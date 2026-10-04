/// IndiRun V1 spacing, radius, and sizing tokens.
///
/// All values are multiples of 4dp (the base grid unit).
/// Do NOT use arbitrary padding/margin values in widgets — use these constants.
abstract final class AppDimensions {
  // ─────────────────────────────────────────────
  // 4dp spacing grid
  // ─────────────────────────────────────────────
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space36 = 36.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space64 = 64.0;
  static const double space72 = 72.0;
  static const double space80 = 80.0;

  // ─────────────────────────────────────────────
  // Screen layout
  // ─────────────────────────────────────────────
  /// Standard horizontal screen padding
  static const double screenPadding = 16.0;

  /// Wider padding for sections with breathing room
  static const double screenPaddingWide = 24.0;

  // ─────────────────────────────────────────────
  // Component padding
  // ─────────────────────────────────────────────
  /// Card inner padding
  static const double cardPadding = 12.0;

  /// Card inner padding (generous)
  static const double cardPaddingLarge = 16.0;

  /// Chip horizontal padding
  static const double chipPaddingH = 12.0;

  /// Chip vertical padding
  static const double chipPaddingV = 6.0;

  /// Bottom sheet handle area
  static const double bottomSheetTopPadding = 12.0;

  // ─────────────────────────────────────────────
  // Touch targets & button heights
  // ─────────────────────────────────────────────
  /// WCAG minimum touch target (also: icon buttons)
  static const double minTouchTarget = 48.0;

  /// Standard button height
  static const double buttonHeight = 52.0;

  /// Large active-run action buttons (pause, stop, etc.)
  static const double runActionButtonSize = 56.0;

  /// Gap between active-run buttons
  static const double runActionButtonGap = 12.0;

  // ─────────────────────────────────────────────
  // Card and tile heights
  // ─────────────────────────────────────────────
  /// Minimum height of a running metric stat tile
  static const double statTileMinHeight = 88.0;

  /// Run card height (history list)
  static const double runCardHeight = 80.0;

  /// Avatar size — default
  static const double avatarSize = 48.0;

  /// Avatar size — large (profile screen)
  static const double avatarSizeLarge = 80.0;

  // ─────────────────────────────────────────────
  // Corner radii
  // ─────────────────────────────────────────────
  static const double radiusXS = 4.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusCard = 16.0;
  static const double radiusModal = 28.0;
  static const double radiusPill = 999.0;

  // ─────────────────────────────────────────────
  // Borders
  // ─────────────────────────────────────────────
  static const double borderThin = 1.0;
  static const double borderMedium = 1.5;
  static const double borderThick = 2.0;

  // ─────────────────────────────────────────────
  // Elevation (Material 3)
  // ─────────────────────────────────────────────
  static const double elevationNone = 0.0;
  static const double elevationLow = 1.0;
  static const double elevationMedium = 3.0;
  static const double elevationHigh = 6.0;

  // ─────────────────────────────────────────────
  // Animation durations
  // ─────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);

  // ─────────────────────────────────────────────
  // Map
  // ─────────────────────────────────────────────
  static const double mapControlSize = 40.0;
  static const double mapGpsButtonSize = 40.0;
}
