import 'package:get/get.dart';

import 'package:bulkify/app/modules/auth_module/splash/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(
      SplashController(),
    );
  }
}
