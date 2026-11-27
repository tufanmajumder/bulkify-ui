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
        'High-priority notifications for new delivery requests',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel _fallbackChannel = AndroidNotificationChannel(
    'fcm_fallback_notification_channel',
    'Order Notifications',
    description:
        'High-priority fallback channel for incoming order notifications',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  // Tracks active status bar notification IDs by order key / order number
  static final Map<String, int> _orderNotificationIds = {};

  /// Generates a deterministic positive 32-bit notification ID from an order key
  static int getNotificationId(String key) {
    final clean = key.replaceAll('#', '').trim();
    if (clean.isEmpty || clean.toLowerCase() == 'order') return 1001;
    return (clean.hashCode.abs() % 90000) + 1000;
  }

  /// Cancels an order notification from the Android status bar
  static Future<void> cancelOrderNotification(String orderKey) async {
    final clean = orderKey.replaceAll('#', '').trim();
    if (clean.isEmpty || clean.toLowerCase() == 'order') {
      try {
        await _notificationsPlugin.cancelAll();
      } catch (_) {}
      return;
    }

    // 1. Cancel by stored ID if available
    final storedId = _orderNotificationIds[clean];
    if (storedId != null) {
      try {
        await _notificationsPlugin.cancel(id: storedId);
        print("Cancelled status bar notification by stored ID $storedId for $clean");
      } catch (_) {}
    }

    // 2. Cancel by computed deterministic ID
    final computedId = getNotificationId(clean);
    try {
      await _notificationsPlugin.cancel(id: computedId);
      print("Cancelled status bar notification by computed ID $computedId for $clean");
    } catch (_) {}

    // 3. Cancel any matching entry in _orderNotificationIds
    final List<String> toRemove = [];
    for (final entry in _orderNotificationIds.entries) {
      if (entry.key == clean ||
          entry.key.contains(clean) ||
          clean.contains(entry.key)) {
        try {
          await _notificationsPlugin.cancel(id: entry.value);
        } catch (_) {}
        toRemove.add(entry.key);
      }
    }
    for (final k in toRemove) {
      _orderNotificationIds.remove(k);
    }
  }

  /// Cancels all notifications from the Android status bar
  static Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      _orderNotificationIds.clear();
      print("Cancelled all status bar notifications.");
    } catch (e) {
      print("Error cancelling all notifications: $e");
    }
  }

  static Future<void> initialize({bool isBackground = false}) async {
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

    // Create high-priority channels on Android and request permission if in foreground
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImpl != null) {
      try {
        await androidImpl.createNotificationChannel(_channel);
        await androidImpl.createNotificationChannel(_fallbackChannel);
      } catch (e) {
        print("Error creating notification channels: $e");
      }

      if (!isBackground) {
        try {
          await androidImpl.requestNotificationsPermission();
        } catch (e) {
          print("Error requesting notification permissions: $e");
        }
      }
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

    // Dynamic orderKey & orderNumber extraction
    String rawOrderKey = (data['orderkey'] ??
            data['orderKey'] ??
            data['order_key'] ??
            data['order_id'] ??
            data['id'] ??
            '')
        .toString()
        .trim();
    String rawOrderNumber = (data['ordernumber'] ??
            data['orderNumber'] ??
            data['order_number'] ??
            '')
        .toString()
        .trim();

    final notifTitle =
        message?.notification?.title ?? data['title']?.toString() ?? '';
    final notifBody =
        message?.notification?.body ??
        data['body']?.toString() ??
        data['description']?.toString() ??
        '';

    final fullNotifText = '$notifTitle\n$notifBody';
    final allMatches = RegExp(
      r'[Oo]rder\s*#?([A-Za-z0-9_-]+)',
    ).allMatches(fullNotifText).toList();

    for (final m in allMatches) {
      final val = (m.group(1) ?? '').trim();
      if (val.isEmpty || val.toLowerCase() == 'order') continue;
      if (val.contains('-') && val.length > 20) {
        if (rawOrderKey.isEmpty) rawOrderKey = val;
      } else if (val.toUpperCase().startsWith('SO-') || val.length < 20) {
        if (rawOrderNumber.isEmpty) rawOrderNumber = val;
      }
    }

    if (rawOrderKey.toLowerCase() == 'order') rawOrderKey = '';
    if (rawOrderNumber.toLowerCase() == 'order') rawOrderNumber = '';

    if (rawOrderKey.isEmpty && allMatches.isNotEmpty) {
      for (final m in allMatches) {
        final val = (m.group(1) ?? '').trim();
        if (val.isNotEmpty && val.toLowerCase() != 'order') {
          rawOrderKey = val;
          break;
        }
      }
    }
    if (rawOrderNumber.isEmpty) {
      rawOrderNumber = rawOrderKey;
    }

    final cleanOrderKey = rawOrderKey.replaceAll('#', '').trim();
    final cleanOrderNumber = rawOrderNumber.replaceAll('#', '').trim();
    final displayOrderId = cleanOrderNumber.isNotEmpty &&
            cleanOrderNumber.toLowerCase() != 'order'
        ? (cleanOrderNumber.startsWith('#')
            ? cleanOrderNumber
            : '#$cleanOrderNumber')
        : (cleanOrderKey.isNotEmpty && cleanOrderKey.toLowerCase() != 'order'
            ? '#$cleanOrderKey'
            : '#001');

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

    String storeName =
        (data['storeName'] ??
                data['restaurantName'] ??
                data['store'] ??
                '')
            .toString()
            .trim();
    if (storeName.isEmpty ||
        storeName == 'Delivery Driver' ||
        storeName == 'New Delivery Available' ||
        storeName == 'Store') {
      if (data['store'] is Map && data['store']['name'] != null) {
        storeName = data['store']['name'].toString();
      } else {
        storeName = 'DTS Private Limited';
      }
    }

    String address =
        (data['dropoff'] ??
                data['address'] ??
                data['dropOffAddress'] ??
                data['deliveryaddress'] ??
                '')
            .toString()
            .trim();
    if (address.isEmpty) {
      if (data['drop'] is Map && data['drop']['address'] != null) {
        address = data['drop']['address'].toString();
      } else {
        address = 'Vill And Post SANKRAIL, WB, 711313, India';
      }
    }

    final payout = data['payout'] ?? data['amount'] ?? data['total'];

    return {
      'orderKey': cleanOrderKey,
      'orderNumber': cleanOrderNumber,
      'orderId': displayOrderId,
      'distance': distance,
      'description': description,
      'storeName': storeName,
      'address': address,
      'payout': payout,
      'raw': data,
    };
  }

  /// Builds a complete available order map suitable for HomeController.availableOrders
  static Map<String, dynamic> buildOrderMapFromDetails(
    Map<String, dynamic> details,
  ) {
    final raw = Map<String, dynamic>.from(details['raw'] ?? {});
    final cleanOrderKey = (details['orderKey'] ??
            raw['orderkey'] ??
            raw['orderKey'] ??
            '')
        .toString()
        .replaceAll('#', '')
        .trim();
    final orderNum = (details['orderNumber'] ??
            raw['ordernumber'] ??
            raw['orderNumber'] ??
            cleanOrderKey)
        .toString()
        .replaceAll('#', '')
        .trim();
    final displayId = orderNum.isNotEmpty
        ? (orderNum.startsWith('#') ? orderNum : '#$orderNum')
        : (cleanOrderKey.isNotEmpty ? '#$cleanOrderKey' : '#001');

    String storeName = (details['storeName'] ??
            raw['storeName'] ??
            raw['restaurantName'] ??
            raw['store'] ??
            '')
        .toString()
        .trim();
    if (storeName.isEmpty ||
        storeName == 'Delivery Driver' ||
        storeName == 'New Delivery Available' ||
        storeName == 'Store') {
      if (raw['store'] is Map && raw['store']['name'] != null) {
        storeName = raw['store']['name'].toString();
      } else {
        storeName = 'DTS Private Limited';
      }
    }

    String dropAddress = (details['address'] ??
            raw['dropoff'] ??
            raw['address'] ??
            raw['dropOffAddress'] ??
            raw['deliveryaddress'] ??
            '')
        .toString()
        .trim();
    if (dropAddress.isEmpty) {
      if (raw['drop'] is Map && raw['drop']['address'] != null) {
        dropAddress = raw['drop']['address'].toString();
      } else {
        dropAddress = 'Vill And Post SANKRAIL, WB, 711313, India';
      }
    }

    // Format payout: e.g. "₹ 524.00"
    dynamic rawPayout = details['payout'] ??
        raw['payout'] ??
        raw['amount'] ??
        raw['total'];
    String formattedPayout = '₹ 524.00';
    if (rawPayout != null && rawPayout.toString().trim().isNotEmpty) {
      final pStr = rawPayout.toString().trim();
      if (pStr.startsWith('₹') || pStr.startsWith('\$')) {
        formattedPayout = pStr;
      } else {
        final dVal = double.tryParse(pStr);
        if (dVal != null) {
          formattedPayout = '₹ ${dVal.toStringAsFixed(2)}';
        } else {
          formattedPayout = '₹ $pStr';
        }
      }
    }

    return <String, dynamic>{
      'id': displayId,
      'orderNumber': orderNum.isNotEmpty ? orderNum : cleanOrderKey,
      'orderkey': cleanOrderKey,
      'orderKey': cleanOrderKey,
      'assignmentkey':
          (raw['assignmentkey'] ?? raw['assignmentKey'] ?? '').toString(),
      'restaurantName': storeName,
      'storeName': storeName,
      'distance': (details['distance'] ?? raw['distance'] ?? '-').toString(),
      'eta': (raw['eta'] ?? '-').toString(),
      'payout': formattedPayout,
      'amount': double.tryParse(raw['amount']?.toString() ?? '') ??
          double.tryParse(rawPayout?.toString() ?? '') ??
          524.0,
      'dropoff': dropAddress,
      'dropOffAddress': dropAddress,
      'address': dropAddress,
      'status': 'Pending',
      'orderstatus': 'Pending',
      'raw': raw,
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
      if (orderKey.isNotEmpty) {
        rejectDeliveryOrder(
          orderKey: orderKey,
          orderId: orderId,
          rawOrder: payloadMap,
        );
      } else {
        Get.snackbar(
          'Delivery Rejected',
          'You rejected Order $orderId',
          backgroundColor: const Color(0xFFDC2626),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } else {
      // Tap on notification itself -> (Commented out: popup disabled as requested)
      // showDeliveryDialog(
      //   orderId: orderId,
      //   orderKey: orderKey,
      //   distance: orderDetails['distance'],
      //   description: orderDetails['description'],
      //   rawOrder: payloadMap,
      // );
      if (Get.isRegistered<HomeController>()) {
        final orderMap = buildOrderMapFromDetails(orderDetails);
        Get.find<HomeController>().handleIncomingOrderNotification(
          orderKey,
          orderData: orderMap,
        );
      }
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

    // Cancel status bar notification immediately
    cancelOrderNotification(cleanOrderKey);
    cancelOrderNotification(displayId);

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

        fallbackOrder['orderstatus'] = 'accepted';
        fallbackOrder['status'] = 'accepted';
        fallbackOrder['statusText'] = 'Accepted';
        fallbackOrder['statusType'] = 'active';

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

  /// Rejects an order using ApiManager.rejectOrder, removes it from available orders, and refreshes
  static Future<void> rejectDeliveryOrder({
    required String orderKey,
    String? orderId,
    String reasonCode = "",
    String remarks = "",
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

    // Cancel status bar notification immediately
    cancelOrderNotification(cleanOrderKey);
    cancelOrderNotification(displayId);

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
        await homeController.handleOrderReject(
          existingOrder,
          reasonCode: reasonCode,
          remarks: remarks,
        );
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
      'raw': rawOrder ?? {},
    };

    if (Get.isRegistered<HomeController>()) {
      if (Get.isDialogOpen == true) Get.back();
      await Get.find<HomeController>().handleOrderReject(
        fallbackOrder,
        reasonCode: reasonCode,
        remarks: remarks,
      );
      return;
    }

    // 3. Direct API call if HomeController is not yet registered
    try {
      final authService = AuthService();
      final response = await authService.rejectOrder(
        orderKey: cleanOrderKey,
        reasonCode: reasonCode,
        remarks: remarks,
      );

      if (response != null &&
          (response['success'] == true ||
              response['code'] == 200 ||
              response['code'] == "200" ||
              response['status'] == 'success')) {
        if (Get.isDialogOpen == true) Get.back();

        final String msg =
            response['message']?.toString() ?? 'Order rejected successfully';
        WidgetManager.showSnackBar(
          message: msg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.grey.shade900,
          textColor: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        final String errorMsg =
            response?['message']?.toString() ?? 'Failed to reject order';
        WidgetManager.showSnackBar(
          message: errorMsg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print("Error rejecting order in notification service: $e");
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
    String resolvedOrderId =
        orderId ??
        details['orderId'] ??
        (resolvedOrderKey.isNotEmpty ? '#$resolvedOrderKey' : '#001');
    if (resolvedOrderId.toLowerCase() == '#order' ||
        resolvedOrderId.toLowerCase() == 'order') {
      final numStr =
          (details['orderNumber'] ?? '').toString().replaceAll('#', '').trim();
      resolvedOrderId =
          (numStr.isNotEmpty && numStr.toLowerCase() != 'order')
              ? '#$numStr'
              : (resolvedOrderKey.isNotEmpty ? '#$resolvedOrderKey' : '#001');
    }
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

    // 1. Show System Notification (clean in status bar without Accept & Reject action buttons)
    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFCD463E),
      styleInformation: BigTextStyleInformation(
        resolvedDescription,
        contentTitle: resolvedTitle,
        summaryText: 'Order $resolvedOrderId · $resolvedDistance',
      ),
      channelShowBadge: true,
      autoCancel: true,
      // actions: const <AndroidNotificationAction>[
      //   AndroidNotificationAction(
      //     'accept_action',
      //     'Accept',
      //     showsUserInterface: true,
      //     cancelNotification: true,
      //   ),
      //   AndroidNotificationAction(
      //     'reject_action',
      //     'Reject',
      //     cancelNotification: true,
      //   ),
      // ],
    );

    // Map order notification ID deterministically and store it
    final String keyForId = (details['orderNumber']?.toString().isNotEmpty ==
                true &&
            details['orderNumber'].toString().toLowerCase() != 'order')
        ? details['orderNumber'].toString()
        : (resolvedOrderKey.isNotEmpty ? resolvedOrderKey : resolvedOrderId);
    final int notifId = getNotificationId(keyForId);
    if (resolvedOrderKey.isNotEmpty) {
      _orderNotificationIds[resolvedOrderKey] = notifId;
    }
    _orderNotificationIds[resolvedOrderId.replaceAll('#', '')] = notifId;
    if (details['orderNumber'] != null &&
        details['orderNumber'].toString().toLowerCase() != 'order') {
      _orderNotificationIds[details['orderNumber'].toString().replaceAll('#', '')] =
          notifId;
    }

    try {
      await _notificationsPlugin.show(
        id: notifId,
        title: resolvedTitle,
        body: 'Order $resolvedOrderId · $resolvedDistance\n$resolvedDescription',
        notificationDetails: NotificationDetails(android: androidDetails),
        payload: payloadJson,
      );
      print("Shown status bar notification ID $notifId for order $resolvedOrderId / $resolvedOrderKey");
    } catch (e) {
      print("Error showing notification in NotificationService: $e");
    }

    // 2. Refresh available orders on Home screen in real time and schedule 30s auto-removal
    final orderMap = buildOrderMapFromDetails(details);
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().handleIncomingOrderNotification(
        resolvedOrderKey,
        orderData: orderMap,
      );
    }

    // 3. Display the in-app heads-up prompt (Commented out: notifications now appear only in status bar)
    // if (Get.context != null) {
    //   showDeliveryDialog(
    //     orderId: resolvedOrderId,
    //     orderKey: resolvedOrderKey,
    //     distance: resolvedDistance,
    //     description: resolvedDescription,
    //     rawOrder: details['raw'],
    //   );
    // }
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
    String resolvedOrderId =
        orderId ??
        details['orderId'] ??
        (resolvedOrderKey.isNotEmpty ? '#$resolvedOrderKey' : '#001');
    if (resolvedOrderId.toLowerCase() == '#order' ||
        resolvedOrderId.toLowerCase() == 'order') {
      final numStr =
          (details['orderNumber'] ?? '').toString().replaceAll('#', '').trim();
      resolvedOrderId =
          (numStr.isNotEmpty && numStr.toLowerCase() != 'order')
              ? '#$numStr'
              : (resolvedOrderKey.isNotEmpty ? '#$resolvedOrderKey' : '#001');
    }
    final resolvedDistance = distance ?? details['distance'] ?? '2.5 km away';
    final resolvedDescription =
        description ??
        details['description'] ??
        'Collect the order from the merchant and deliver it to the customer.';

    final RxBool isAccepting = false.obs;
    final RxBool isRejecting = false.obs;

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
            isRejecting: isRejecting.value,
            onAccept: (isAccepting.value || isRejecting.value)
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
            onReject: (isAccepting.value || isRejecting.value)
                ? null
                : () async {
                    isRejecting.value = true;
                    try {
                      await rejectDeliveryOrder(
                        orderKey: resolvedOrderKey.isNotEmpty
                            ? resolvedOrderKey
                            : resolvedOrderId.replaceAll('#', ''),
                        orderId: resolvedOrderId,
                        rawOrder: details['raw'],
                      );
                    } finally {
                      isRejecting.value = false;
                    }
                  },
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.55),
      barrierDismissible: true,
    );
  }
}
