import 'package:get/get.dart';
import 'package:bulkify/app/modules/customer_unavailable/controllers/customer_unavailable_controller.dart';

class CustomerUnavailableBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerUnavailableController>(
      () => CustomerUnavailableController(),
    );
  }
}
