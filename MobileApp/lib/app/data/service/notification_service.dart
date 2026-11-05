import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../widgets/delivery_notification_card.dart';

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

    // Create the high priority channel on Android
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(_channel);
    }
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    _handleAction(response);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    _handleAction(response);
  }

  static void _handleAction(NotificationResponse response) {
    final actionId = response.actionId;
    if (actionId == 'accept_action') {
      Get.snackbar(
        'Delivery Accepted',
        'You accepted the delivery order.',
        backgroundColor: const Color(0xFF16A34A),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } else if (actionId == 'reject_action') {
      Get.snackbar(
        'Delivery Rejected',
        'You rejected the delivery order.',
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } else {
      // Tap on notification itself -> show the in-app delivery card
      showDeliveryDialog();
    }
  }

  static Future<void> showDeliveryNotification({
    RemoteMessage? message,
    String? orderId,
    String? distance,
    String? description,
  }) async {
    final data = message?.data ?? {};
    final notification = message?.notification;

    final resolvedOrderId =
        orderId ?? data['order_id'] ?? data['orderId'] ?? '#001';
    final resolvedDistance = distance ?? data['distance'] ?? '2.5 km away';
    final resolvedDescription =
        description ??
        data['description'] ??
        notification?.body ??
        'Collect the order from the merchant and deliver it to the customer.';
    final resolvedTitle = notification?.title ?? 'New Delivery Available';

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
      payload: jsonEncode({
        'order_id': resolvedOrderId,
        'distance': resolvedDistance,
        'description': resolvedDescription,
      }),
    );

    // 2. Also display the in-app heads-up prompt matching Image 1
    showDeliveryDialog(
      orderId: resolvedOrderId,
      distance: resolvedDistance,
      description: resolvedDescription,
    );
  }

  static void showDeliveryDialog({
    String orderId = '#001',
    String distance = '2.5 km away',
    String description =
        'Collect the order from the merchant and deliver it to the customer.',
  }) {
    if (Get.isDialogOpen == true) return;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 14),
        child: DeliveryNotificationCard(
          orderId: orderId,
          distance: distance,
          description: description,
          onAccept: () {
            Get.back();
            Get.snackbar(
              'Order Accepted',
              'You have accepted Order $orderId',
              backgroundColor: const Color(0xFF16A34A),
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
          },
          onReject: () {
            Get.back();
            Get.snackbar(
              'Order Rejected',
              'You rejected Order $orderId',
              backgroundColor: const Color(0xFFDC2626),
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
          },
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.55),
      barrierDismissible: true,
    );
  }
}
