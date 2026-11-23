import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

import '../../modules/home/controllers/home_controller.dart';
import '../../routes/app_pages.dart';
import '../../widgets/delivery_notification_card.dart';
import '../service/auth_service.dart';
import '../utils/widget_manager.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'delivery_driver_channel',
    'Delivery Driver Notifications',
    description:
        'High-priority notifications for new delivery requests with Accept and Reject actions',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationTapped,
    );

    // Create the high priority channel on Android and request permission (Android 13+)
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(_channel);
      await androidImpl.requestNotificationsPermission();
    }
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    _handleAction(response);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    _handleAction(response);
  }

  /// Extracts structured order details from FCM message or payload data
  static Map<String, dynamic> extractOrderDetails({
    RemoteMessage? message,
    Map<String, dynamic>? payloadData,
  }) {
    Map<String, dynamic> data = {};
    if (payloadData != null) {
      data = Map<String, dynamic>.from(payloadData);
    } else if (message != null) {
      data = Map<String, dynamic>.from(message.data);
    }

    // Decode if data contains nested JSON
    if (data['order'] != null) {
      if (data['order'] is String) {
        try {
          final decoded = jsonDecode(data['order']);
          if (decoded is Map<String, dynamic>) data.addAll(decoded);
        } catch (_) {}
      } else if (data['order'] is Map) {
        data.addAll(Map<String, dynamic>.from(data['order']));
      }
    }
    if (data['data'] != null) {
      if (data['data'] is String) {
        try {
          final decoded = jsonDecode(data['data']);
          if (decoded is Map<String, dynamic>) data.addAll(decoded);
        } catch (_) {}
      } else if (data['data'] is Map) {
        data.addAll(Map<String, dynamic>.from(data['data']));
      }
    }
    if (data['offer'] != null) {
      if (data['offer'] is String) {
        try {
          final decoded = jsonDecode(data['offer']);
          if (decoded is Map<String, dynamic>) data.addAll(decoded);
        } catch (_) {}
      } else if (data['offer'] is Map) {
        data.addAll(Map<String, dynamic>.from(data['offer']));
      }
    }

    // Dynamic orderKey extraction
    String rawOrderKey = (data['orderkey'] ?? '').toString().trim();

    final notifTitle =
        message?.notification?.title ?? data['title']?.toString() ?? '';
    final notifBody =
        message?.notification?.body ??
        data['body']?.toString() ??
        data['description']?.toString() ??
        '';

    if (rawOrderKey.isEmpty) {
      final titleMatch = RegExp(
        r'[Oo]rder\s*#?([A-Za-z0-9_-]+)',
      ).firstMatch(notifTitle);
      if (titleMatch != null) {
        rawOrderKey = titleMatch.group(1) ?? '';
      } else {
        final bodyMatch = RegExp(
          r'[Oo]rder\s*#?([A-Za-z0-9_-]+)',
        ).firstMatch(notifBody);
        if (bodyMatch != null) {
          rawOrderKey = bodyMatch.group(1) ?? '';
        }
      }
    }

    final cleanOrderKey = rawOrderKey.replaceAll('#', '').trim();
    final displayOrderId = cleanOrderKey.isNotEmpty
        ? '#$cleanOrderKey'
        : '#001';

    final distance = (data['distance'] ?? data['km'] ?? '2.5 km away')
        .toString();

    String description =
        (data['description'] ??
                data['body'] ??
                message?.notification?.body ??
                '')
            .toString()
            .trim();
    if (description.isEmpty) {
      description =
          'Collect the order from the merchant and deliver it to the customer.';
    }

    final storeName =
        (data['storeName'] ??
                data['restaurantName'] ??
                data['store'] ??
                data['title'] ??
                message?.notification?.title ??
                'Store')
            .toString();

    final address =
        (data['dropoff'] ??
                data['address'] ??
                data['dropOffAddress'] ??
                data['deliveryaddress'] ??
                '')
            .toString();

    return {
      'orderKey': cleanOrderKey,
      'orderId': displayOrderId,
      'distance': distance,
      'description': description,
      'storeName': storeName,
      'address': address,
      'raw': data,
    };
  }

  static void _handleAction(NotificationResponse response) {
    Map<String, dynamic> payloadMap = {};
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        payloadMap = jsonDecode(response.payload!);
      } catch (_) {}
    }

    final orderDetails = extractOrderDetails(payloadData: payloadMap);
    final orderKey = orderDetails['orderKey']?.toString() ?? '';
    final orderId = orderDetails['orderId']?.toString() ?? '#001';

    final actionId = response.actionId;
    if (actionId == 'accept_action') {
      if (orderKey.isNotEmpty) {
        acceptDeliveryOrder(
          orderKey: orderKey,
          orderId: orderId,
          rawOrder: payloadMap,
        );
      } else {
        Get.snackbar(
          'Delivery Accepted',
          'You accepted the delivery order.',
          backgroundColor: const Color(0xFF16A34A),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } else if (actionId == 'reject_action') {
      Get.snackbar(
        'Delivery Rejected',
        'You rejected Order $orderId',
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } else {
      // Tap on notification itself -> show the in-app delivery card with dynamic order
      showDeliveryDialog(
        orderId: orderId,
        orderKey: orderKey,
        distance: orderDetails['distance'],
        description: orderDetails['description'],
        rawOrder: payloadMap,
      );
    }
  }

  /// Accepts an order using the API, refreshes available orders, and navigates
  static Future<void> acceptDeliveryOrder({
    required String orderKey,
    String? orderId,
    Map<String, dynamic>? rawOrder,
  }) async {
    final cleanOrderKey = orderKey.replaceAll('#', '').trim();
    if (cleanOrderKey.isEmpty) {
      WidgetManager.showSnackBar(
        message: 'Invalid order ID',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    final displayId =
        orderId ??
        (cleanOrderKey.startsWith('#') ? cleanOrderKey : '#$cleanOrderKey');

    // 1. If HomeController is active, check if this order is in availableOrders
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      final existingOrder = homeController.availableOrders.firstWhereOrNull(
        (o) =>
            (o['orderkey']?.toString().replaceAll('#', '') == cleanOrderKey) ||
            (o['orderKey']?.toString().replaceAll('#', '') == cleanOrderKey) ||
            (o['id']?.toString().replaceAll('#', '') == cleanOrderKey) ||
            (o['orderNumber']?.toString().replaceAll('#', '') == cleanOrderKey),
      );

      if (existingOrder != null && existingOrder.isNotEmpty) {
        if (Get.isDialogOpen == true) Get.back();
        await homeController.handleOrderAccept(existingOrder);
        return;
      }
    }

    // 2. Fallback Order Map
    final fallbackOrder = <String, dynamic>{
      'id': displayId,
      'orderNumber': cleanOrderKey,
      'orderkey': cleanOrderKey,
      'orderKey': cleanOrderKey,
      'restaurantName':
          rawOrder?['storeName'] ?? rawOrder?['restaurantName'] ?? 'Store',
      'storeName':
          rawOrder?['storeName'] ?? rawOrder?['restaurantName'] ?? 'Store',
      'distance': rawOrder?['distance'] ?? '-',
      'eta': rawOrder?['eta'] ?? '-',
      'payout': rawOrder?['payout'] ?? '₹ 0.00',
      'amount': rawOrder?['amount'] ?? 0.0,
      'dropoff': rawOrder?['dropoff'] ?? rawOrder?['address'] ?? '',
      'dropOffAddress': rawOrder?['dropoff'] ?? rawOrder?['address'] ?? '',
      'address': rawOrder?['dropoff'] ?? rawOrder?['address'] ?? '',
      'status': 'Accepted',
      'orderstatus': 'Accepted',
      'raw': rawOrder ?? {},
    };

    if (Get.isRegistered<HomeController>()) {
      if (Get.isDialogOpen == true) Get.back();
      await Get.find<HomeController>().handleOrderAccept(fallbackOrder);
      return;
    }

    // 3. Direct API call if HomeController is not yet registered
    try {
      final authService = AuthService();
      final response = await authService.acceptOrder(orderKey: cleanOrderKey);

      if (response != null &&
          (response['success'] == true ||
              response['code'] == 200 ||
              response['code'] == "200" ||
              response['status'] == 'success')) {
        if (Get.isDialogOpen == true) Get.back();

        final String msg =
            response['message']?.toString() ?? 'Order accepted successfully';
        WidgetManager.showSnackBar(
          message: msg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 2),
        );

        final Location location = Location();
        bool serviceEnabled = await location.serviceEnabled();
        PermissionStatus permission = await location.hasPermission();

        if (!serviceEnabled || permission != PermissionStatus.granted) {
          Get.toNamed(Routes.DEVICE_LOCATION, arguments: fallbackOrder);
        } else {
          Get.toNamed(Routes.ORDER_DETAILS, arguments: fallbackOrder);
        }
      } else {
        final String errorMsg =
            response?['message']?.toString() ?? 'Failed to accept order';
        WidgetManager.showSnackBar(
          message: errorMsg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print("Error accepting order in notification service: $e");
    }
  }

  static Future<void> showDeliveryNotification({
    RemoteMessage? message,
    String? orderId,
    String? orderKey,
    String? distance,
    String? description,
    Map<String, dynamic>? rawOrder,
  }) async {
    final details = extractOrderDetails(
      message: message,
      payloadData: rawOrder,
    );

    final resolvedOrderKey = (orderKey ?? details['orderKey'] ?? '')
        .toString()
        .replaceAll('#', '')
        .trim();
    final resolvedOrderId =
        orderId ??
        details['orderId'] ??
        (resolvedOrderKey.isNotEmpty ? '#$resolvedOrderKey' : '#001');
    final resolvedDistance = distance ?? details['distance'] ?? '2.5 km away';
    final resolvedDescription =
        description ??
        details['description'] ??
        'Collect the order from the merchant and deliver it to the customer.';
    final resolvedTitle =
        message?.notification?.title ?? 'New Delivery Available';

    final payloadJson = jsonEncode({
      'order_id': resolvedOrderId,
      'order_key': resolvedOrderKey,
      'orderkey': resolvedOrderKey,
      'distance': resolvedDistance,
      'description': resolvedDescription,
      'title': resolvedTitle,
      ...?details['raw'],
    });

    // 1. Show System Notification with Accept and Reject actions
    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: const Color(0xFFCD463E),
      styleInformation: BigTextStyleInformation(
        resolvedDescription,
        contentTitle: resolvedTitle,
        summaryText: 'Order $resolvedOrderId · $resolvedDistance',
      ),
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'accept_action',
          'Accept',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'reject_action',
          'Reject',
          cancelNotification: true,
        ),
      ],
    );

    await _notificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: resolvedTitle,
      body: 'Order $resolvedOrderId · $resolvedDistance\n$resolvedDescription',
      notificationDetails: NotificationDetails(android: androidDetails),
      payload: payloadJson,
    );

    // 2. Also refresh available orders on Home screen in real time
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().fetchPendingOffers();
      Get.find<HomeController>().fetchSummaryData();
    }

    // 3. Display the in-app heads-up prompt (only when UI is mounted and in foreground)
    if (Get.context != null) {
      showDeliveryDialog(
        orderId: resolvedOrderId,
        orderKey: resolvedOrderKey,
        distance: resolvedDistance,
        description: resolvedDescription,
        rawOrder: details['raw'],
      );
    }
  }

  static void showDeliveryDialog({
    RemoteMessage? message,
    String? orderId,
    String? orderKey,
    String? distance,
    String? description,
    Map<String, dynamic>? rawOrder,
  }) {
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    final details = extractOrderDetails(
      message: message,
      payloadData: rawOrder,
    );

    final resolvedOrderKey = (orderKey ?? details['orderKey'] ?? '')
        .toString()
        .replaceAll('#', '')
        .trim();
    final resolvedOrderId =
        orderId ??
        details['orderId'] ??
        (resolvedOrderKey.isNotEmpty ? '#$resolvedOrderKey' : '#001');
    final resolvedDistance = distance ?? details['distance'] ?? '2.5 km away';
    final resolvedDescription =
        description ??
        details['description'] ??
        'Collect the order from the merchant and deliver it to the customer.';

    final RxBool isAccepting = false.obs;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 14),
        child: Obx(
          () => DeliveryNotificationCard(
            orderId: resolvedOrderId,
            distance: resolvedDistance,
            description: resolvedDescription,
            isAccepting: isAccepting.value,
            onAccept: isAccepting.value
                ? null
                : () async {
                    isAccepting.value = true;
                    try {
                      await acceptDeliveryOrder(
                        orderKey: resolvedOrderKey.isNotEmpty
                            ? resolvedOrderKey
                            : resolvedOrderId.replaceAll('#', ''),
                        orderId: resolvedOrderId,
                        rawOrder: details['raw'],
                      );
                    } finally {
                      isAccepting.value = false;
                    }
                  },
            onReject: () {
              if (Get.isDialogOpen == true) Get.back();
              WidgetManager.showSnackBar(
                message: 'You rejected Order $resolvedOrderId',
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color(0xFFDC2626),
                duration: const Duration(seconds: 2),
              );
            },
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.55),
      barrierDismissible: true,
    );
  }
}
