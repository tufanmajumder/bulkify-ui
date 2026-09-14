import 'package:admin_app/views/order_details_screen.dart';
import 'package:admin_app/views/order_list_screen.dart';
import 'package:admin_app/views/payment_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/login_screen.dart';
import 'views/user_profile_screen.dart';
import 'views/users_screen.dart';

void main() {
  runApp(const BulkifyAdminApp());
}

class BulkifyAdminApp extends StatelessWidget {
  const BulkifyAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Admin App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Public Sans',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFCF4340),
          primary: const Color(0xFFCF4340),
        ),
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/', page: () => const UsersScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/users', page: () => const UsersScreen()),
        GetPage(
          name: '/UserProfileScreen',
          page: () => const UserProfileScreen(),
        ),
        GetPage(name: '/user-profile', page: () => const UserProfileScreen()),
        GetPage(name: '/orders', page: () => const OrderListScreen()),
        GetPage(name: '/order-details', page: () => const OrderDetailsScreen()),
        GetPage(name: '/payment-details', page: () => const PaymentListScreen()),
        GetPage(name: '/payments', page: () => const PaymentListScreen()),
      ],
    );
  }
}
