import 'package:flutter/material.dart';

/// Shared radii, spacing, and elevation, exposed as a theme extension so
/// the future component kit (VS-3) can read one consistent source via
/// `Theme.of(context)` instead of mixing static-class imports.
///
/// Values mirror the existing `AppBorders`/`AppSpacing` constants in
/// `app_theme.dart`; they do not vary by brightness today, but living in
/// the theme keeps them swappable and testable alongside the other
/// semantic extensions.
@immutable
class ShapeTokens extends ThemeExtension<ShapeTokens> {
  const ShapeTokens({
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.radiusPill,
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    required this.spaceXxl,
    required this.elevationLow,
    required this.elevationMedium,
    required this.elevationHigh,
  });

  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double radiusPill;

  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;
  final double spaceXxl;

  final double elevationLow;
  final double elevationMedium;
  final double elevationHigh;

  BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  BorderRadius get borderRadiusPill => BorderRadius.circular(radiusPill);

  static const standard = ShapeTokens(
    radiusSm: 8.0,
    radiusMd: 12.0,
    radiusLg: 24.0,
    radiusXl: 32.0,
    radiusPill: 50.0,
    spaceXs: 4.0,
    spaceSm: 8.0,
    spaceMd: 16.0,
    spaceLg: 24.0,
    spaceXl: 32.0,
    spaceXxl: 48.0,
    elevationLow: 2.0,
    elevationMedium: 6.0,
    elevationHigh: 12.0,
  );

  @override
  ShapeTokens copyWith({
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? radiusPill,
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? spaceXxl,
    double? elevationLow,
    double? elevationMedium,
    double? elevationHigh,
  }) {
    return ShapeTokens(
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      radiusPill: radiusPill ?? this.radiusPill,
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      spaceXxl: spaceXxl ?? this.spaceXxl,
      elevationLow: elevationLow ?? this.elevationLow,
      elevationMedium: elevationMedium ?? this.elevationMedium,
      elevationHigh: elevationHigh ?? this.elevationHigh,
    );
  }

  @override
  ShapeTokens lerp(ThemeExtension<ShapeTokens>? other, double t) {
    if (other is! ShapeTokens) return this;
    double d(double a, double b) => a + (b - a) * t;
    return ShapeTokens(
      radiusSm: d(radiusSm, other.radiusSm),
      radiusMd: d(radiusMd, other.radiusMd),
      radiusLg: d(radiusLg, other.radiusLg),
      radiusXl: d(radiusXl, other.radiusXl),
      radiusPill: d(radiusPill, other.radiusPill),
      spaceXs: d(spaceXs, other.spaceXs),
      spaceSm: d(spaceSm, other.spaceSm),
      spaceMd: d(spaceMd, other.spaceMd),
      spaceLg: d(spaceLg, other.spaceLg),
      spaceXl: d(spaceXl, other.spaceXl),
      spaceXxl: d(spaceXxl, other.spaceXxl),
      elevationLow: d(elevationLow, other.elevationLow),
      elevationMedium: d(elevationMedium, other.elevationMedium),
      elevationHigh: d(elevationHigh, other.elevationHigh),
    );
  }
}

extension ShapeTokensContext on BuildContext {
  /// Shorthand for the current theme's [ShapeTokens].
  ShapeTokens get shapeTokens =>
      Theme.of(this).extension<ShapeTokens>() ?? ShapeTokens.standard;
}
