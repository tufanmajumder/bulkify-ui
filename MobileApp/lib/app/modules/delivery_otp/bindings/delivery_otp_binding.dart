import 'package:get/get.dart';
import 'package:bulkify/app/modules/delivery_otp/controllers/delivery_otp_controller.dart';

class DeliveryOtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryOtpController>(
      () => DeliveryOtpController(),
    );
  }
}
