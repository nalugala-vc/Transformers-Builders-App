import 'package:flutter/material.dart';

/// Logical-pixel spacing, radii, and touch targets. Use these instead of magic numbers.
abstract final class AppSizes {
  AppSizes._();

  static const double s0 = 0;
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s36 = 36;
  static const double s40 = 40;
  static const double s44 = 44;
  static const double s48 = 48;
  static const double s56 = 56;
  static const double s64 = 64;
  static const double s72 = 72;
  static const double s80 = 80;
  static const double s96 = 96;

  /// Minimum tap target (Material guidance).
  static const double minTouchTarget = s48;

  /// Default horizontal page padding on larger layouts.
  static const double pagePaddingCompact = s16;
  static const double pagePaddingMedium = s24;
  static const double pagePaddingExpanded = s32;

  /// Scaled height / gap / icon size from a design baseline (logical px).
  static double h(BuildContext context, double base) => AppScaledSizes(context).h(base);

  /// Scaled font size from a design baseline. [Text] still applies system text scaling.
  static double f(BuildContext context, double base) => AppScaledSizes(context).f(base);
}

/// Width thresholds aligned with common Material window size classes.
abstract final class AppBreakpoints {
  AppBreakpoints._();

  /// Layouts narrower than this are treated as compact (phones, narrow panes).
  static const double compactMax = 600;

  /// Between [compactMax] and this: medium (tablets, small laptops).
  static const double mediumMax = 840;
}

enum AppLayoutSizeClass {
  compact,
  medium,
  expanded,
}

extension AppLayoutSizeClassContext on BuildContext {
  AppLayoutSizeClass get layoutSizeClass {
    final width = MediaQuery.sizeOf(this).width;
    if (width < AppBreakpoints.compactMax) return AppLayoutSizeClass.compact;
    if (width < AppBreakpoints.mediumMax) return AppLayoutSizeClass.medium;
    return AppLayoutSizeClass.expanded;
  }

  /// Horizontal padding that scales slightly with window width.
  double get responsivePagePadding {
    switch (layoutSizeClass) {
      case AppLayoutSizeClass.compact:
        return AppSizes.pagePaddingCompact;
      case AppLayoutSizeClass.medium:
        return AppSizes.pagePaddingMedium;
      case AppLayoutSizeClass.expanded:
        return AppSizes.pagePaddingExpanded;
    }
  }

  /// Returns a different value per [layoutSizeClass] — use with [AppSizes] for spacing, heights, widths, etc.
  ///
  /// If [medium] is omitted, medium layouts use [expanded] (closer to desktop than phone).
  T layoutValue<T>({
    required T compact,
    T? medium,
    required T expanded,
  }) {
    switch (layoutSizeClass) {
      case AppLayoutSizeClass.compact:
        return compact;
      case AppLayoutSizeClass.medium:
        return medium ?? expanded;
      case AppLayoutSizeClass.expanded:
        return expanded;
    }
  }
}

/// Layout-aware scaling (phone → tablet → wide). Use [BuildContext.scaled] for shorthand getters
/// (`h20`, `f16`, …) or [AppSizes.h] / [AppSizes.f] with a baseline.
final class AppScaledSizes {
  AppScaledSizes(this._context);

  final BuildContext _context;

  static double _heightScale(AppLayoutSizeClass layout) {
    return switch (layout) {
      AppLayoutSizeClass.compact => 1.0,
      AppLayoutSizeClass.medium => 1.08,
      AppLayoutSizeClass.expanded => 1.15,
    };
  }

  static double _fontScale(AppLayoutSizeClass layout) {
    return switch (layout) {
      AppLayoutSizeClass.compact => 1.0,
      AppLayoutSizeClass.medium => 1.06,
      AppLayoutSizeClass.expanded => 1.12,
    };
  }

  double get _hScale => _heightScale(_context.layoutSizeClass);
  double get _fScale => _fontScale(_context.layoutSizeClass);

  /// Vertical sizes (heights, gaps, square icons) — scales a bit more than [f].
  double h(double base) => base * _hScale;

  /// Typography baseline — slightly gentler than [h]. Do not pre-apply [TextScaler]; [Text] handles a11y.
  double f(double base) => base * _fScale;

  double get h0 => h(AppSizes.s0);
  double get h2 => h(AppSizes.s2);
  double get h4 => h(AppSizes.s4);
  double get h6 => h(AppSizes.s6);
  double get h8 => h(AppSizes.s8);
  double get h10 => h(AppSizes.s10);
  double get h12 => h(AppSizes.s12);
  double get h14 => h(AppSizes.s14);
  double get h16 => h(AppSizes.s16);
  double get h18 => h(AppSizes.s18);
  double get h20 => h(AppSizes.s20);
  double get h24 => h(AppSizes.s24);
  double get h28 => h(AppSizes.s28);
  double get h32 => h(AppSizes.s32);
  double get h36 => h(AppSizes.s36);
  double get h40 => h(AppSizes.s40);
  double get h44 => h(AppSizes.s44);
  double get h48 => h(AppSizes.s48);
  double get h56 => h(AppSizes.s56);
  double get h64 => h(AppSizes.s64);
  double get h72 => h(AppSizes.s72);
  double get h80 => h(AppSizes.s80);
  double get h96 => h(AppSizes.s96);

  double get f0 => f(AppSizes.s0);
  double get f2 => f(AppSizes.s2);
  double get f4 => f(AppSizes.s4);
  double get f6 => f(AppSizes.s6);
  double get f8 => f(AppSizes.s8);
  double get f10 => f(AppSizes.s10);
  double get f12 => f(AppSizes.s12);
  double get f14 => f(AppSizes.s14);
  double get f16 => f(AppSizes.s16);
  double get f18 => f(AppSizes.s18);
  double get f20 => f(AppSizes.s20);
  double get f24 => f(AppSizes.s24);
  double get f28 => f(AppSizes.s28);
  double get f32 => f(AppSizes.s32);
  double get f36 => f(AppSizes.s36);
  double get f40 => f(AppSizes.s40);
  double get f44 => f(AppSizes.s44);
  double get f48 => f(AppSizes.s48);
  double get f56 => f(AppSizes.s56);
  double get f64 => f(AppSizes.s64);
  double get f72 => f(AppSizes.s72);
  double get f80 => f(AppSizes.s80);
  double get f96 => f(AppSizes.s96);
}

extension AppScaledSizesContext on BuildContext {
  /// Shorthand: `context.scaled.h20`, `context.scaled.f16`, or `scaled.h(AppSizes.s20)`.
  AppScaledSizes get scaled => AppScaledSizes(this);
}
