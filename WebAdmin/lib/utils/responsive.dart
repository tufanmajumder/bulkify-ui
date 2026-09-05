import 'package:flutter/material.dart';

class Responsive {
  /// Returns width as a percentage of screen width (0 to 100)
  static double w(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * (percent / 100);
  }

  /// Returns height as a percentage of screen height (0 to 100)
  static double h(BuildContext context, double percent) {
    return MediaQuery.of(context).size.height * (percent / 100);
  }

  /// Returns dynamically scaled font size bounded within min/max factors
  static double sp(BuildContext context, double baseFontSize) {
    final width = MediaQuery.of(context).size.width;
    double scaleFactor = width / 1200.0;
    if (scaleFactor < 0.85) scaleFactor = 0.85;
    if (scaleFactor > 1.25) scaleFactor = 1.25;
    return baseFontSize * scaleFactor;
  }

  /// Breakpoint helpers
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width <= 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 1024;

  /// Dynamic horizontal padding based on screen width
  static double dynamicPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 12.0;
    if (width < 1024) return 20.0;
    return (width * 0.02).clamp(20.0, 36.0);
  }

  /// Dynamic gap/spacing height
  static double dynamicSpacing(BuildContext context, double baseSpacing) {
    final height = MediaQuery.of(context).size.height;
    double factor = (height / 800.0).clamp(0.8, 1.3);
    return baseSpacing * factor;
  }
}
