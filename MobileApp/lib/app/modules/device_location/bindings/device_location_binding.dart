import 'package:get/get.dart';
import 'package:bulkify/app/modules/device_location/controllers/device_location_controller.dart';

class DeviceLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeviceLocationController>(
      () => DeviceLocationController(),
    );
  }
}
