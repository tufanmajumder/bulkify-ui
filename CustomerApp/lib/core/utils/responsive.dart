import 'package:flutter/material.dart';

/// Responsive helper breakpoints and utilities for Android phones, iPhones,
/// Android tablets, and iPads (portrait & landscape).
class Responsive {
  /// Tablet threshold based on shortest side >= 600dp (standard across Android & iOS)
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  /// Small phone threshold (iPhone SE, smaller Android devices with width < 360dp or height < 680dp)
  static bool isSmallPhone(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 360 || size.height < 680;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Device width
  static double width(BuildContext context) => MediaQuery.of(context).size.width;

  /// Device height
  static double height(BuildContext context) => MediaQuery.of(context).size.height;

  /// Max content width constraint for tablets / wide screens
  static const double maxContentWidth = 540.0;
  static const double maxTabletWidth = 960.0;

  /// Dynamic scale factor between minimum and maximum bounds
  static double scale(BuildContext context, {required double phone, required double tablet}) {
    return isTablet(context) ? tablet : phone;
  }
}

/// Extension on BuildContext for quick and clean responsive queries
extension ResponsiveContext on BuildContext {
  bool get isTablet => Responsive.isTablet(this);
  bool get isSmallPhone => Responsive.isSmallPhone(this);
  bool get isLandscape => Responsive.isLandscape(this);
  double get screenWidth => Responsive.width(this);
  double get screenHeight => Responsive.height(this);
}

