import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'app/data/service/notification_service.dart';
import 'app/data/utils/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  await NotificationService.showDeliveryNotification(message: message);
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Initialize Local Notifications Service
  await NotificationService.initialize();

  // Set background messaging handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 3. Request notification permissions (Required for Android 13+ & iOS)
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (kDebugMode) {
    print('User permission status: ${settings.authorizationStatus}');
  }

  // 4. Generate and print the FCM Token
  try {
    final String? fcmToken = await messaging.getToken();
    print("========================================");
    print("FCM TOKEN: $fcmToken");
    print("========================================");
  } catch (e) {
    print("Error fetching FCM token: $e");
  }

  // Listen for token refresh
  messaging.onTokenRefresh.listen((newToken) {
    print("FCM Token Refreshed: $newToken");
  });

  // Handle foreground messages: show rich notification with Accept & Reject
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      print(
        'Foreground notification received: ${message.notification?.title} - ${message.notification?.body}',
      );
    }
    NotificationService.showDeliveryNotification(message: message);
  });

  // Handle when notification opened the app
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    NotificationService.showDeliveryDialog();
  });

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size designSize = kIsWeb
            ? Size(constraints.maxWidth, constraints.maxHeight)
            : const Size(360, 690);

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: false,
          ensureScreenSize: true,
          builder: (context, child) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: "Bulkify",
              theme: AppTheme.lightTheme,
              initialRoute: AppPages.INITIAL,
              getPages: AppPages.routes,
            );
          },
        );
      },
    );
  }
}
