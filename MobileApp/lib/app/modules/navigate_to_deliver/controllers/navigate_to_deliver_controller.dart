import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../routes/app_pages.dart';

class NavigateToDeliverController extends GetxController {
  final RxString customerName = 'Priya Nair'.obs;
  final RxString deliveryAddress =
      'B-12, Lakeview Residency, 5th Avenue, Bengaluru 560034'.obs;
  final RxDouble orderValue = 145.00.obs;
  final RxString customerPhone = '+91 98123 45670'.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final data = Get.arguments as Map<String, dynamic>;
      if (data['customerName'] != null) {
        customerName.value = data['customerName'];
      }
      if (data['dropOffAddress'] != null || data['address'] != null) {
        deliveryAddress.value = (data['dropOffAddress'] ?? data['address'])
            .toString();
      }
      if (data['orderTotal'] != null && data['orderTotal'] is num) {
        orderValue.value = (data['orderTotal'] as num).toDouble();
      } else if (data['amount'] != null && data['amount'] is num) {
        orderValue.value = (data['amount'] as num).toDouble();
      }
      if (data['customerPhone'] != null) {
        customerPhone.value = data['customerPhone'];
      }
    }
  }

  Future<void> onCallCustomer() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: customerPhone.value.replaceAll(' ', ''),
    );
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      Get.snackbar(
        "Calling Customer",
        "Dialing ${customerName.value} (${customerPhone.value})...",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> onOpenGoogleMaps() async {
    final encodedDestination = Uri.encodeComponent(deliveryAddress.value);

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final Uri googleMapsAppUri = Uri.parse(
        'comgooglemaps://?daddr=$encodedDestination&directionsmode=driving',
      );
      final Uri appleMapsUri = Uri.parse(
        'https://maps.apple.com/?daddr=$encodedDestination&dirflg=d',
      );
      final Uri webMapsUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=My+Location&destination=$encodedDestination&travelmode=driving',
      );

      try {
        if (await canLaunchUrl(googleMapsAppUri)) {
          await launchUrl(
            googleMapsAppUri,
            mode: LaunchMode.externalApplication,
          );
          return;
        }
        if (await canLaunchUrl(appleMapsUri)) {
          await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
          return;
        }
        await launchUrl(webMapsUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        Get.snackbar(
          "Maps Error",
          "Could not open maps application: $e",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      final Uri googleMapsUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=My+Location&destination=$encodedDestination&travelmode=driving',
      );

      try {
        if (await canLaunchUrl(googleMapsUri)) {
          await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        Get.snackbar(
          "Maps Error",
          "Could not open Google Maps: $e",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void onArrivedAtLocation() {
    Get.toNamed(
      Routes.DELIVERY_OTP,
      arguments: {
        'customerName': customerName.value,
        'customerPhone': customerPhone.value,
        'deliveryAddress': deliveryAddress.value,
        'orderValue': orderValue.value,
      },
    );
  }
}
