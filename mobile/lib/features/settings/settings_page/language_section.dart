part of '../settings_page.dart';

/// Interface language picker. Persian also switches the layout to right to left.
class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(languageProvider);
    Widget row(AppLanguage language, String title) => AppListRow(
      key: ValueKey('language-${language.name}'),
      icon: LucideIcons.languages,
      title: title,
      trailing: selected == language
          ? Icon(LucideIcons.check, size: 18, color: context.colors.primary)
          : null,
      onTap: () => ref.read(languageProvider.notifier).setLanguage(language),
    );

    return AppListCard(
      label: tl('Language'),
      verticalPadding: Grid.twelve,
      children: [row(AppLanguage.en, 'English'), row(AppLanguage.fa, 'فارسی')],
    );
  }
}
