import 'package:get/get.dart';
import 'package:bulkify/app/modules/delivery_failed_reason/controllers/delivery_failed_reason_controller.dart';

class DeliveryFailedReasonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryFailedReasonController>(
      () => DeliveryFailedReasonController(),
    );
  }
}
