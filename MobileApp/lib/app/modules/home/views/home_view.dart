import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:bulkify/app/data/utils/color_manager.dart';
import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/modules/earnings/views/earnings_view.dart';
import 'package:bulkify/app/modules/orders/views/orders_view.dart';
import 'package:bulkify/app/modules/profile/views/profile_view.dart';
import 'package:bulkify/app/modules/home/controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF8F9FC);
    const Color cardBg = Colors.white;
    const Color textPrimary = Color(0xFF1E1B2E);
    const Color textSecondary = Color(0xFF4A4A6A);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final bool? shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: cardBg,
            title: WidgetManager.customText(
              text: 'Exit App',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
            content: WidgetManager.customText(
              text: 'Are you sure you want to exit?',
              fontSize: 14.sp,
              color: textSecondary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: WidgetManager.customText(
                  text: 'No',
                  fontSize: 15.sp,
                  color: Colors.grey,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: WidgetManager.customText(
                  text: 'Yes',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.red,
                ),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Obx(
            () => IndexedStack(
              index: controller.currentNavIndex.value,
              children: [
                _buildHomeTab(context),
                const EarningsView(),
                const OrdersView(),
                const ProfileView(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  /// Main Home Screen View
  Widget _buildHomeTab(BuildContext context) {
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Section (Greeting & Profile Avatar)
              _buildHeaderSection(),

              SizedBox(height: 20.h),

              // 2. Today's Overview Section (Dynamic Responsive Cards Grid)
              _buildTodaysOverviewSection(),

              SizedBox(height: 20.h),

              // 3. Go Online Duty Banner
              _buildGoOnlineCard(),

              SizedBox(height: 20.h),

              // 4. Available Food Deliveries Section
              _buildAvailableOrdersSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Header Section with Dynamic Greeting & Solid Red Profile Avatar matching reference design
  Widget _buildHeaderSection() {
    final int hour = DateTime.now().hour;
    final IconData timeIcon = hour < 18
        ? Icons.wb_sunny_rounded
        : Icons.nights_stay_rounded;

    const Color textPrimary = Color(0xFF1E1B2E);
    const Color textSecondary = Color(0xFF7E7E9A);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: ColorManager.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(timeIcon, size: 13.r, color: ColorManager.red),
                  ),
                  SizedBox(width: 6.w),
                  Obx(
                    () => WidgetManager.customText(
                      text: controller.greeting.value,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    child: const Icon(Icons.info_outline),
                    onTap: () => controller.showDeviceInfoDialog(Get.context!),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Obx(
                () => WidgetManager.customText(
                  text: controller.userName.value,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                  letterSpacing: -0.5,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),

        // Solid Red Profile Avatar with Status Indicator Dot
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ColorManager.red,
              ),
              child: Center(
                child: Icon(
                  Icons.person_rounded,
                  size: 28.r,
                  color: Colors.white,
                ),
              ),
            ),
            Obx(
              () => Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.isOnline.value
                        ? const Color(0xFF109B5B)
                        : const Color(0xFFA5A3AE),
                    border: Border.all(color: Colors.white, width: 2.w),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Today's Overview Section (2x2 Grid with reduced gap space)
  Widget _buildTodaysOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Earnings & Completed
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _buildOverviewCard(
                  value:
                      "${controller.currencySymbol.value} ${controller.earningsMain.value}${controller.earningsCents.value}",
                  label: "Earnings",
                  onTap: () => controller.changeNavIndex(1),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Obx(
                () => _buildOverviewCard(
                  value: "${controller.totalOrders.value}",
                  label: "Completed",
                  onTap: () => controller.changeNavIndex(2),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // Row 2: Online time & Distance
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _buildOverviewCard(
                  value: controller.onlineTime.value,
                  label: "Online Time",
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Obx(
                () => _buildOverviewCard(
                  value: controller.totalDistance.value,
                  label: "Distance",
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Compact Overview Card Item Tile
  Widget _buildOverviewCard({
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    const Color textPrimary = Color(0xFF1E1B2E);
    const Color textMuted = Color(0xFF8A8A9E);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: WidgetManager.customText(
                text: value,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 2.h),
            WidgetManager.customText(
              text: label,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: textMuted,
            ),
          ],
        ),
      ),
    );
  }

  /// Go Online / Offline Duty Switch Banner matching reference design
  Widget _buildGoOnlineCard() {
    return Obx(() {
      final bool isOnline = controller.isOnline.value;

      const Color redBg = Color(0xFFC5392B);
      const Color greenBg = Color(0xFF109B5B);
      const Color redTrack = Color(0xFF9E2A2B);
      const Color greenTrack = Color(0xFF0B7041);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isOnline ? greenBg : redBg,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: (isOnline ? greenBg : redBg).withValues(alpha: 0.35),
              blurRadius: 14.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Status Dot & Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7.r,
                        height: 7.r,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      WidgetManager.customText(
                        text: isOnline ? "You're online" : "Go online to start",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  WidgetManager.customText(
                    text: isOnline
                        ? "Looking for orders near you"
                        : "You are currently offline",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // Toggle Switch Widget
            GestureDetector(
              onTap: () {
                controller.toggleOnlineStatus(!isOnline);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 52.w,
                height: 30.h,
                padding: EdgeInsets.all(3.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: isOnline ? greenTrack : redTrack,
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: isOnline
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Available Food Deliveries Section matching reference design
  Widget _buildAvailableOrdersSection() {
    const Color textPrimary = Color(0xFF1E1B2E);
    const Color redText = Color(0xFFC5392B);
    const Color pillBg = Color(0xFFFDEAE8);

    return Obx(() {
      final bool isOnline = controller.isOnline.value;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Available orders + status pill badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                WidgetManager.customText(
                  text: "Available Orders",
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
                if (!isOnline)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: WidgetManager.customText(
                      text: "Offline",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: redText,
                    ),
                  ),
              ],
            ),

            if (!isOnline) ...[
              SizedBox(height: 32.h),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56.r,
                      height: 56.r,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF2F3F8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.lock_outline_rounded,
                          size: 24.r,
                          color: const Color(0xFF9E9EB2),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    WidgetManager.customText(
                      text: "You're offline",
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4A4A6A),
                    ),
                    SizedBox(height: 4.h),
                    WidgetManager.customText(
                      text: "Go online to see available orders",
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8A8A9E),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ] else ...[
              SizedBox(height: 14.h),
              Divider(color: const Color(0xFFF0F0F5), height: 1.h),
              SizedBox(height: 16.h),

              // ListView of Available Order Cards
              if (controller.availableOrders.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: WidgetManager.customText(
                      text: "No available orders nearby at the moment.",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8A8A9E),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.availableOrders.length,
                  separatorBuilder: (context, index) => Column(
                    children: [
                      SizedBox(height: 16.h),
                      Divider(color: const Color(0xFFF0F0F5), height: 1.h),
                      SizedBox(height: 16.h),
                    ],
                  ),
                  itemBuilder: (context, index) {
                    final order = controller.availableOrders[index];
                    return _buildFoodOrderItemCard(
                      order: order,
                      restaurantName: order['restaurantName'] ?? '',
                      distance: order['distance'] ?? '',
                      payout: order['payout'] ?? '',
                      dropoff: order['dropoff'] ?? '',
                      eta: order['eta'] ?? '3.2 km · 11',
                    );
                  },
                ),
            ],
          ],
        ),
      );
    });
  }

  /// Available Order Card matching reference image design layout
  Widget _buildFoodOrderItemCard({
    required Map<String, dynamic> order,
    required String restaurantName,
    required String distance,
    required String payout,
    required String dropoff,
    required String eta,
  }) {
    const Color textPrimary = Color(0xFF1E1B2E);
    const Color textSecondary = Color(0xFF5A6072);
    const Color redColor = Color(0xFFC5392B);

    final String cleanDropoff = dropoff.replaceAll('Drop-off: ', '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Store Icon in Light Red Circle (matching image)
            Container(
              width: 40.r,
              height: 40.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFDEAE8),
              ),
              child: Center(
                child: Icon(
                  Icons.storefront_rounded,
                  size: 18.r,
                  color: redColor,
                ),
              ),
            ),
            SizedBox(width: 14.w),

            // Order Content Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Name & Payout (matching image)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: WidgetManager.customText(
                          text: restaurantName,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      //SizedBox(width: 8.w),
                    ],
                  ),

                  SizedBox(height: 4.h),
                  WidgetManager.customText(
                    text: payout,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: ColorManager.simpleGreen,
                  ),
                  SizedBox(height: 4.h),

                  // Drop-off Location Row (matching image)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 14.r,
                          color: textSecondary,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: RichText(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: cleanDropoff,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),

                  // Distance Row (matching image)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14.r,
                        color: textSecondary,
                      ),
                      SizedBox(width: 6.w),
                      WidgetManager.customText(
                        text: (distance.isNotEmpty && distance != '0')
                            ? distance
                            : (eta.contains('km')
                                  ? eta.split('·').first.trim()
                                  : '3.2 km'),
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // Action Buttons Row (Reject Pill & Accept Solid Red Pill)
        Row(
          children: [
            // Reject Button
            Expanded(
              child: SizedBox(
                height: 42.h,
                child: ElevatedButton(
                  onPressed: () {
                    controller.availableOrders.removeWhere(
                      (o) => o['restaurantName'] == restaurantName,
                    );
                    WidgetManager.showSnackBar(
                      message: 'Order From $restaurantName Has Been Rejected.',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.grey.shade900,
                      textColor: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0F2F5),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    elevation: 0,
                  ),
                  child: WidgetManager.customText(
                    text: 'Reject',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4A4A6A),
                  ),
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // Accept Button (Solid Red Pill with soft shadow)
            Expanded(
              child: Container(
                height: 42.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22.r),
                  boxShadow: [
                    BoxShadow(
                      color: redColor.withValues(alpha: 0.35),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    controller.handleOrderAccept(order);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: redColor,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    elevation: 0,
                  ),
                  child: WidgetManager.customText(
                    text: 'Accept',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Obx(() {
      const Color navBg = Colors.white;
      const Color borderColor = Color(0xFFF0F0F5);
      const Color unselectedColor = Color(0xFF9E9EB2);

      final Widget navBarWidget = Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(
            top: BorderSide(color: borderColor, width: 1.w),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: controller.currentNavIndex.value,
          onTap: controller.changeNavIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: navBg,
          selectedItemColor: ColorManager.red,
          unselectedItemColor: unselectedColor,
          selectedFontSize: 12.sp,
          unselectedFontSize: 12.sp,
          selectedLabelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Icon(Icons.home_rounded, size: 26.r),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Icon(Icons.account_balance_wallet_outlined, size: 24.r),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Icon(Icons.account_balance_wallet_rounded, size: 24.r),
              ),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Icon(Icons.inventory_2_outlined, size: 24.r),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Icon(Icons.inventory_2_rounded, size: 24.r),
              ),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Icon(Icons.person_outline_rounded, size: 24.r),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Icon(Icons.person_rounded, size: 24.r),
              ),
              label: 'Profile',
            ),
          ],
        ),
      );

      return navBarWidget;
    });
  }
}
