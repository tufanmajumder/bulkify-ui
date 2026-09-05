import 'package:get/get.dart';

import '../controllers/otp_validation_controller.dart';

class OtpValidationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpValidationController>(
      () => OtpValidationController(),
    );
  }
}
