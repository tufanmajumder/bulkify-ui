import 'package:get/get.dart';
import '../controllers/map_webview_controller.dart';

class MapWebviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapWebviewController>(
      () => MapWebviewController(),
    );
  }
}
