import 'package:get/get.dart';
import '../controllers/navigate_to_deliver_controller.dart';

class NavigateToDeliverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigateToDeliverController>(
      () => NavigateToDeliverController(),
    );
  }
}
