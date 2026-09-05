import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MapWebviewController extends GetxController {
  final RxString address =
      'B-12, Lakeview Residency, 5th Avenue, Bengaluru 560034'.obs;
  final RxString mapUrl = ''.obs;
  final RxBool isLoading = true.obs;

  late final WebViewController webViewController;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      if (Get.arguments is Map<String, dynamic> &&
          Get.arguments['address'] != null) {
        address.value = Get.arguments['address'].toString();
      } else if (Get.arguments is String) {
        address.value = Get.arguments.toString();
      }
    }

    final encodedAddress = Uri.encodeComponent(address.value);
    mapUrl.value =
        'https://maps.google.com/maps?saddr=My+Location&daddr=$encodedAddress&output=embed';

    if (!kIsWeb) {
      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              isLoading.value = true;
            },
            onPageFinished: (String url) {
              isLoading.value = false;
            },
            onWebResourceError: (WebResourceError error) {
              isLoading.value = false;
            },
            onNavigationRequest: (NavigationRequest request) async {
              if (request.url.startsWith('intent://') ||
                  request.url.startsWith('google.navigation:') ||
                  request.url.startsWith('market://') ||
                  (!request.url.startsWith('http://') &&
                      !request.url.startsWith('https://'))) {
                try {
                  final Uri uri = Uri.parse(request.url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                } catch (_) {}
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(mapUrl.value));
    } else {
      isLoading.value = false;
    }
  }
}
