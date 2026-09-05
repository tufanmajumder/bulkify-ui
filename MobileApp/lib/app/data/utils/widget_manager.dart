import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_manager.dart';

class WidgetManager {
  /// Custom Reusable Snackbar widget/function callable by passing properties.
  static void showSnackBar({
    required String title,
    required String message,
    SnackPosition snackPosition = SnackPosition.TOP,
    Color? backgroundColor,
    Color textColor = Colors.white,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    EdgeInsets margin = const EdgeInsets.all(16),
    double borderRadius = 12,
    OnTap? onTap,
    TextButton? mainButton,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: snackPosition,
      backgroundColor: backgroundColor ?? const Color(0xFF28283C),
      colorText: textColor,
      icon: icon != null ? Icon(icon, color: textColor) : null,
      duration: duration,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      mainButton: mainButton,
    );
  }

  /// Helper alert snackbar method for showing quick alerts/errors.
  static void showAlertSnackBar(String message, [int durationSeconds = 3]) {
    showSnackBar(
      title: 'Alert',
      message: message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      duration: Duration(seconds: durationSeconds),
    );
  }

  /// Reusable & Custom Dynamic Text Widget using GoogleFonts.poppins across the entire app.
  static Widget customText({
    required String text,
    String fontName = 'Poppins',
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? letterSpacing,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        decoration: decoration,
        decorationColor: decorationColor,
      ),
    );
  }

  /// Solid Red Button with Crisp White Border & White Icon/Text
  static Widget gradientButton({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    Widget? child,
    double? width,
    double? height,
    double borderRadius = 14.0,
    bool isEnabled = true,
    Color textColor = Colors.white,
    List<Color>? gradientColors,
    double elevation = 4.0,
  }) {
    final colors = gradientColors ?? const [
      ColorManager.red,
      Color(0xFFE54B42),
    ];

    return Container(
      width: width ?? double.infinity,
      height: height ?? 48.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: isEnabled
            ? LinearGradient(
                colors: colors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isEnabled ? null : const Color(0xFFDCDCE6),
        border: isEnabled
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.2,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: child ??
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: textColor),
                      const SizedBox(width: 8),
                    ],
                    customText(
                      text: text,
                      fontName: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: 0.4,
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}
