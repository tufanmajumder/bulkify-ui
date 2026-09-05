import 'package:get/get.dart';
import 'package:bulkify/app/modules/collect_payment/controllers/collect_payment_controller.dart';

class CollectPaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CollectPaymentController>(
      () => CollectPaymentController(),
    );
  }
}
