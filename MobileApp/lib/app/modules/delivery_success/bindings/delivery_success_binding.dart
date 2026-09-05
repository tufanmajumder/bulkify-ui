import 'package:get/get.dart';
import 'package:bulkify/app/modules/delivery_success/controllers/delivery_success_controller.dart';

class DeliverySuccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliverySuccessController>(
      () => DeliverySuccessController(),
    );
  }
}
