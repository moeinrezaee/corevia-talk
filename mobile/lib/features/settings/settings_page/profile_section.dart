part of '../settings_page.dart';

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.profileEditPageBuilder,
    this.onEditDisplayName,
    this.onEditProfileDescription,
  });

  final WidgetBuilder profileEditPageBuilder;
  final Future<void> Function(BuildContext context)? onEditDisplayName;
  final Future<void> Function(BuildContext context)? onEditProfileDescription;

  @override
  Widget build(BuildContext context) => AppListCard(
    key: const ValueKey('edit-profile-options'),
    dividerIndent: Grid.xs,
    verticalPadding: Grid.twelve,
    children: [
      AppListRow(
        key: const ValueKey('edit-profile-display-name'),
        title: tl('Display name'),
        trailing: const _RowChevron(),
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          unawaited(onEditDisplayName?.call(context));
        },
      ),
      AppListRow(
        key: const ValueKey('edit-profile-description'),
        title: tl('Profile description'),
        trailing: const _RowChevron(),
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          unawaited(onEditProfileDescription?.call(context));
        },
      ),
      AppListRow(
        key: const ValueKey('edit-profile-photo'),
        title: tl('Edit photo'),
        trailing: const _RowChevron(),
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          Navigator.of(
            context,
          ).push(immediatePageRoute<void>(builder: profileEditPageBuilder));
        },
      ),
    ],
  );
}
