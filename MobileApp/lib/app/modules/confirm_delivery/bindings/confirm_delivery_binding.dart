import 'package:get/get.dart';
import '../controllers/confirm_delivery_controller.dart';

class ConfirmDeliveryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConfirmDeliveryController>(
      () => ConfirmDeliveryController(),
    );
  }
}
