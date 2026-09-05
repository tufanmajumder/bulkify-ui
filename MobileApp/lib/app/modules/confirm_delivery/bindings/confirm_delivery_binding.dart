import 'package:get/get.dart';
import 'package:bulkify/app/modules/confirm_delivery/controllers/confirm_delivery_controller.dart';

class ConfirmDeliveryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConfirmDeliveryController>(
      () => ConfirmDeliveryController(),
    );
  }
}
