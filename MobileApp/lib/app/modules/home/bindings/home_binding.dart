import 'package:get/get.dart';

import 'package:bulkify/app/modules/earnings/controllers/earnings_controller.dart';
import 'package:bulkify/app/modules/orders/controllers/orders_controller.dart';
import 'package:bulkify/app/modules/profile/controllers/profile_controller.dart';
import 'package:bulkify/app/modules/home/controllers/home_controller.dart';

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
