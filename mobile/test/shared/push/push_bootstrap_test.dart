import 'package:corevia_talk/shared/push/dev_push_lease.dart';
import 'package:corevia_talk/shared/community/community.dart';
import 'package:corevia_talk/shared/push/push_bootstrap.dart';
import 'package:corevia_talk/shared/push/push_subscription.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets('first opt-in starts registration without switching community', (
    tester,
  ) async {
    var registrations = 0;
    Widget bootstrap(bool enabled) => CoreviaTalkPushRegistrationBootstrap(
      shouldRegister: enabled,
      attemptKey: 'same-community|same-relay',
      startRegistration: () async {
        registrations += 1;
      },
      child: const SizedBox(),
    );
    await tester.pumpWidget(bootstrap(false));
    expect(registrations, 0);
    await tester.pumpWidget(bootstrap(true));
    expect(registrations, 1);
    await tester.pumpWidget(bootstrap(true));
    expect(registrations, 1);
  });

  testWidgets('new community starts registration once capability arrives', (
    tester,
  ) async {
    final community = Community.create(
      name: 'Team',
      relayUrl: 'wss://relay.example',
    );
    var registrations = 0;
    Widget bootstrap(CoreviaTalkPushLeaseDescriptor? descriptor) =>
        CoreviaTalkPushRegistrationBootstrap(
          shouldRegister: coreviaTalkPushLifecycleEnabled(
            community: community,
            descriptor: descriptor,
          ),
          attemptKey: '${community.id}|${community.relayUrl}',
          startRegistration: () async => registrations += 1,
          child: const SizedBox(),
        );
    await tester.pumpWidget(bootstrap(null));
    expect(registrations, 0);
    final descriptor = _descriptor(keyId: 'relay-v1', pubkey: _hex('b'));
    await tester.pumpWidget(bootstrap(descriptor));
    expect(registrations, 1);
    await tester.pumpWidget(bootstrap(descriptor));
    expect(registrations, 1);
  });

  test(
    'superseded lease acceptance is a retryable publication failure',
    () async {
      await expectLater(
        publishCoreviaTalkPushLeaseRecoverably(
          reserveGeneration: () async => 1,
          publish: (_) async {},
          markAccepted: (_) async => false,
        ),
        throwsStateError,
      );
    },
  );

  test('failed bootstrap attempt becomes retryable after the delay', () async {
    final gate = CoreviaTalkPushAttemptGate(retryDelay: Duration.zero);
    addTearDown(gate.dispose);
    var retries = 0;

    expect(gate.tryBegin('attempt'), isTrue);
    gate.failed('attempt', retry: () => retries += 1);
    await Future<void>.delayed(Duration.zero);

    expect(retries, 1);
    expect(gate.tryBegin('attempt'), isTrue);
  });

  testWidgets('a failed attempt stays blocked until the retry delay', (
    tester,
  ) async {
    final gate = CoreviaTalkPushAttemptGate();
    addTearDown(gate.dispose);
    var retries = 0;
    expect(gate.tryBegin('attempt'), isTrue);
    gate.failed('attempt', retry: () => retries++);
    expect(gate.tryBegin('attempt'), isFalse);
    await tester.pump(const Duration(seconds: 4));
    expect(gate.tryBegin('attempt'), isFalse);
    expect(retries, 0);
    await tester.pump(const Duration(seconds: 1));
    expect(retries, 1);
    expect(gate.tryBegin('attempt'), isTrue);
  });

  test('a new attempt cancels an obsolete scheduled retry', () async {
    final gate = CoreviaTalkPushAttemptGate(retryDelay: Duration.zero);
    addTearDown(gate.dispose);
    var retries = 0;

    expect(gate.tryBegin('old'), isTrue);
    gate.failed('old', retry: () => retries += 1);
    expect(gate.tryBegin('new'), isTrue);
    await Future<void>.delayed(Duration.zero);

    expect(retries, 0);
    expect(gate.tryBegin('new'), isFalse);
  });

  test('successful bootstrap becomes retryable at renewal time', () async {
    final gate = CoreviaTalkPushAttemptGate(retryDelay: Duration.zero);
    addTearDown(gate.dispose);
    var retries = 0;

    expect(gate.tryBegin('attempt'), isTrue);
    gate.retryAfter('attempt', delay: Duration.zero, retry: () => retries += 1);
    await Future<void>.delayed(Duration.zero);

    expect(retries, 1);
    expect(gate.tryBegin('attempt'), isTrue);
  });

  test('completed bootstrap attempt can run again for later work', () {
    final gate = CoreviaTalkPushAttemptGate();
    addTearDown(gate.dispose);

    expect(gate.tryBegin('attempt'), isTrue);
    gate.complete('attempt');
    expect(gate.tryBegin('attempt'), isTrue);
  });

  test('publication attempt changes when the relay executor rotates', () {
    final subscription = CoreviaTalkPushSubscription(
      filter: CoreviaTalkPushFilter(kinds: const [9], pTags: [_hex('a')]),
      notificationClass: 'default',
    );
    final original = coreviaTalkPushPublicationAttemptKey(
      communityId: 'community',
      relayBaseUrl: 'https://relay.example',
      token: 'token',
      descriptor: _descriptor(keyId: 'relay-v1', pubkey: _hex('b')),
      subscriptions: [subscription],
    );

    expect(
      coreviaTalkPushPublicationAttemptKey(
        communityId: 'community',
        relayBaseUrl: 'https://relay.example',
        token: 'token',
        descriptor: _descriptor(keyId: 'relay-v2', pubkey: _hex('b')),
        subscriptions: [subscription],
      ),
      isNot(original),
    );
    expect(
      coreviaTalkPushPublicationAttemptKey(
        communityId: 'community',
        relayBaseUrl: 'https://relay.example',
        token: 'token',
        descriptor: _descriptor(keyId: 'relay-v1', pubkey: _hex('c')),
        subscriptions: [subscription],
      ),
      isNot(original),
    );
  });

  test('default push requires relay capability and respects opt-out', () {
    final enabled = Community.create(
      name: 'Team',
      relayUrl: 'wss://relay.example',
    );
    final disabled = enabled.copyWith(pushNotificationsEnabled: false);

    expect(
      coreviaTalkPushLifecycleEnabled(
        community: disabled,
        descriptor: _descriptor(keyId: 'relay-v1', pubkey: _hex('b')),
      ),
      isFalse,
    );
    expect(
      coreviaTalkPushLifecycleEnabled(
        community: enabled,
        descriptor: _descriptor(keyId: 'relay-v1', pubkey: _hex('b')),
      ),
      isTrue,
    );
    expect(
      coreviaTalkPushLifecycleEnabled(community: enabled, descriptor: null),
      isFalse,
    );
  });

  test('pending opt-out tombstone keeps active push lifecycle disabled', () {
    final subscription = CoreviaTalkPushSubscription(
      filter: CoreviaTalkPushFilter(kinds: const [9], pTags: [_hex('a')]),
      notificationClass: 'default',
    );
    final community =
        Community.create(
          name: 'Team',
          relayUrl: 'wss://relay.example',
        ).copyWith(
          pushNotificationsEnabled: false,
          pushSubscriptionState:
              CoreviaTalkPushLeaseSubscriptionState.desired(desired: [subscription])
                  .withAccepted(subscriptions: [subscription], generation: 3)
                  .withPendingTombstone(4),
        );

    expect(
      coreviaTalkPushLifecycleEnabled(
        community: community,
        descriptor: _descriptor(keyId: 'relay-v1', pubkey: _hex('b')),
      ),
      isFalse,
    );
  });

  test(
    'relay commit followed by local failure retries at a newer generation',
    () async {
      var durableCursor = 0;
      var relayGeneration = 0;
      var acceptedGeneration = 0;
      var failLocalSave = true;

      Future<int> reserve() async => ++durableCursor;
      Future<void> publish(int generation) async {
        expect(generation, greaterThan(relayGeneration));
        relayGeneration = generation;
      }

      Future<bool> markAccepted(int generation) async {
        if (failLocalSave) {
          failLocalSave = false;
          throw StateError('injected local persistence failure');
        }
        acceptedGeneration = generation;
        return true;
      }

      await expectLater(
        publishCoreviaTalkPushLeaseRecoverably(
          reserveGeneration: reserve,
          publish: publish,
          markAccepted: markAccepted,
        ),
        throwsStateError,
      );
      expect(relayGeneration, 1);
      expect(acceptedGeneration, 0);

      await publishCoreviaTalkPushLeaseRecoverably(
        reserveGeneration: reserve,
        publish: publish,
        markAccepted: markAccepted,
      );
      expect(relayGeneration, 2);
      expect(acceptedGeneration, 2);
    },
  );
}

CoreviaTalkPushLeaseDescriptor _descriptor({
  required String keyId,
  required String pubkey,
}) => CoreviaTalkPushLeaseDescriptor(
  origin: 'wss://relay.example',
  executorKeyId: keyId,
  executorPubkey: pubkey,
  transport: 'apns',
  maxLeaseTtlSeconds: 3600,
  maxContentLength: 4096,
  maxPlaintextLength: 4096,
  maxEndpointLength: 2048,
  maxStringLength: 512,
);

String _hex(String character) => List.filled(64, character).join();
