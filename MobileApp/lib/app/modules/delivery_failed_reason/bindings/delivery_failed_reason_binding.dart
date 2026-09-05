import 'package:get/get.dart';
import '../controllers/delivery_failed_reason_controller.dart';

class DeliveryFailedReasonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryFailedReasonController>(
      () => DeliveryFailedReasonController(),
    );
  }
}
