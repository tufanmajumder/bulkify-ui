import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import '../../../data/utils/widget_manager.dart';
import '../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';

class DeviceLocationController extends GetxController {
  dynamic orderArgument;
  final Location _location = Location();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      orderArgument = Get.arguments;
    }
  }

  /// Request real-time location service & permission using location package
  Future<void> allowLocationAccess() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      if (!kIsWeb) {
        // 1. Check if device GPS/location service is enabled
        bool serviceEnabled = await _location.serviceEnabled();
        if (!serviceEnabled) {
          serviceEnabled = await _location.requestService();
          if (!serviceEnabled) {
            WidgetManager.showSnackBar(
              title: 'Location Service Disabled',
              message: 'Please enable Location (GPS) in your device settings.',
              snackPosition: SnackPosition.TOP,
            );
            return;
          }
        }

        // 2. Check location permission status
        PermissionStatus permissionGranted = await _location.hasPermission();
        if (permissionGranted == PermissionStatus.denied) {
          permissionGranted = await _location.requestPermission();
          if (permissionGranted != PermissionStatus.granted) {
            WidgetManager.showSnackBar(
              title: 'Permission Denied',
              message: 'Location permission is required to find nearby orders.',
              snackPosition: SnackPosition.TOP,
            );
            return;
          }
        }
      }

      // 3. Configure location accuracy settings
      try {
        await _location.changeSettings(accuracy: LocationAccuracy.balanced);
      } catch (e) {
        print("Change location settings error: $e");
      }

      // 4. Acquire real-time current location coordinates with a 4-second timeout
      LocationData? locationData;
      try {
        locationData = await _location.getLocation().timeout(
          const Duration(seconds: 4),
          onTimeout: () {
            print("Location fetch timed out, proceeding with fallback.");
            return LocationData.fromMap({'latitude': 0.0, 'longitude': 0.0});
          },
        );
      } catch (e) {
        print("Error fetching location data: $e");
      }

      // 5. Update home controller location state
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.isLocationEnabled.value = true;
        if (locationData != null) {
          homeController.currentLatitude.value = locationData.latitude ?? 0.0;
          homeController.currentLongitude.value = locationData.longitude ?? 0.0;
        }
      }

      WidgetManager.showSnackBar(
        title: 'Location Enabled',
        message: 'Real-time location acquired successfully!',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // 6. Navigate to Order Details or previous screen
      if (orderArgument != null) {
        Get.offNamed(Routes.ORDER_DETAILS, arguments: orderArgument);
      } else {
        Get.back();
      }
    } catch (e) {
      print("Real-time location error: $e");
      WidgetManager.showSnackBar(
        title: 'Location Error',
        message: 'Failed to access location: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Skip location access for now
  void skipLocation() {
    Get.back();
  }
}
