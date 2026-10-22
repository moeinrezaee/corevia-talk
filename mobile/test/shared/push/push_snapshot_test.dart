import 'package:corevia_talk/shared/push/push_snapshot.dart';
import 'package:corevia_talk/shared/push/push_subscription.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('push community snapshot carries flattened resolution policies', () {
    final subscription = buildDesiredCoreviaTalkPushSubscriptions(
      myPubkey: 'a' * 64,
    ).single;
    final snapshot = CoreviaTalkPushCommunitySnapshot(
      id: 'community',
      name: 'Team',
      relayUrl: 'https://relay.example.com',
      pubkey: 'a' * 64,
      subscriptions: [subscription],
    );

    final decoded = CoreviaTalkPushCommunitySnapshot.fromJson(snapshot.toJson());

    expect(decoded.toJson(), snapshot.toJson());
    expect(decoded.subscriptions, hasLength(1));
  });
}
