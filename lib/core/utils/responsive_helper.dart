import 'package:flutter/material.dart';

/// Responsive design helper for multi-screen support
/// Breakpoints:
/// - Phone: < 600px
/// - Tablet (Portrait): 600px - 1000px
/// - Tablet (Landscape): 1000px - 1200px
/// - Desktop: 1200px - 1920px
/// - Large Desktop: >= 1920px
class ResponsiveHelper {
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 1000;
  static const double desktopMaxWidth = 1200;
  static const double largeDesktopMaxWidth = 1920;

  /// Get the current device type based on screen width
  static DeviceType getDeviceType(double width) {
    if (width < phoneMaxWidth) {
      return DeviceType.phone;
    } else if (width < tabletMaxWidth) {
      return DeviceType.tabletPortrait;
    } else if (width < desktopMaxWidth) {
      return DeviceType.tabletLandscape;
    } else if (width < largeDesktopMaxWidth) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  /// Get device type from BuildContext
  static DeviceType getDeviceTypeFromContext(BuildContext context) {
    return getDeviceType(MediaQuery.of(context).size.width);
  }

  /// Check if device is phone
  static bool isPhone(BuildContext context) {
    return getDeviceTypeFromContext(context) == DeviceType.phone;
  }

  /// Check if device is tablet (any orientation)
  static bool isTablet(BuildContext context) {
    final type = getDeviceTypeFromContext(context);
    return type == DeviceType.tabletPortrait || type == DeviceType.tabletLandscape;
  }

  /// Check if device is desktop or larger
  static bool isDesktop(BuildContext context) {
    final type = getDeviceTypeFromContext(context);
    return type.index >= DeviceType.desktop.index;
  }

  /// Check if device supports side-by-side layout (width >= 1200px)
  static bool supportsWideLayout(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopMaxWidth;
  }

  /// Get responsive padding based on device type
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < phoneMaxWidth) {
      return const EdgeInsets.all(12);
    } else if (width < desktopMaxWidth) {
      return const EdgeInsets.all(16);
    } else if (width < largeDesktopMaxWidth) {
      return const EdgeInsets.all(20);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Get responsive spacing based on device type
  static double getResponsiveSpacing(BuildContext context, {
    required double phoneValue,
    required double tabletValue,
    required double desktopValue,
    required double largeDesktopValue,
  }) {
    final type = getDeviceTypeFromContext(context);
    switch (type) {
      case DeviceType.phone:
        return phoneValue;
      case DeviceType.tabletPortrait:
      case DeviceType.tabletLandscape:
        return tabletValue;
      case DeviceType.desktop:
        return desktopValue;
      case DeviceType.largeDesktop:
        return largeDesktopValue;
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, {
    required double base,
    double phoneMultiplier = 0.9,
    double tabletMultiplier = 1.0,
    double desktopMultiplier = 1.1,
    double largeDesktopMultiplier = 1.2,
  }) {
    final type = getDeviceTypeFromContext(context);
    switch (type) {
      case DeviceType.phone:
        return base * phoneMultiplier;
      case DeviceType.tabletPortrait:
      case DeviceType.tabletLandscape:
        return base * tabletMultiplier;
      case DeviceType.desktop:
        return base * desktopMultiplier;
      case DeviceType.largeDesktop:
        return base * largeDesktopMultiplier;
    }
  }

  /// Get max width for content container
  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < desktopMaxWidth) {
      return width;
    } else if (width < largeDesktopMaxWidth) {
      return width * 0.95;
    } else {
      return 1800; // Fixed max for ultra-wide screens
    }
  }

  /// Build a responsive grid with appropriate spacing
  static int getGridColumns(BuildContext context) {
    final type = getDeviceTypeFromContext(context);
    switch (type) {
      case DeviceType.phone:
        return 1;
      case DeviceType.tabletPortrait:
        return 2;
      case DeviceType.tabletLandscape:
      case DeviceType.desktop:
        return 3;
      case DeviceType.largeDesktop:
        return 4;
    }
  }
}

/// Device type enum for clarity
enum DeviceType {
  phone,
  tabletPortrait,
  tabletLandscape,
  desktop,
  largeDesktop,
}

/// Extension for easier access to responsive values
extension ResponsiveContext on BuildContext {
  /// Get device type
  DeviceType get deviceType => ResponsiveHelper.getDeviceTypeFromContext(this);

  /// Check if phone
  bool get isPhone => ResponsiveHelper.isPhone(this);

  /// Check if tablet
  bool get isTablet => ResponsiveHelper.isTablet(this);

  /// Check if desktop or larger
  bool get isDesktop => ResponsiveHelper.isDesktop(this);

  /// Check if supports wide layout
  bool get supportsWideLayout => ResponsiveHelper.supportsWideLayout(this);

  /// Get responsive padding
  EdgeInsets get responsivePadding => ResponsiveHelper.getResponsivePadding(this);

  /// Get max content width
  double get maxContentWidth => ResponsiveHelper.getMaxContentWidth(this);

  /// Get grid columns
  int get gridColumns => ResponsiveHelper.getGridColumns(this);
}
