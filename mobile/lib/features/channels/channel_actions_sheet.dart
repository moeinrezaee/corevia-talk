import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:buzz/shared/theme/buzz_icons.dart';

import '../../shared/clipboard_utils.dart';
import '../../shared/identity_names/identity_names_provider.dart';
import 'dm_channel_labels.dart';
import '../../shared/mentions/agent_identity_provider.dart';
import '../../shared/theme/theme.dart';
import '../../shared/widgets/sheet_action_section.dart';
import '../../shared/widgets/app_list.dart';
import '../../shared/widgets/app_list_card.dart';
import '../../shared/widgets/avatar_image.dart';
import '../../shared/widgets/buzz_action_tile.dart';
import '../../shared/widgets/buzz_loading_indicator.dart';
import '../../shared/widgets/frosted_app_bar.dart';
import '../../shared/widgets/frosted_scaffold.dart';
import '../../shared/widgets/ios_glass_navigation_button.dart';
import '../../shared/widgets/tabler_star_icon.dart';
import '../../shared/widgets/modal_presentation.dart';
import 'channel.dart';
import 'add_members_sheet.dart';
import 'channel_identity_names_provider.dart';
import 'channel_management_provider.dart';
import 'channel_mutes/channel_mutes_provider.dart';
import 'channel_sections/channel_sections_provider.dart';
import 'channel_stars/channel_stars_provider.dart';
import 'channels_provider.dart';
import 'manage_channel_sheet.dart';
import 'members_sheet.dart';
import '../../shared/profile/user_cache_provider.dart';
import '../../shared/read_state/read_state_provider.dart';
import '../../shared/read_state/read_state_time.dart';
import '../../shared/i18n/app_language.dart';
import '../../shared/i18n/text_direction.dart';

part 'channel_details_page.dart';

/// Opens the mobile channel actions sheet and returns whether its parent page
/// should close after a successful lifecycle action.
Future<bool?> showChannelActionsSheet({
  required BuildContext context,
  required Channel channel,
  required bool isUnread,
  VoidCallback? onMarkRead,
  String? sectionId,
}) => showBuzzModalBottomSheet<bool>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  constraints: BoxConstraints(
    maxWidth: 640,
    maxHeight: MediaQuery.sizeOf(context).height * 0.7,
  ),
  builder: (_) => ChannelActionsSheet(
    channel: channel,
    isUnread: isUnread,
    onMarkRead: onMarkRead,
    sectionId: sectionId,
  ),
);

/// Mobile action sheet for channel-level read, organization, and lifecycle
/// operations.
class ChannelActionsSheet extends HookConsumerWidget {
  const ChannelActionsSheet({
    super.key,
    required this.channel,
    required this.isUnread,
    this.onMarkRead,
    this.sectionId,
  });

  final Channel channel;
  final bool isUnread;
  final VoidCallback? onMarkRead;
  final String? sectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayedChannel = useState(channel);
    final currentChannel = displayedChannel.value;
    final isMuted =
        ref.watch(channelMutesProvider).store.channels[channel.id]?.muted ==
        true;
    final isStarred =
        !channel.isDm &&
        ref.watch(channelStarsProvider).store.channels[channel.id]?.starred ==
            true;
    final membersAsync = channel.isDm
        ? const AsyncValue<List<ChannelMember>>.data([])
        : ref.watch(channelMembersProvider(channel.id));
    final agentOwnersAsync = channel.isDm
        ? const AsyncValue<Map<String, String>>.data({})
        : ref.watch(agentOwnersProvider);
    final currentPubkey = ref.watch(currentPubkeyProvider)?.toLowerCase();
    final currentMember = membersAsync.value?.cast<ChannelMember?>().firstWhere(
      (member) => member?.pubkey.toLowerCase() == currentPubkey,
      orElse: () => null,
    );
    final ownsOwnerAgent =
        currentPubkey != null &&
        membersAsync.value?.any(
              (member) =>
                  member.isOwner &&
                  agentOwnersAsync.value?[member.pubkey.toLowerCase()]
                          ?.toLowerCase() ==
                      currentPubkey,
            ) ==
            true;
    final canManageLifecycle =
        currentMember?.isElevated == true || ownsOwnerAgent;
    final canArchive = !channel.isArchived && canManageLifecycle;
    final canUnarchive = channel.isArchived && canManageLifecycle;
    final canDelete =
        !channel.isArchived &&
        (currentMember?.isOwner == true || ownsOwnerAgent);
    final lifecycleCapabilitiesLoading =
        membersAsync.isLoading || agentOwnersAsync.isLoading;
    final lifecycleCapabilitiesUnavailable =
        membersAsync.hasError || agentOwnersAsync.hasError;

    void close() => Navigator.of(context).pop();

    return SafeArea(
      top: false,
      child: IconTheme.merge(
        data: const IconThemeData(size: 22),
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(
            Grid.gutter,
            0,
            Grid.gutter,
            Grid.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!channel.isDm) ...[
                _ChannelQuickActionsRow(
                  isStarred: isStarred,
                  isUnread: isUnread,
                  onToggleStar: () {
                    close();
                    final notifier = ref.read(channelStarsProvider.notifier);
                    isStarred
                        ? notifier.unstarChannel(channel.id)
                        : notifier.starChannel(channel.id);
                  },
                  onToggleRead: () {
                    close();
                    final timestamp = dateTimeToUnixSeconds(
                      channel.lastMessageAt,
                    );
                    if (isUnread) {
                      onMarkRead?.call();
                      if (timestamp != null) {
                        ref
                            .read(readStateProvider.notifier)
                            .markContextRead(
                              channel.id,
                              timestamp,
                              clearForcedMessages: true,
                            );
                        ref
                            .read(channelsProvider.notifier)
                            .clearObservedUnreadCoveredByRead(
                              channel.id,
                              timestamp,
                            );
                      }
                    } else {
                      ref
                          .read(readStateProvider.notifier)
                          .markContextUnread(channel.id, channelId: channel.id);
                    }
                  },
                ),
                SizedBox(height: Grid.xs),
              ],
              SheetActionSection(
                children: [
                  if (!channel.isDm)
                    ListTile(
                      leading: Icon(BuzzIcons.folderInput),
                      title: Text(tl('Move to section…')),
                      onTap: () async {
                        final pageContext = Navigator.of(
                          context,
                          rootNavigator: true,
                        ).context;
                        close();
                        await _showMoveSectionSheet(
                          pageContext,
                          ref,
                          channel: channel,
                          sectionId: sectionId,
                        );
                      },
                    ),
                  ListTile(
                    leading: Icon(isMuted ? BuzzIcons.bell : BuzzIcons.bellOff),
                    title: Text(
                      isMuted ? tl('Unmute channel') : tl('Mute channel'),
                    ),
                    onTap: () {
                      close();
                      final notifier = ref.read(channelMutesProvider.notifier);
                      isMuted
                          ? notifier.unmuteChannel(channel.id)
                          : notifier.muteChannel(channel.id);
                    },
                  ),
                  if (!channel.isDm)
                    ListTile(
                      leading: Icon(BuzzIcons.settings),
                      title: Text(tl('Manage channel')),
                      onTap: () async {
                        final shouldClose = await showManageChannelSheet(
                          context: context,
                          channel: currentChannel,
                          canEditDetails:
                              canManageLifecycle && !currentChannel.isArchived,
                          onChannelUpdated: (updated) =>
                              displayedChannel.value = updated,
                        );
                        if (shouldClose == true && context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      },
                    ),
                ],
              ),
              SheetActionSection(
                children: [
                  ListTile(
                    leading: Icon(BuzzIcons.copy),
                    title: Text(tl('Copy channel name')),
                    onTap: () {
                      close();
                      copyToClipboard(
                        context,
                        currentChannel.name,
                        message: tl('Channel name copied to clipboard'),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(BuzzIcons.hash),
                    title: Text(tl('Copy channel ID')),
                    onTap: () {
                      close();
                      copyToClipboard(
                        context,
                        channel.id,
                        message: tl('Channel ID copied to clipboard'),
                      );
                    },
                  ),
                ],
              ),
              if (!channel.isDm)
                SheetActionSection(
                  children: [
                    if (channel.isMember && !channel.isArchived)
                      _ActionTile(
                        icon: BuzzIcons.logOut,
                        label: tl('Leave channel'),
                        destructive: true,
                        onTap: () => _confirmAndRun(
                          context,
                          ref,
                          title: tlt('Leave #{0}?', [currentChannel.name]),
                          body: tl(
                            'You’ll stop receiving messages from this channel.',
                          ),
                          confirmLabel: tl('Leave'),
                          action: () => ref
                              .read(channelActionsProvider)
                              .leaveChannel(channel.id),
                        ),
                      ),
                    if (lifecycleCapabilitiesLoading)
                      ListTile(
                        enabled: false,
                        leading: BuzzLoadingIndicator(
                          size: 20,
                          semanticLabel: tl('Loading channel actions'),
                        ),
                        title: Text(tl('Loading channel actions…')),
                      )
                    else if (lifecycleCapabilitiesUnavailable)
                      ListTile(
                        enabled: false,
                        leading: Icon(BuzzIcons.triangleAlert),
                        title: Text(tl('Channel actions unavailable')),
                      )
                    else ...[
                      if (canArchive)
                        _ActionTile(
                          icon: BuzzIcons.archive,
                          label: tl('Archive channel'),
                          onTap: () => _confirmAndRun(
                            context,
                            ref,
                            title: tlt('Archive #{0}?', [currentChannel.name]),
                            body: tl('The channel will become read-only.'),
                            confirmLabel: tl('Archive'),
                            action: () => ref
                                .read(channelActionsProvider)
                                .archiveChannel(channel.id),
                          ),
                        ),
                      if (canUnarchive)
                        _ActionTile(
                          icon: BuzzIcons.archiveRestore,
                          label: tl('Unarchive channel'),
                          onTap: () => _confirmAndRun(
                            context,
                            ref,
                            title: tlt('Unarchive #{0}?', [
                              currentChannel.name,
                            ]),
                            body: tl('The channel will become active again.'),
                            confirmLabel: tl('Unarchive'),
                            action: () => ref
                                .read(channelActionsProvider)
                                .unarchiveChannel(channel.id),
                          ),
                        ),
                      if (canDelete)
                        _ActionTile(
                          icon: BuzzIcons.trash2,
                          label: tl('Delete channel'),
                          destructive: true,
                          onTap: () => _confirmAndRun(
                            context,
                            ref,
                            title: tlt('Delete #{0}?', [currentChannel.name]),
                            body: tl(
                              'This permanently deletes the channel and cannot be undone.',
                            ),
                            confirmLabel: tl('Delete'),
                            action: () => ref
                                .read(channelActionsProvider)
                                .deleteChannel(channel.id),
                          ),
                        ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelQuickActionsRow extends StatelessWidget {
  const _ChannelQuickActionsRow({
    required this.isStarred,
    required this.isUnread,
    required this.onToggleStar,
    required this.onToggleRead,
  });

  final bool isStarred;
  final bool isUnread;
  final VoidCallback onToggleStar;
  final VoidCallback onToggleRead;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _ChannelQuickAction(
          icon: BuzzIcons.star,
          iconWidget: TablerStarIcon(
            color: context.colors.onSurface,
            filled: isStarred,
          ),
          label: isStarred ? tl('Unstar') : tl('Star'),
          onTap: onToggleStar,
        ),
      ),
      SizedBox(width: Grid.twelve),
      Expanded(
        child: _ChannelQuickAction(
          icon: isUnread ? BuzzIcons.checkCheck : BuzzIcons.circleDot,
          label: isUnread ? tl('Mark Read') : tl('Mark Unread'),
          onTap: onToggleRead,
        ),
      ),
    ],
  );
}

class _ChannelQuickAction extends StatelessWidget {
  const _ChannelQuickAction({
    required this.icon,
    this.iconWidget,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Widget? iconWidget;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      unawaited(HapticFeedback.lightImpact());
      onTap();
    },
    behavior: HitTestBehavior.opaque,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 68 + (Grid.xxs * 2),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(Radii.dialog),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget ??
                  Icon(icon, size: 22, color: context.colors.onSurface),
              const SizedBox(height: Grid.xxs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: destructive ? context.colors.error : null),
    title: Text(
      label,
      style: destructive ? TextStyle(color: context.colors.error) : null,
    ),
    onTap: () {
      unawaited(HapticFeedback.lightImpact());
      onTap();
    },
  );
}

Future<void> _confirmAndRun(
  BuildContext sheetContext,
  WidgetRef ref, {
  required String title,
  required String body,
  required String confirmLabel,
  required Future<void> Function() action,
}) async {
  final pageContext = Navigator.of(sheetContext, rootNavigator: true).context;
  final confirmed = await showBuzzDialog<bool>(
    context: pageContext,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(tl('Cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await action();
    if (pageContext.mounted) Navigator.of(pageContext).pop(true);
  } catch (error) {
    if (!pageContext.mounted) return;
    ScaffoldMessenger.of(pageContext).showSnackBar(
      SnackBar(
        content: Text(
          tlt('Couldn’t {0} channel. Try again.', [confirmLabel.toLowerCase()]),
        ),
      ),
    );
  }
}

Future<void> _showMoveSectionSheet(
  BuildContext context,
  WidgetRef ref, {
  required Channel channel,
  required String? sectionId,
}) async {
  final sections = [...ref.read(channelSectionsProvider).store.sections]
    ..sort((a, b) => a.order.compareTo(b.order));
  await showBuzzModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: IconTheme.merge(
        data: const IconThemeData(size: 22),
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(
            Grid.gutter,
            0,
            Grid.gutter,
            Grid.xs,
          ),
          child: SheetActionSection(
            children: [
              for (final section in sections)
                ListTile(
                  leading: const Icon(BuzzIcons.folder),
                  title: Text(section.name),
                  trailing: sectionId == section.id
                      ? Icon(
                          BuzzIcons.check,
                          color: sheetContext.colors.primary,
                        )
                      : null,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ref
                        .read(channelSectionsProvider.notifier)
                        .assignChannel(channel.id, section.id);
                  },
                ),
              ListTile(
                leading: Icon(BuzzIcons.folderPlus),
                title: Text(tl('New section…')),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final name = await _showSectionNameDialog(context);
                  if (name == null || name.isEmpty) return;
                  final notifier = ref.read(channelSectionsProvider.notifier);
                  notifier.createSection(name);
                  final created = ref
                      .read(channelSectionsProvider)
                      .store
                      .sections
                      .where((section) => section.name == name.trim())
                      .lastOrNull;
                  if (created != null) {
                    notifier.assignChannel(channel.id, created.id);
                  }
                },
              ),
              if (sectionId != null)
                ListTile(
                  leading: Icon(BuzzIcons.folderMinus),
                  title: Text(tl('Remove from section')),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ref
                        .read(channelSectionsProvider.notifier)
                        .unassignChannel(channel.id);
                  },
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<String?> _showSectionNameDialog(BuildContext context) async {
  final controller = TextEditingController();
  final result = await showBuzzDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(tl('New Section')),
      content: TextField(
        textAlign: uiStartTextAlign(context),
        controller: controller,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(tl('Cancel')),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(controller.text.trim()),
          child: Text(tl('Create')),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}
