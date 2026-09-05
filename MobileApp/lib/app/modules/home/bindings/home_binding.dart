import 'package:get/get.dart';

import '../../earnings/controllers/earnings_controller.dart';
import '../../orders/controllers/orders_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<EarningsController>(
      () => EarningsController(),
    );
    Get.lazyPut<OrdersController>(
      () => OrdersController(),
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
  }
}
