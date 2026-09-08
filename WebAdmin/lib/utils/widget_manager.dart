import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'color_manager.dart';

class WidgetManager {
  /// Formats snackbar text to sentence case where only the first letter is capitalized,
  /// preserving acronyms like OTP.
  ///
  String convertData(String phone, String deviceId, String model, String brand) {
    // 1. Define your source Map
    final Map<String, dynamic> deviceData = {
      "devicetype": phone,
      "deviceid": deviceId,
      "model": model,
      "brand": brand,
    };

    // 2. Format the Map into a pretty-printed JSON string with 2 spaces
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String prettyJsonString = encoder.convert(deviceData);

    // 3. Convert the string to bytes (UTF-8)
    final List<int> jsonBytes = utf8.encode(prettyJsonString);

    // 4. Encode the bytes to Base64
    final String base64Result = base64.encode(jsonBytes);

    return base64Result;
  }

  static String formatSnackbarText(String input) {
    if (input.trim().isEmpty) return input;

    final words = input.split(' ');
    final StringBuffer result = StringBuffer();
    bool capitalizeNext = true;

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.isEmpty) {
        result.write(' ');
        continue;
      }

      final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '');
      if (cleanWord == 'OTP') {
        result.write(word);
        capitalizeNext = false;
      } else if (capitalizeNext) {
        if (word.length == 1) {
          result.write(word.toUpperCase());
        } else {
          result.write(word[0].toUpperCase() + word.substring(1).toLowerCase());
        }
        capitalizeNext = false;
      } else {
        result.write(word.toLowerCase());
      }

      if (word.endsWith('.') || word.endsWith('!') || word.endsWith('?')) {
        capitalizeNext = true;
      }

      if (i < words.length - 1) {
        result.write(' ');
      }
    }

    return result.toString();
  }

  /// Custom Reusable Snackbar widget/function callable by passing properties.
  static void showSnackBar({
    required String message,
    SnackPosition snackPosition = SnackPosition.TOP,
    Color? backgroundColor,
    Color textColor = Colors.white,
    IconData? icon,
    Duration duration = const Duration(seconds: 5),
    EdgeInsets margin = const EdgeInsets.all(16),
    double borderRadius = 12,
    OnTap? onTap,
    TextButton? mainButton,
  }) {
    final effectiveBg = backgroundColor ?? const Color(0xFF28283C);
    final int argb = effectiveBg.toARGB32();
    final int red = (argb >> 16) & 0xFF;
    final int green = (argb >> 8) & 0xFF;
    final int blue = argb & 0xFF;

    final bool isRed =
        effectiveBg == Colors.redAccent ||
        effectiveBg == Colors.red ||
        effectiveBg == ColorManager.red ||
        effectiveBg == ColorManager.primaryRed ||
        effectiveBg == ColorManager.error ||
        argb == Colors.redAccent.toARGB32() ||
        argb == Colors.red.toARGB32() ||
        argb == ColorManager.red.toARGB32() ||
        argb == ColorManager.primaryRed.toARGB32() ||
        argb == ColorManager.error.toARGB32() ||
        (red > 150 && red > green * 1.3 && red > blue * 1.3);

    final bool isGreen =
        effectiveBg == Colors.green ||
        effectiveBg == Colors.greenAccent ||
        effectiveBg == ColorManager.success ||
        argb == const Color(0xFF2E7D32).toARGB32() ||
        argb == const Color(0xFF4CAF50).toARGB32() ||
        argb == Colors.green.toARGB32() ||
        argb == Colors.greenAccent.toARGB32() ||
        argb == ColorManager.success.toARGB32() ||
        (green > 90 && green > red * 1.1 && green > blue * 1.1);

    final bool isOrange =
        effectiveBg == Colors.orangeAccent ||
        effectiveBg == Colors.orange ||
        effectiveBg == Colors.amber ||
        effectiveBg == Colors.amberAccent ||
        effectiveBg == ColorManager.warning ||
        effectiveBg == ColorManager.warningLight ||
        effectiveBg == ColorManager.avatarOrange ||
        argb == Colors.orangeAccent.toARGB32() ||
        argb == Colors.orange.toARGB32() ||
        argb == Colors.amber.toARGB32() ||
        argb == Colors.amberAccent.toARGB32() ||
        argb == ColorManager.warning.toARGB32() ||
        argb == ColorManager.avatarOrange.toARGB32() ||
        (red > 160 && green > 70 && green < red && blue < 140);

    final effectiveIcon =
        icon ??
        (isRed
            ? Icons.close_rounded
            : isGreen
            ? Icons.check_rounded
            : isOrange
            ? Icons.priority_high
            : Icons.info_outline_rounded);

    final iconWidget = GestureDetector(
      onTap: () {
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
      },
      child: Container(
        width: 26,
        height: 26,
        margin: const EdgeInsets.only(right: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Icon(effectiveIcon, color: textColor, size: 16),
      ),
    );

    final String formattedMessage = formatSnackbarText(message);

    final EdgeInsets effectiveMargin = snackPosition == SnackPosition.TOP
        ? EdgeInsets.only(
            top: 4,
            left: margin.left,
            right: margin.right,
            bottom: margin.bottom > 8 ? 8 : margin.bottom,
          )
        : margin;

    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget,
          Expanded(
            child: Text(
              formattedMessage,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: textColor,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      snackPosition: snackPosition,
      backgroundColor: effectiveBg,
      duration: duration,
      margin: effectiveMargin,
      borderRadius: borderRadius,
      onTap: onTap,
      mainButton: mainButton,
    );
  }

  /// Helper alert snackbar method for showing quick alerts/errors.
  static void showAlertSnackBar(String message, [int durationSeconds = 5]) {
    showSnackBar(
      message: message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      icon: Icons.close_rounded,
      duration: Duration(seconds: durationSeconds),
    );
  }

  /// Helper warning snackbar method for showing warning notifications.
  static void showWarningSnackBar(String message, [int durationSeconds = 5]) {
    showSnackBar(
      message: message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orangeAccent,
      textColor: Colors.white,
      icon: Icons.priority_high,
      duration: Duration(seconds: durationSeconds),
    );
  }

  /// Helper success snackbar method for showing quick success notifications.
  static void showSuccessSnackBar(String message, [int durationSeconds = 5]) {
    showSnackBar(
      message: message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF2E7D32),
      textColor: Colors.white,
      icon: Icons.check_rounded,
      duration: Duration(seconds: durationSeconds),
    );
  }

  /// Reusable & Custom Dynamic Text Widget using Poppins font across the entire app.
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
      style: TextStyle(
        fontFamily: fontName,
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
    final colors =
        gradientColors ?? const [ColorManager.red, Color(0xFFE54B42)];

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
            ? Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child:
                child ??
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
