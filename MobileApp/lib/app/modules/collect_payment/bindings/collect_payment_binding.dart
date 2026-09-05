import 'package:get/get.dart';
import '../controllers/collect_payment_controller.dart';

class CollectPaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CollectPaymentController>(
      () => CollectPaymentController(),
    );
  }
}
