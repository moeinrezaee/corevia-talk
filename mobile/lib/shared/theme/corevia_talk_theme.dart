import 'package:flutter/material.dart';

import 'accent_colors.dart';
import 'app_colors.dart';
import 'theme_extensions.dart';

/// Name of the first-party Corevia Talk theme. Corevia Talk reuses the GitHub Light palette for
/// every base color; the one thing that sets it apart is a branded gradient
/// painted across the app's top section. Mirrors desktop, where the same
/// gradient fills the sidebar canvas — see `data-corevia-talk-sidebar` in
/// `desktop/src/shared/styles/globals/theme.css`.
const coreviaTalkThemeName = 'corevia-talk';

/// Name of the dark counterpart, which reuses the GitHub Dark palette and the
/// dark-tuned gradient stops. Paired with [coreviaTalkThemeName] in `themePairs`, so
/// the two behave as a single "Corevia Talk" choice under System mode.
const coreviaTalkDarkThemeName = 'corevia-talk-dark';

/// Whether [themeName] is either half of the Corevia Talk pair. Both halves enable the
/// gradient so System mode keeps it on across an OS light/dark switch.
bool isCoreviaTalkTheme(String themeName) =>
    themeName == coreviaTalkThemeName || themeName == coreviaTalkDarkThemeName;

/// Whether the current widget tree is using the first-party Corevia Talk treatment.
bool isCoreviaTalkThemeContext(BuildContext context) =>
    Theme.of(context).extension<AppColors>()?.topSectionGradient != null;

/// Primary foreground for the mobile top navigation.
///
/// Every theme uses its own [ColorScheme.onSurface]. Corevia Talk is the exception:
/// its desktop-matching top gradient needs a neutral black or white foreground
/// rather than the accent-derived color scheme foreground.
Color navigationPrimaryForeground(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  if (!isCoreviaTalkThemeContext(context)) return scheme.onSurface;
  return scheme.brightness == Brightness.dark ? Colors.white : Colors.black;
}

/// Secondary label and placeholder foreground for the mobile top navigation.
Color navigationSecondaryForeground(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  if (!isCoreviaTalkThemeContext(context)) return scheme.onSurfaceVariant;
  return navigationPrimaryForeground(context).withValues(alpha: 0.4);
}

/// Channel-section label and icon foreground for the mobile side navigation.
///
/// Section labels need more hierarchy than a placeholder. Corevia Talk therefore uses
/// a stronger neutral over its gradient, while all other themes preserve their
/// established secondary foreground token.
Color navigationSectionForeground(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  if (!isCoreviaTalkThemeContext(context)) return scheme.onSurfaceVariant;
  return navigationPrimaryForeground(context).withValues(alpha: 0.8);
}

/// Search-field surface for the mobile top navigation.
Color navigationSearchSurface(BuildContext context) {
  return context.controlSurface;
}

/// A low-contrast navigation divider derived from the active theme foreground.
Color navigationDivider(BuildContext context, double opacity) =>
    navigationPrimaryForeground(context).withValues(alpha: opacity);

/// Corevia Talk renders with its fixed neutral foreground while preserving the stored
/// wire accent so the user's choice returns on another theme.
int effectiveAccentIndex(String themeName, String storedAccent) {
  if (isCoreviaTalkTheme(themeName)) return neutralAccentIndex;
  return accentIndexForWireValue(storedAccent) ?? defaultAccentIndex;
}

/// Gradient stops, matching desktop's `--corevia-talk-gradient-*` custom properties.
const _lightTop = Color(0xFFE6E6B6);
const _lightBottom = Color(0xFFC4D0DA);
const _darkTop = Color(0xFF4A4616);
const _darkBottom = Color(0xFF0A1423);

/// The Corevia Talk gradient for the app's top section, or null when [themeName] is not
/// a Corevia Talk theme — in which case the section keeps its default frosted fill.
///
/// The stops are fully opaque: under Corevia Talk the color replaces the frosted
/// treatment rather than tinting it, matching desktop's solid sidebar canvas.
///
/// [brightness] comes from the applied color scheme rather than the theme name,
/// so System mode picks the right stops as the OS switches.
LinearGradient? coreviaTalkTopSectionGradient(
  String themeName,
  Brightness brightness,
) {
  if (!isCoreviaTalkTheme(themeName)) return null;

  final isDark = brightness == Brightness.dark;
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      isDark ? _darkTop : _lightTop,
      isDark ? _darkBottom : _lightBottom,
    ],
  );
}

/// Desktop navigation ink distinguishes read destinations from unread labels.
Color channelNavigationForeground(BuildContext context, {bool unread = false}) {
  if (unread || Theme.of(context).brightness != Brightness.dark) {
    return navigationPrimaryForeground(context);
  }
  return Theme.of(context).colorScheme.onSurfaceVariant;
}

/// Metadata ink used by Home section headings and muted destinations.
Color navigationMetadataForeground(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFFA4A4A4)
    : const Color(0xFF5F5F5F);
