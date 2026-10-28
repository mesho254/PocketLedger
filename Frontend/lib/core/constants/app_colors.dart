import 'package:flutter/material.dart';

class AppColors {
  // Novbank & Modern Fintech Brand Accents
  static const Color primary = Color(0xFF0A5C6B); // Novbank Deep Oceanic Teal
  static const Color primaryLight = Color(0xFF14B8A6); // Luminous Teal-Mint
  static const Color primaryDark = Color(0xFF07434E);

  static const Color accentTeal = Color(0xFF0D8A9E); // Checking / Overview Teal
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentAmber = Color(0xFFF58A07); // Novbank Warm Amber
  static const Color accentRose = Color(0xFFF43F5E);

  // Financial Semantics
  static const Color income = Color(0xFF00C46A); // Novbank Vibrant Green
  static const Color expense = Color(0xFFF43F5E);
  static const Color savings = Color(0xFF0D8A9E);

  // Light Theme Palette ("Novbank Editorial Alabaster")
  static const Color backgroundLight = Color(0xFFF2F4F7);
  static const Color surfaceLight = Color(0xFFF6F8FA);
  static const Color surfaceCardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE6EAF0);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Dark Theme Palette ("Obsidian & Luminous Teal")
  static const Color backgroundDark = Color(0xFF090D16);
  static const Color surfaceDark = Color(0xFF1A2234);
  static const Color surfaceCardDark = Color(0xFF131926);
  static const Color borderDark = Color(0xFF232D42);

  // Text Colors (Dark)
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Status Alerts
  static const Color statusSafe = Color(0xFF00C46A);
  static const Color statusWarning = Color(0xFFF58A07);
  static const Color statusExceeded = Color(0xFFEF4444);
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final bool isDark;
  final Color scaffoldBg;
  final Color cardSurface;
  final Color nestedSurface;
  final Color iconBoxSurface;
  final Color borderSubtle;
  final Color primaryBrand;
  final Color secondaryTeal;
  final Color badgeBg;
  final Color badgeText;
  final Color incomeGreen;
  final Color warningAmber;
  final Color expenseRose;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color dockBackground;
  final Color dockActivePill;
  final Color dockActiveIcon;
  final Color dockInactiveIcon;
  final Color progressTrack;
  final Color tooltipBg;

  const AppPalette({
    required this.isDark,
    required this.scaffoldBg,
    required this.cardSurface,
    required this.nestedSurface,
    required this.iconBoxSurface,
    required this.borderSubtle,
    required this.primaryBrand,
    required this.secondaryTeal,
    required this.badgeBg,
    required this.badgeText,
    required this.incomeGreen,
    required this.warningAmber,
    required this.expenseRose,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.dockBackground,
    required this.dockActivePill,
    required this.dockActiveIcon,
    required this.dockInactiveIcon,
    required this.progressTrack,
    required this.tooltipBg,
  });

  static const AppPalette light = AppPalette(
    isDark: false,
    scaffoldBg: Color(0xFFF2F4F7),
    cardSurface: Color(0xFFFFFFFF),
    nestedSurface: Color(0xFFF6F8FA),
    iconBoxSurface: Color(0xFFFFFFFF),
    borderSubtle: Color(0xFFE6EAF0),
    primaryBrand: Color(0xFF0A5C6B),
    secondaryTeal: Color(0xFF0D8A9E),
    badgeBg: Color(0xFFE6F4F6),
    badgeText: Color(0xFF0A6C7C),
    incomeGreen: Color(0xFF00C46A),
    warningAmber: Color(0xFFF58A07),
    expenseRose: Color(0xFFF43F5E),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF64748B),
    textMuted: Color(0xFF94A3B8),
    dockBackground: Color(0xDF525860),
    dockActivePill: Color(0xFFFFFFFF),
    dockActiveIcon: Color(0xFF0A5C6B),
    dockInactiveIcon: Color(0xFFE2E8F0),
    progressTrack: Color(0xFFE6EEF0),
    tooltipBg: Color(0xFF095260),
  );

  static const AppPalette dark = AppPalette(
    isDark: true,
    scaffoldBg: Color(0xFF090D16),
    cardSurface: Color(0xFF131926),
    nestedSurface: Color(0xFF1A2234),
    iconBoxSurface: Color(0xFF222C42),
    borderSubtle: Color(0xFF232D42),
    primaryBrand: Color(0xFF14B8A6),
    secondaryTeal: Color(0xFF06B6D4),
    badgeBg: Color(0xFF0F2E38),
    badgeText: Color(0xFF2DD4BF),
    incomeGreen: Color(0xFF10B981),
    warningAmber: Color(0xFFFBBF24),
    expenseRose: Color(0xFFFB7185),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    dockBackground: Color(0xE6182032),
    dockActivePill: Color(0xFF14B8A6),
    dockActiveIcon: Color(0xFF090D16),
    dockInactiveIcon: Color(0xFF94A3B8),
    progressTrack: Color(0xFF222C42),
    tooltipBg: Color(0xFF0D8A9E),
  );

  List<BoxShadow> get cardShadow => isDark
      ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ]
      : [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ];

  @override
  AppPalette copyWith({
    bool? isDark,
    Color? scaffoldBg,
    Color? cardSurface,
    Color? nestedSurface,
    Color? iconBoxSurface,
    Color? borderSubtle,
    Color? primaryBrand,
    Color? secondaryTeal,
    Color? badgeBg,
    Color? badgeText,
    Color? incomeGreen,
    Color? warningAmber,
    Color? expenseRose,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? dockBackground,
    Color? dockActivePill,
    Color? dockActiveIcon,
    Color? dockInactiveIcon,
    Color? progressTrack,
    Color? tooltipBg,
  }) {
    return AppPalette(
      isDark: isDark ?? this.isDark,
      scaffoldBg: scaffoldBg ?? this.scaffoldBg,
      cardSurface: cardSurface ?? this.cardSurface,
      nestedSurface: nestedSurface ?? this.nestedSurface,
      iconBoxSurface: iconBoxSurface ?? this.iconBoxSurface,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      primaryBrand: primaryBrand ?? this.primaryBrand,
      secondaryTeal: secondaryTeal ?? this.secondaryTeal,
      badgeBg: badgeBg ?? this.badgeBg,
      badgeText: badgeText ?? this.badgeText,
      incomeGreen: incomeGreen ?? this.incomeGreen,
      warningAmber: warningAmber ?? this.warningAmber,
      expenseRose: expenseRose ?? this.expenseRose,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      dockBackground: dockBackground ?? this.dockBackground,
      dockActivePill: dockActivePill ?? this.dockActivePill,
      dockActiveIcon: dockActiveIcon ?? this.dockActiveIcon,
      dockInactiveIcon: dockInactiveIcon ?? this.dockInactiveIcon,
      progressTrack: progressTrack ?? this.progressTrack,
      tooltipBg: tooltipBg ?? this.tooltipBg,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      isDark: t < 0.5 ? isDark : other.isDark,
      scaffoldBg: Color.lerp(scaffoldBg, other.scaffoldBg, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      nestedSurface: Color.lerp(nestedSurface, other.nestedSurface, t)!,
      iconBoxSurface: Color.lerp(iconBoxSurface, other.iconBoxSurface, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      primaryBrand: Color.lerp(primaryBrand, other.primaryBrand, t)!,
      secondaryTeal: Color.lerp(secondaryTeal, other.secondaryTeal, t)!,
      badgeBg: Color.lerp(badgeBg, other.badgeBg, t)!,
      badgeText: Color.lerp(badgeText, other.badgeText, t)!,
      incomeGreen: Color.lerp(incomeGreen, other.incomeGreen, t)!,
      warningAmber: Color.lerp(warningAmber, other.warningAmber, t)!,
      expenseRose: Color.lerp(expenseRose, other.expenseRose, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      dockBackground: Color.lerp(dockBackground, other.dockBackground, t)!,
      dockActivePill: Color.lerp(dockActivePill, other.dockActivePill, t)!,
      dockActiveIcon: Color.lerp(dockActiveIcon, other.dockActiveIcon, t)!,
      dockInactiveIcon: Color.lerp(dockInactiveIcon, other.dockInactiveIcon, t)!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      tooltipBg: Color.lerp(tooltipBg, other.tooltipBg, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
