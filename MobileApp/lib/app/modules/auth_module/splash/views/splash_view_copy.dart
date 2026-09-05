import 'package:bulkify/app/data/utils/asset_manager.dart';
import 'package:bulkify/app/data/utils/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:bulkify/app/modules/auth_module/splash/controllers/splash_controller.dart';

class SplashViewCopy extends GetView<SplashController> {
  const SplashViewCopy({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    controller;

    return Scaffold(
      backgroundColor: ColorManager.cardBg,
      body: SafeArea(
        child: Container(
          height: Get.height,
          width: Get.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorManager.cardBg,
                ColorManager.red.withValues(alpha: 0.32),
              ],
              stops: const [0.27, 1.8],
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(
                left: Get.width * 0.16,
                right: Get.width * 0.16,
              ),
              child: Image.asset(AssetManager.splashLogo2Png),
              // For vector SVG use: SvgPicture.asset(AssetManager.splashLogo),
            ),
          ),
        ),
      ),
    );
  }
}
