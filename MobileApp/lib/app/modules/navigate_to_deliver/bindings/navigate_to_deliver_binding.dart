import 'package:get/get.dart';
import 'package:bulkify/app/modules/navigate_to_deliver/controllers/navigate_to_deliver_controller.dart';

class NavigateToDeliverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigateToDeliverController>(
      () => NavigateToDeliverController(),
    );
  }
}
