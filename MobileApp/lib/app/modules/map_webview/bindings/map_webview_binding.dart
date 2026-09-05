import 'package:get/get.dart';
import 'package:bulkify/app/modules/map_webview/controllers/map_webview_controller.dart';

class MapWebviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapWebviewController>(
      () => MapWebviewController(),
    );
  }
}
