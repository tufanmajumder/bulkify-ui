import 'package:flutter/foundation.dart';
import 'package:bulkify/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkSessionAndNavigate();
  }

  /// Checks if 'sessionId' exists in SharedPreferences.
  /// If present & non-empty (or on Web) -> Go to HOME.
  /// Otherwise -> Go to LOGIN.
  void _checkSessionAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    try {
      if (kIsWeb) {
        print("Running on Web. Navigating directly to Home...");
        Get.offAllNamed(Routes.HOME);
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      final String? sessionId = prefs.getString('sessionId');

      if (sessionId != null && sessionId.trim().isNotEmpty) {
        print("Session ID found ($sessionId). Navigating to Home...");
        Get.offAllNamed(Routes.HOME);
      } else {
        print("No Session ID found. Navigating to Login...");
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      print("Error checking session in SplashController: $e");
      Get.offAllNamed(kIsWeb ? Routes.HOME : Routes.LOGIN);
    }
  }
}
