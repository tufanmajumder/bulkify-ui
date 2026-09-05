import 'package:get/get.dart';

import 'package:bulkify/app/modules/auth_module/otp_validation/controllers/otp_validation_controller.dart';

class OtpValidationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpValidationController>(
      () => OtpValidationController(),
    );
  }
}
