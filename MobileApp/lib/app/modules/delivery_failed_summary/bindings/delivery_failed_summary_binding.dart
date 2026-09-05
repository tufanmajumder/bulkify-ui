import 'package:get/get.dart';
import 'package:bulkify/app/modules/delivery_failed_summary/controllers/delivery_failed_summary_controller.dart';

class DeliveryFailedSummaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryFailedSummaryController>(
      () => DeliveryFailedSummaryController(),
    );
  }
}
