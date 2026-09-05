import 'dart:convert';

import 'package:bulkify/app/data/models/home/summary_model.dart';
import 'package:bulkify/app/data/service/auth_service.dart';
import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/routes/app_pages.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' hide Summary;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bulkify/app/data/models/auth_models/profile/profileModel.dart'
    as profile_model;
import 'package:bulkify/app/modules/profile/controllers/profile_controller.dart';

class HomeController extends GetxController {
  final AuthService _authService = AuthService();

  // API State & Summary Model
  final RxBool isLoadingSummary = false.obs;
  final Rxn<SummaryModel> summaryModel = Rxn<SummaryModel>();

  // Navigation Index
  final RxInt currentNavIndex = 0.obs;

  // Device Location state & real-time coordinates
  final RxBool isLocationEnabled = false.obs;
  final RxDouble currentLatitude = 0.0.obs;
  final RxDouble currentLongitude = 0.0.obs;

  // Driver / User Profile Data
  final RxString greeting = 'Good Morning'.obs;
  final RxString userName = '...'.obs;
  final RxString userAvatarUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    updateGreeting();
    checkDeviceLocationStatus();
    fetchSummaryData();
    fetchUserProfileData();
  }

  /// Checks if real-time location is already enabled on device init
  Future<void> checkDeviceLocationStatus() async {
    if (kIsWeb) return;
    try {
      final Location location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      PermissionStatus permission = await location.hasPermission();

      if (serviceEnabled && permission == PermissionStatus.granted) {
        isLocationEnabled.value = true;
        final locData = await location.getLocation().timeout(
          const Duration(seconds: 4),
          onTimeout: () =>
              LocationData.fromMap({'latitude': 0.0, 'longitude': 0.0}),
        );
        currentLatitude.value = locData.latitude ?? 0.0;
        currentLongitude.value = locData.longitude ?? 0.0;
      }
    } catch (e) {
      print("Location status check: $e");
    }
  }

  /// Updates the greeting message based on the current time of day.
  void updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting.value = 'Good Morning';
    } else if (hour < 18) {
      greeting.value = 'Good Afternoon';
    } else if (hour < 21) {
      greeting.value = 'Good Evening';
    } else {
      greeting.value = 'Good Night';
    }
  }

  // Earnings & Orders Data
  final RxString currencySymbol = '₹'.obs;
  final RxString earningsMain = '0'.obs;
  final RxString earningsCents = '0'.obs;
  final RxInt totalOrders = 0.obs;
  final RxString onlineTime = '0'.obs;
  final RxString totalDistance = '0'.obs;

  // Available Food Orders Data List
  final RxList<Map<String, dynamic>> availableOrders = <Map<String, dynamic>>[
    {
      'id': '#FOOD-4892',
      'restaurantName': 'Burger Bistro',
      'distance': '3.2 km',
      'payout': '₹ 165.00',
      'dropoff': 'Flat 402, Oakwood Heights, Main Street, Bengaluru 560038',
      'eta': '3.2 km · 11',
    },
    {
      'id': '#FOOD-4898',
      'restaurantName': 'Fresh Mart',
      'distance': '3.3 km',
      'payout': '₹ 145.00',
      'dropoff': 'Lakeview Residency, B-12, Bengaluru 560038',
      'eta': '3.3 km · 8',
    },
  ].obs;

  // Online / Offline Status
  final RxBool isOnline = false.obs;

  // Toggle Online Status
  Future<void> toggleOnlineStatus(bool value) async {
    final response = await _authService.updateOnlineStatus(isOnline: value);
    if (response != null &&
        (response['success'] == true ||
            response['code'] == 200 ||
            response['code'] == "200")) {
      isOnline.value = value;
      final String msg =
          response['message']?.toString() ??
          (value ? 'You are now online' : 'You are now offline');
      WidgetManager.showSnackBar(
        message: msg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: value ? const Color(0xFF2E7D32) : Colors.orangeAccent,
        duration: const Duration(seconds: 2),
      );
    } else {
      final String errorMsg =
          response?['message']?.toString() ?? 'Failed to update online status';
      WidgetManager.showSnackBar(
        message: errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Change Bottom Nav Index
  void changeNavIndex(int index) {
    currentNavIndex.value = index;
  }

  /// Handle Order Accept Action
  /// Checks real-time location service & permission using 'location' package.
  /// If location service is off or permission denied, navigate to Device Location screen.
  /// If location is on, navigate to Order Details.
  Future<void> handleOrderAccept(Map<String, dynamic> order) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var sid = prefs.getString('sessionId');
    print("Sid...$sid");
    final Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    PermissionStatus permission = await location.hasPermission();

    if (!serviceEnabled || permission != PermissionStatus.granted) {
      isLocationEnabled.value = false;
      Get.toNamed(Routes.DEVICE_LOCATION, arguments: order);
    } else {
      isLocationEnabled.value = true;
      Get.toNamed(Routes.ORDER_DETAILS, arguments: order);
    }
  }

  /// Logout user and clear session ID
  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessionId');
    Get.offAllNamed(Routes.LOGIN);
  }

  /// Fetch summary API data when home page loads
  Future<void> fetchSummaryData() async {
    isLoadingSummary.value = true;
    try {
      final SummaryModel? model = await _authService.getSummary();
      if (model != null) {
        summaryModel.value = model;
        _updateSummaryFields(model);
      }
    } catch (e) {
      print("Error fetching summary data: $e");
    } finally {
      isLoadingSummary.value = false;
    }
  }

  /// Fetch user profile data to populate userName on Home view
  Future<void> fetchUserProfileData() async {
    try {
      if (Get.isRegistered<ProfileController>()) {
        final profileCtrl = Get.find<ProfileController>();
        if (profileCtrl.driverName.value.isNotEmpty) {
          userName.value = profileCtrl.driverName.value;
        }
        ever(profileCtrl.driverName, (String name) {
          if (name.isNotEmpty) {
            userName.value = name;
          }
        });
      }

      if (userName.value == '...' || userName.value.isEmpty) {
        final profile_model.ProfileViewModel? profileModel = await _authService
            .getConnect();
        if (profileModel != null && profileModel.data != null) {
          final dynamic rootData = profileModel.data;
          final profile_model.Data? dataObj = rootData is profile_model.Data
              ? rootData
              : (rootData is Map<String, dynamic>
                    ? profile_model.Data.fromJson(rootData)
                    : null);

          if (dataObj != null && dataObj.profile != null) {
            final p = dataObj.profile!;
            final String first = p.contactname?.toString().trim() ?? '';
            final String last = p.surname?.toString().trim() ?? '';
            if (first.isNotEmpty && last.isNotEmpty) {
              userName.value = "$first $last";
            } else if (first.isNotEmpty) {
              userName.value = first;
            } else if (last.isNotEmpty) {
              userName.value = last;
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching user profile in HomeController: $e");
    }
  }

  /// Map data from SummaryModel to observable reactive variables
  void _updateSummaryFields(SummaryModel model) {
    final dynamic rootData = model.data;
    if (rootData == null) return;

    final Data? dataData = rootData is Data
        ? rootData
        : (rootData is Map<String, dynamic> ? Data.fromJson(rootData) : null);

    if (dataData == null) return;

    // Online Status
    if (dataData.onlinestatus != null) {
      final statusVal = dataData.onlinestatus;
      if (statusVal is bool) {
        isOnline.value = statusVal;
      } else if (statusVal is num) {
        isOnline.value = statusVal == 1;
      } else if (statusVal is String) {
        isOnline.value =
            statusVal.toLowerCase() == 'true' ||
            statusVal == '1' ||
            statusVal.toLowerCase() == 'online';
      }
    }

    final Summary? s = dataData.summary is Summary
        ? dataData.summary as Summary
        : (dataData.summary is Map<String, dynamic>
              ? Summary.fromJson(dataData.summary)
              : null);
    if (s == null) return;

    // 1. Earnings
    if (s.earnings != null) {
      final amtVal = s.earnings;
      if (amtVal is Map) {
        if (amtVal['symbol'] != null) {
          currencySymbol.value = amtVal['symbol'].toString();
        }
        final numAmt = amtVal['amount'];
        if (numAmt != null) {
          final double? numVal = double.tryParse(numAmt.toString());
          if (numVal != null) {
            final parts = numVal.toStringAsFixed(2).split('.');
            earningsMain.value = parts[0];
            earningsCents.value = '.${parts[1]}';
          } else {
            earningsMain.value = numAmt.toString();
            earningsCents.value = '';
          }
        }
      } else {
        final double? numVal = double.tryParse(amtVal.toString());
        if (numVal != null) {
          final parts = numVal.toStringAsFixed(2).split('.');
          earningsMain.value = parts[0];
          earningsCents.value = '.${parts[1]}';
        } else {
          earningsMain.value = amtVal.toString();
          earningsCents.value = '';
        }
      }
    }

    // 2. Completed Orders
    if (s.completedorders != null) {
      final val = int.tryParse(s.completedorders.toString());
      if (val != null) {
        totalOrders.value = val;
      }
    }

    // 3. Online Time (Seconds)
    if (s.onlinetimeseconds != null) {
      final val = s.onlinetimeseconds;
      final int? totalSecs = int.tryParse(val.toString());
      if (totalSecs != null) {
        final int totalMins = totalSecs ~/ 60;
        final int hours = totalMins ~/ 60;
        final int remainingMins = totalMins % 60;
        if (hours > 0) {
          onlineTime.value = '$hours h $remainingMins m';
        } else {
          onlineTime.value = '$remainingMins m';
        }
      } else {
        onlineTime.value = val.toString();
      }
    }

    // 4. Distance
    if (s.distance != null) {
      final val = s.distance.toString().trim();
      if (val.toLowerCase().contains('km')) {
        totalDistance.value = val;
      } else {
        totalDistance.value = '$val km';
      }
    }
  }

  void showDeviceInfoDialog(BuildContext context) async {
    final deviceInfo = DeviceInfoPlugin();
    final BaseDeviceInfo info = await deviceInfo.deviceInfo;

    String deviceId = 'Unknown';
    String model = 'Unknown';
    String brand = 'Unknown';
    String deviceType = 'Phone';
    String base64Data = '';

    try {
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        deviceId = webInfo.userAgent ?? 'Web Browser';
        model = webInfo.browserName.name;
        final vendor = webInfo.vendor;
        brand = (vendor != null && vendor.isNotEmpty) ? vendor : 'Web Browser';
        deviceType = 'Web Browser';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        model = androidInfo.model;
        brand = androidInfo.brand;
        final shortestSide = MediaQuery.of(context).size.shortestSide;
        deviceType = shortestSide >= 600 ? 'Tablet' : 'Phone';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'Unknown iOS';
        model = iosInfo.name.isNotEmpty ? iosInfo.name : iosInfo.model;
        brand = 'Apple';
        deviceType = iosInfo.model.toLowerCase().contains('ipad')
            ? 'Tablet'
            : 'Phone';
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        deviceId = windowsInfo.deviceId;
        model = windowsInfo.computerName;
        brand = 'Microsoft';
        deviceType = 'Desktop';
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        final macInfo = await deviceInfo.macOsInfo;
        deviceId = macInfo.systemGUID ?? 'Unknown macOS';
        model = macInfo.model;
        brand = 'Apple';
        deviceType = 'Desktop';
      } else if (defaultTargetPlatform == TargetPlatform.linux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        deviceId = linuxInfo.machineId ?? 'Unknown Linux';
        model = linuxInfo.name;
        brand = linuxInfo.variant ?? 'Linux';
        deviceType = 'Desktop';
      }
      base64Data = AuthService().convertData(
        deviceType,
        deviceId,
        model,
        brand,
      );
      print('data in block...$base64Data');
    } catch (e) {
      deviceId = 'Error: $e';
    }

    print("Device ID: $deviceId ($deviceType)");
    print("Device Info Data: ${info.data}");

    if (!context.mounted) return;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.perm_device_info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Device Information', style: TextStyle(fontSize: 20)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DEVICE TYPE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      deviceType,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    const Text(
                      'DEVICE ID',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      deviceId,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    const Text(
                      'MODEL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      model,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    const Text(
                      'BRAND',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      brand,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    const Text(
                      'BASE64 DATA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      base64Data,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              //const Divider(),
              // const SizedBox(height: 8),
              // ...info.data.entries.map((entry) {
              //   return Padding(
              //     padding: const EdgeInsets.symmetric(vertical: 4),
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           '${entry.key}: ',
              //           style: const TextStyle(fontWeight: FontWeight.bold),
              //         ),
              //         Expanded(child: Text('${entry.value}')),
              //       ],
              //     ),
              //   );
              // }),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
