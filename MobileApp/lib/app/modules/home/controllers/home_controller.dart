import 'package:bulkify/app/data/models/home/summary_model.dart';
import 'package:bulkify/app/data/service/auth_service.dart';
import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/routes/app_pages.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final RxString userName = 'John Doe'.obs;
  final RxString userAvatarUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    updateGreeting();
    checkDeviceLocationStatus();
    fetchSummaryData();
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
  final RxString earningsMain = '1,850'.obs;
  final RxString earningsCents = '.75'.obs;
  final RxInt totalOrders = 4.obs;
  final RxString onlineTime = '2h 45m'.obs;
  final RxString totalDistance = '8.2 km'.obs;

  // Available Food Orders Data List
  final RxList<Map<String, dynamic>> availableOrders = <Map<String, dynamic>>[
    {
      'id': '#FOOD-4892',
      'restaurantName': 'Burger Bistro',
      'distance': '1.5 km',
      'payout': '₹165.00',
      'dropoff': 'Oakwood Heights, Flat 402',
      'eta': '3.2 km · 11',
    },
    {
      'id': '#FOOD-4898',
      'restaurantName': 'Fresh Mart',
      'distance': '0',
      'payout': '₹145.00',
      'dropoff': 'Lakeview Residency, B-12',
      'eta': '3.3 km · 8',
    },
  ].obs;

  // Online / Offline Status
  final RxBool isOnline = false.obs;

  // Toggle Online Status
  void toggleOnlineStatus(bool value) {
    isOnline.value = value;
    if (value) {
      WidgetManager.showSnackBar(
        title: 'Online Status',
        message: 'You are now online and ready to accept orders!',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } else {
      WidgetManager.showSnackBar(
        title: 'Offline Status',
        message: 'You are now offline.',
        snackPosition: SnackPosition.TOP,
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

  /// Map data from SummaryModel to observable reactive variables
  void _updateSummaryFields(SummaryModel model) {
    if (model.data == null) return;

    final dataObj = model.data is Data
        ? model.data as Data
        : (model.data is Map<String, dynamic>
            ? Data.fromJson(model.data as Map<String, dynamic>)
            : null);

    if (dataObj == null) return;

    // 1. Earnings (symbol and amount)
    if (dataObj.earnings != null) {
      final earningsObj = dataObj.earnings is Earnings
          ? dataObj.earnings as Earnings
          : (dataObj.earnings is Map<String, dynamic>
              ? Earnings.fromJson(dataObj.earnings as Map<String, dynamic>)
              : null);

      if (earningsObj != null) {
        if (earningsObj.symbol != null &&
            earningsObj.symbol.toString().isNotEmpty) {
          currencySymbol.value = earningsObj.symbol.toString();
        }

        if (earningsObj.amount != null) {
          final amtVal = earningsObj.amount;
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
    }

    // 2. Completed Orders
    if (dataObj.completedorders != null) {
      final val = int.tryParse(dataObj.completedorders.toString());
      if (val != null) {
        totalOrders.value = val;
      }
    }

    // 3. Online Time
    if (dataObj.onlinetimeminutes != null) {
      final val = dataObj.onlinetimeminutes;
      final int? mins = int.tryParse(val.toString());
      if (mins != null) {
        final int hours = mins ~/ 60;
        final int remainingMins = mins % 60;
        if (hours > 0) {
          onlineTime.value = '${hours}h ${remainingMins}m';
        } else {
          onlineTime.value = '${remainingMins}m';
        }
      } else {
        onlineTime.value = val.toString();
      }
    }

    // 4. Distance Covered
    if (dataObj.distancecoveredkm != null) {
      final val = dataObj.distancecoveredkm.toString();
      if (val.toLowerCase().contains('km')) {
        totalDistance.value = val;
      } else {
        totalDistance.value = '$val km';
      }
    }
  }
}
