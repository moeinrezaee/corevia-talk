import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// A consistent inline author row for message-oriented surfaces.
class MessageAuthorMeta extends StatelessWidget {
  /// Primary author name shown at the start of the row.
  final String displayName;

  /// Optional secondary username, hidden when blank or equal to [displayName].
  final String? username;

  /// Timestamp label shown after the author metadata.
  final String timestamp;

  /// Whether metadata includes the timestamp alongside the author.
  final bool showTimestamp;

  /// Color applied to [displayName].
  final Color nameColor;

  /// Color applied to the username and [timestamp].
  final Color metadataColor;

  /// Optional callback invoked when [displayName] is tapped.
  final VoidCallback? onAuthorTap;

  /// Optional key assigned to the display-name text.
  final Key? displayNameKey;

  /// Optional key assigned to the username text.
  final Key? usernameKey;

  /// Optional key assigned to the timestamp text.
  final Key? timestampKey;

  /// Optional second line under the name (agent owner, persona).
  final String? roleLine;

  /// The author sits on the UI end side (avatar there): the header is the
  /// mirror image of the own one, with the name next to the avatar and the
  /// other items ordered away from it.
  final bool mirrored;

  /// Base text style for [displayName], with [nameColor] applied.
  final TextStyle nameStyle;

  /// Base text style for secondary metadata, with [metadataColor] applied.
  final TextStyle metadataStyle;

  /// Base text style for [timestamp], with [metadataColor] applied.
  final TextStyle timestampStyle;

  /// Mirrors metadata order without changing text reading direction.
  final bool reversed;

  /// Positions the metadata within the available message width.
  final MainAxisAlignment alignment;

  /// Creates an inline author row with optional username and tap handling.
  const MessageAuthorMeta({
    super.key,
    required this.displayName,
    required this.timestamp,
    required this.nameColor,
    required this.metadataColor,
    this.username,
    this.alignment = MainAxisAlignment.start,
    this.reversed = false,
    this.showTimestamp = true,
    this.onAuthorTap,
    this.displayNameKey,
    this.usernameKey,
    this.timestampKey,
    this.roleLine,
    this.mirrored = false,
    this.nameStyle = messageUsernameTextStyle,
    this.metadataStyle = messageMetadataTextStyle,
    this.timestampStyle = messageTimestampTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedUsername = username?.trim();
    final showUsername =
        normalizedUsername != null &&
        normalizedUsername.isNotEmpty &&
        normalizedUsername != displayName.trim();
    final resolvedNameStyle = nameStyle.copyWith(color: nameColor);
    final resolvedMetadataStyle = metadataStyle.copyWith(color: metadataColor);
    final resolvedTimestampStyle = timestampStyle.copyWith(
      color: metadataColor,
    );

    Widget authorName = Text(
      displayName,
      key: displayNameKey,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: resolvedNameStyle,
    );
    if (onAuthorTap != null) {
      authorName = GestureDetector(onTap: onAuthorTap, child: authorName);
    }

    final role = roleLine?.trim();

    return LayoutBuilder(
      builder: (context, constraints) {
        final metadataMaxWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth / (showUsername ? 3 : 2)
            : double.infinity;
        // The name may use up to 80% of the room.
        final nameMaxWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth * 0.8
            : double.infinity;

        final items = <Widget>[
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: nameMaxWidth),
              child: authorName,
            ),
          ),
          if (showUsername) ...[
            const SizedBox(width: Grid.half),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: metadataMaxWidth),
              child: Text(
                normalizedUsername,
                key: usernameKey,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: resolvedMetadataStyle,
              ),
            ),
          ],
          if (showTimestamp) ...[
            const SizedBox(width: Grid.xxs),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: metadataMaxWidth),
              child: Text(
                timestamp,
                key: timestampKey,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: resolvedTimestampStyle,
              ),
            ),
          ],
        ];
        final header = Row(
          mainAxisAlignment: alignment,
          crossAxisAlignment: CrossAxisAlignment.center,
          // Mirrored headers list the items from the avatar outwards, which
          // is the reverse of the reading order on the end side.
          children: (mirrored != reversed) ? items.reversed.toList() : items,
        );
        if (role == null || role.isEmpty) return header;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: mirrored
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            header,
            Text(
              role,
              key: ValueKey('${displayNameKey ?? 'message'}-role-line'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: resolvedMetadataStyle,
            ),
          ],
        );
      },
    );
  }
}
