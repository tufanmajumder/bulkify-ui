import 'package:bulkify/app/data/utils/asset_manager.dart';
import 'package:bulkify/app/data/utils/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bulkify/app/modules/auth_module/splash/controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    controller;

    return Scaffold(
      backgroundColor: ColorManager.red,
      body: SafeArea(
        child: Container(
          height: Get.height,
          width: Get.width,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                SizedBox(
                  width: Get.width,
                  height: Get.height * 0.16,
                  child: Image.asset(AssetManager.splashLogo1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
