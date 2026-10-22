import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:corevia_talk/shared/hosted/account_identity_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/nostr.dart' as nostr;
import 'package:corevia_talk/shared/deeplink/deep_link.dart';
import 'package:corevia_talk/shared/hosted/web_connect_binding.dart';
import 'package:corevia_talk/shared/hosted/hosted_environment.dart';

void main() {
  final fields = {
    'challenge_id': '12345678-1234-1234-1234-123456789012',
    'nonce': 'a' * 43,
    'verification_code': '123456',
    'audience': 'corevia-talk:nostr-identity',
    'action': 'bind_nostr_identity',
    'protocol': 'corevia-talk-nostr-identity',
    'version': '1',
    'origin': HostedEnvironment.origin.toString(),
    'expires_at': '2099-01-01T00:00:00Z',
    'return': 'browser_fragment_v1',
    'callback_url': HostedEnvironment.origin.resolve('/corevia-talk').toString(),
  };
  Uri link(Map<String, String> values) =>
      Uri(scheme: 'corevia-talk', host: 'nostr-bind', queryParameters: values);
  final keys = nostr.Keys('1'.padLeft(64, '0'));
  Future<T> withKeys<T>(Future<T> Function(nostr.Keys) operation) =>
      operation(keys);

  test('production parser recognizes web links and rejects ambiguous trust', () {
    expect(parseCoreviaTalkDeepLink(link(fields)), isA<NostrBindDeepLink>());
    final otherOrigin = HostedEnvironment.origin.host == 'app.builderlab.xyz'
        ? 'https://app.builderlabstaging.xyz'
        : 'https://app.builderlab.xyz';
    expect(
      parseCoreviaTalkDeepLink(
        link({
          ...fields,
          'origin': otherOrigin,
          'callback_url': '$otherOrigin/corevia-talk',
        }),
      ),
      isNull,
    );
    for (final entry in {
      'origin': 'https://attacker.example',
      'callback_url': 'https://app.builderlab.xyz/corevia-talk?redirect=evil',
      'nonce': 'short',
      'verification_code': '12345',
      'version': '2',
      'expires_at': '2099-01-01T00:00:00',
    }.entries) {
      expect(
        parseCoreviaTalkDeepLink(link({...fields, entry.key: entry.value})),
        isNull,
      );
    }
    expect(
      parseCoreviaTalkDeepLink(Uri.parse('${link(fields)}&nonce=duplicate')),
      isNull,
    );
    expect(parseCoreviaTalkDeepLink(link({...fields, 'extra': 'value'})), isNull);
    expect(
      parseCoreviaTalkDeepLink(
        Uri.parse(
          'corevia-talk://add-community?relay=wss%3A%2F%2Fexample.communities.buzz.xyz&name=Example',
        ),
      ),
      isA<AddCommunityDeepLink>(),
    );
    expect(
      parseCoreviaTalkDeepLink(
        Uri.parse(
          'corevia-talk://add-community?relay=wss%3A%2F%2Fexample.com%2Fpath&name=Example',
        ),
      ),
      isNull,
    );
    expect(
      parseCoreviaTalkDeepLink(
        Uri.parse(
          'corevia-talk://add-community?relay=wss%3A%2F%2Fexample.com&name=Example&name=Other',
        ),
      ),
      isNull,
    );
  });

  test(
    'signs desktop-compatible event and verifies account before browser return',
    () async {
      var verified = false;
      final result = await WebConnectBindingService().complete(
        request: parseNostrBindDeepLink(link(fields))!,
        subject: 'account',
        expectedPubkey: keys.public,
        withKeys: withKeys,
        verify:
            ({
              required subject,
              required challengeId,
              required nonce,
              required signedPayload,
            }) async {
              expect(subject, 'account');
              expect(challengeId, fields['challenge_id']);
              final event = jsonDecode(signedPayload) as Map;
              expect(event['kind'], 24243);
              expect(event['content'], '');
              expect(event['pubkey'], keys.public);
              expect(
                event['tags'],
                contains(equals(['verification_code', '123456'])),
              );
              verified = true;
              return keys.public;
            },
      );
      expect(verified, isTrue);
      expect(result, HostedEnvironment.origin.resolve('/corevia-talk'));
      expect(result.hasFragment, isFalse);
    },
  );

  test(
    'unverified or mismatched identity cannot produce browser return',
    () async {
      for (final mismatch in [false, true]) {
        await expectLater(
          WebConnectBindingService().complete(
            request: parseNostrBindDeepLink(link(fields))!,
            subject: 'account',
            expectedPubkey: keys.public,
            withKeys: withKeys,
            verify:
                ({
                  required subject,
                  required challengeId,
                  required nonce,
                  required signedPayload,
                }) async {
                  if (!mismatch) {
                    throw StateError('account does not own challenge');
                  }
                  return '0' * 64;
                },
          ),
          throwsA(anything),
        );
      }
    },
  );

  test('verification runs outside the identity store signing lock', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});
    final store = AccountIdentityStore();
    await store.create(keys.nsec);
    await WebConnectBindingService()
        .complete(
          request: parseNostrBindDeepLink(link(fields))!,
          subject: 'account',
          expectedPubkey: keys.public,
          withKeys: store.withKeys,
          verify:
              ({
                required subject,
                required challengeId,
                required nonce,
                required signedPayload,
              }) async {
                return (await store.read())!.pubkey;
              },
        )
        .timeout(const Duration(seconds: 2));
  });

  test('expiry and local mismatch stop before verification', () async {
    var calls = 0;
    for (final expired in [false, true]) {
      await expectLater(
        WebConnectBindingService(
          now: () => expired ? DateTime.utc(2100) : DateTime.utc(2026),
        ).complete(
          request: parseNostrBindDeepLink(link(fields))!,
          subject: 'account',
          expectedPubkey: expired ? keys.public : '0' * 64,
          withKeys: withKeys,
          verify:
              ({
                required subject,
                required challengeId,
                required nonce,
                required signedPayload,
              }) async {
                calls++;
                return keys.public;
              },
        ),
        throwsFormatException,
      );
    }
    expect(calls, 0);
  });
}
