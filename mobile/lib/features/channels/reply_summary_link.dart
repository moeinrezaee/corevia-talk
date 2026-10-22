import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/i18n/app_language.dart';
import '../../shared/profile/user_cache_provider.dart';
import '../../shared/theme/theme.dart';
import 'small_avatar.dart';
import 'timeline_message.dart';

/// Desktop-style reply link with a curved branch below the message bubble.
class ReplySummaryLink extends ConsumerWidget {
  const ReplySummaryLink({
    super.key,
    required this.summary,
    required this.onTap,
    this.hasReactions = false,
    this.mirrored = false,
  });

  final ThreadSummary summary;
  final VoidCallback onTap;
  final bool hasReactions;

  /// Places the connector on the outgoing edge without reversing its contents.
  final bool mirrored;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participants = summary.participantPubkeys.take(3).toList();
    final userCache = ref.watch(userCacheProvider);
    final label = summary.isCountPending
        ? tl('Replies')
        : tlt(summary.replyCount == 1 ? '{0} reply' : '{0} replies', [
            '${summary.replyCount}${summary.isLowerBound ? '+' : ''}',
          ]);
    // `mirrored` puts the connector on the end side; in a right-to-left UI the
    // painter's left-to-right frame must be flipped the other way round.
    final flipConnector =
        (Directionality.of(context) == TextDirection.rtl) != mirrored;
    final connectorTop = hasReactions ? -Grid.half : Grid.half;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: mirrored ? 0 : Grid.xxs,
        end: mirrored ? Grid.xxs : 0,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: connectorTop,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ReplyConnector(
                  context.colors.outlineVariant,
                  flipConnector ? TextDirection.rtl : TextDirection.ltr,
                  connectorTop,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: mirrored ? 0 : Grid.twelve,
              end: mirrored ? Grid.twelve : 0,
            ),
            child: Semantics(
              button: true,
              label: tlt('View thread: {0}', [label]),
              onTap: onTap,
              excludeSemantics: true,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(Radii.container),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Padding(
                    padding: const EdgeInsets.all(Grid.half),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (participants.isNotEmpty) ...[
                          SizedBox(
                            width:
                                Grid.gutter +
                                (participants.length - 1) * Grid.twelve,
                            height: Grid.gutter,
                            child: Stack(
                              children: [
                                for (var i = 0; i < participants.length; i++)
                                  PositionedDirectional(
                                    start: i * Grid.twelve,
                                    child: SmallAvatar(
                                      pubkey: participants[i],
                                      userCache: userCache,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Grid.half),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.labelMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyConnector extends CustomPainter {
  const _ReplyConnector(this.color, this.direction, this.topOffset);
  final Color color;
  final TextDirection direction;
  final double topOffset;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (direction == TextDirection.rtl) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    // Keep the endpoint aligned with the unchanged reply avatars.
    final middle = (size.height - topOffset) / 2;
    // Desktop uses a 12px outer corner with a 2px border: the stroke's
    // centerline follows an 11px circular arc, rather than a tight elbow.
    const radius = Grid.twelve - 1;
    final path = Path()
      ..moveTo(1, 0)
      ..lineTo(1, middle - radius)
      ..arcToPoint(
        Offset(Grid.twelve, middle),
        radius: const Radius.circular(radius),
        clockwise: false,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ReplyConnector oldDelegate) =>
      color != oldDelegate.color ||
      direction != oldDelegate.direction ||
      topOffset != oldDelegate.topOffset;
}
