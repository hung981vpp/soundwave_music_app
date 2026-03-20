import 'package:flutter/material.dart';

/// Centralised theme-aware colour palette.
/// Call [AppColors.of(context)] to get an instance.
class AppColors {
  final bool isDark;

  const AppColors._(this.isDark);

  static AppColors of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AppColors._(brightness == Brightness.dark);
  }

  // ── Backgrounds ────────────────────────────────────────────────────────────
  /// Main scaffold background  (darkest level)
  Color get bg => isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF2F2F2);

  /// Card / surface level 1
  Color get surface1 => isDark ? const Color(0xFF1A1A1A) : Colors.white;

  /// Card / surface level 2
  Color get surface2 => isDark ? const Color(0xFF252525) : const Color(0xFFEEEEEE);

  /// Elevated surface / bottom sheets
  Color get surface3 => isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E5E5);

  /// Navigation bar background
  Color get navBg => isDark ? const Color(0xFF111111) : Colors.white;

  // ── Text ──────────────────────────────────────────────────────────────────
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF111111);
  Color get textSecondary => isDark ? Colors.white60 : Colors.black54;
  Color get textTertiary => isDark ? Colors.white38 : Colors.black38;
  Color get textDisabled => isDark ? Colors.white24 : Colors.black26;

  // ── Dividers / Icons ──────────────────────────────────────────────────────
  Color get divider => isDark ? Colors.white12 : Colors.black12;
  Color get iconSubtle => isDark ? Colors.white38 : Colors.black38;
  Color get iconMedium => isDark ? Colors.white54 : Colors.black54;

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color brand = Color(0xFFFF5500);
  static const Color brandLight = Color(0xFFFF7733);

  // ── Utility ───────────────────────────────────────────────────────────────
  /// Overlay over a blurred background
  Color get blurOverlay =>
      isDark ? Colors.black.withOpacity(0.55) : Colors.white.withOpacity(0.55);

  /// Subtle highlight fill (e.g. for search bar bg)
  Color get inputFill => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEAEAEA);

  /// Subtle border (e.g. for cards)
  Color get subtleBorder =>
      isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08);
}
