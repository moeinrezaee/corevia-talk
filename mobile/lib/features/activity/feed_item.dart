import 'package:flutter/foundation.dart';
import '../../shared/i18n/app_language.dart';

import '../../shared/relay/thread_reference.dart';

@immutable
class FeedItem {
  final String id;
  final int kind;
  final String pubkey;
  final String content;
  final int createdAt;
  final String? channelId;
  final String channelName;
  final List<List<String>> tags;
  final String
  category; // "mention", "needs_action", "activity", "agent_activity"

  const FeedItem({
    required this.id,
    required this.kind,
    required this.pubkey,
    required this.content,
    required this.createdAt,
    required this.channelId,
    required this.channelName,
    required this.tags,
    required this.category,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) => FeedItem(
    id: json['id'] as String,
    kind: json['kind'] as int,
    pubkey: json['pubkey'] as String,
    content: json['content'] as String,
    createdAt: json['created_at'] as int,
    channelId: json['channel_id'] as String?,
    channelName: (json['channel_name'] as String?) ?? '',
    tags:
        (json['tags'] as List<dynamic>?)
            ?.map((t) => (t as List<dynamic>).map((e) => e as String).toList())
            .toList() ??
        const [],
    category: json['category'] as String,
  );

  /// The message whose thread directly contains this item, when this event is
  /// a reply. For nested replies this is the direct parent, not the outer root.
  String? get threadHeadId => parseThreadReference(tags).parentId;

  /// Human-readable headline based on event kind and category.
  String get headline {
    switch (kind) {
      case 45001:
        return tl('Forum post');
      case 45003:
        return tl('Forum reply');
      case 46010:
        return tl('Approval requested');
      case 43001:
        return tl('Job requested');
      case 43002:
        return tl('Job accepted');
      case 43003:
        return tl('Progress update');
      case 43004:
        return tl('Job result');
      case 43005:
        return tl('Job cancelled');
      case 43006:
        return tl('Job failed');
      default:
        if (category == 'mention') return tl('Mention');
        if (category == 'agent_activity') return tl('Agent update');
        return tl('Channel update');
    }
  }

  /// Trimmed content, with a fallback for empty events.
  String get displayContent {
    final trimmed = content.trim();
    if (trimmed.isNotEmpty) return trimmed;
    if (kind == 46010) return tl('A workflow is waiting for approval.');
    return tl('No additional details.');
  }
}

/// Parsed response from GET /api/feed.
@immutable
class HomeFeedResponse {
  final List<FeedItem> mentions;
  final List<FeedItem> needsAction;
  final List<FeedItem> activity;
  final List<FeedItem> agentActivity;

  HomeFeedResponse({
    required this.mentions,
    required this.needsAction,
    required this.activity,
    required this.agentActivity,
  });

  factory HomeFeedResponse.fromJson(Map<String, dynamic> json) {
    final feed = json['feed'] as Map<String, dynamic>;
    return HomeFeedResponse(
      mentions: _parseItems(feed['mentions']),
      needsAction: _parseItems(feed['needs_action']),
      activity: _parseItems(feed['activity']),
      agentActivity: _parseItems(feed['agent_activity']),
    );
  }

  /// All items merged into a single list, sorted newest-first.
  late final List<FeedItem> all = () {
    final items = [...mentions, ...needsAction, ...activity, ...agentActivity];
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<FeedItem>.unmodifiable(items);
  }();

  bool get isEmpty =>
      mentions.isEmpty &&
      needsAction.isEmpty &&
      activity.isEmpty &&
      agentActivity.isEmpty;
}

List<FeedItem> _parseItems(dynamic json) {
  if (json == null) return const [];
  return (json as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map(FeedItem.fromJson)
      .toList();
}
