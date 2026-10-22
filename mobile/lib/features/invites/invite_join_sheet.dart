import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:buzz/shared/theme/buzz_icons.dart';

import '../../shared/theme/theme.dart';
import '../../shared/widgets/buzz_loading_indicator.dart';
import '../../shared/widgets/modal_presentation.dart';
import '../pairing/pairing_page.dart';
import 'invite_join_provider.dart';
import '../../shared/i18n/app_language.dart';

Future<bool?> showInviteJoinSheet(BuildContext context) {
  return showBuzzModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    // The route remains a normal modal while idle, but its contents install a
    // PopScope once a membership claim or starter setup begins. Keep drag and
    // the shared close affordance out of this sheet so they cannot bypass that
    // in-flight guard.
    enableDrag: false,
    showCloseButton: false,
    builder: (_) => const _InviteJoinSheetRoute(),
  );
}

class _InviteJoinSheetRoute extends ConsumerWidget {
  const _InviteJoinSheetRoute();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isClaiming =
        ref.watch(inviteJoinProvider).status == InviteJoinStatus.claiming;
    return PopScope(canPop: !isClaiming, child: const InviteJoinSheet());
  }
}

class InviteJoinSheet extends ConsumerWidget {
  const InviteJoinSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inviteJoinProvider);
    final isClaiming = state.status == InviteJoinStatus.claiming;
    final isStarterSetupRecovery = state.isStarterSetupRecovery;
    final host = state.host ?? tl('unknown host');
    final derivedName = state.communityName;
    final primaryLabel = switch ((
      isClaiming,
      isStarterSetupRecovery,
      state.status,
    )) {
      (true, true, _) => tl('Finishing setup…'),
      (true, false, _) => tl('Joining…'),
      (false, true, InviteJoinStatus.error) => tl('Retry setup'),
      (false, true, _) => tl('Finish setting up'),
      _ => tl('Join'),
    };

    if (state.status == InviteJoinStatus.success) {
      return _InviteJoinSuccess(
        host: host,
        communityName: derivedName,
        hasFocusChannel: state.focusChannelId != null,
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(
          Grid.sm,
          0,
          Grid.sm,
          Grid.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(BuzzIcons.userPlus, size: 40, color: context.colors.primary),
            const SizedBox(height: Grid.sm),
            Text(
              isStarterSetupRecovery
                  ? 'Finish setting up'
                  : tl('Join this Buzz community?'),
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: Grid.xxs),
            Text(
              tl('Check the relay host before you join:'),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Grid.xs),
            Container(
              padding: const EdgeInsets.all(Grid.twelve),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest.withValues(
                  alpha: 0.7,
                ),
                borderRadius: BorderRadius.circular(Radii.container),
                border: Border.all(color: context.colors.outlineVariant),
              ),
              child: Text(
                host,
                style: context.textTheme.titleMedium?.copyWith(
                  fontFamily: 'GeistMono',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (derivedName != null && derivedName != host) ...[
              const SizedBox(height: Grid.xxs),
              Text(
                tlt('Display name: {0}', [derivedName]),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: Grid.sm),
            if (isStarterSetupRecovery) ...[
              Text(
                tl(
                  'Your membership is ready, but starter channels still need to be set up. You can safely retry without claiming the invite again.',
                ),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Grid.sm),
            ],
            Text(
              tl(
                'This phone is the only copy of this identity. If you lose it before pairing or backing up, you’ll lose access as this member.',
              ),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            if (state.status == InviteJoinStatus.error &&
                state.errorMessage != null) ...[
              const SizedBox(height: Grid.sm),
              Text(
                state.errorMessage!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ],
            const SizedBox(height: Grid.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isClaiming
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(tl('Cancel')),
                  ),
                ),
                const SizedBox(width: Grid.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isClaiming || state.requiresFreshInvite
                        ? null
                        : () async => ref
                              .read(inviteJoinProvider.notifier)
                              .confirmJoin(),
                    icon: isClaiming
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: BuzzLoadingIndicator(
                              size: 16,
                              semanticLabel: isStarterSetupRecovery
                                  ? tl('Finishing setup')
                                  : tl('Joining community'),
                            ),
                          )
                        : const Icon(BuzzIcons.check),
                    label: Text(primaryLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteJoinSuccess extends StatelessWidget {
  final String host;
  final String? communityName;
  final bool hasFocusChannel;

  const _InviteJoinSuccess({
    required this.host,
    required this.hasFocusChannel,
    this.communityName,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          Grid.sm,
          0,
          Grid.sm,
          Grid.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              BuzzIcons.circleCheck,
              size: 40,
              color: context.colors.primary,
            ),
            const SizedBox(height: Grid.sm),
            Text(
              tlt('You joined {0}', [communityName ?? host]),
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: Grid.xs),
            Text(
              tl(
                'This phone is the only copy of this identity. If you lose it before pairing or backing up, you’ll lose access as this member.',
              ),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Grid.lg),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PairingPage(addingCommunity: true),
                  ),
                );
              },
              icon: const Icon(BuzzIcons.scanLine),
              label: Text(tl('Back it up now')),
            ),
            const SizedBox(height: Grid.xs),
            TextButton(
              onPressed: () => Navigator.of(context).pop(hasFocusChannel),
              child: Text(
                hasFocusChannel
                    ? tl('Continue to #welcome-everyone')
                    : tl('Not now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
