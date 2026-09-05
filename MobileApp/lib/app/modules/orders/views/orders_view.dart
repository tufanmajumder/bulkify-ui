import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/utils/widget_manager.dart';
import '../../../routes/app_pages.dart';
import '../controllers/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color textPrimary = Color(0xFF1E1B2E);
    const Color textSecondary = Color(0xFF7E7E9A);

    final Widget content = SingleChildScrollView(
      controller: controller.scrollController,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Page Header (Title + Refresh Button)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WidgetManager.customText(
                    text: "Orders",
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                  GestureDetector(
                    onTap: controller.refreshOrders,
                    child: Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.refresh_rounded,
                          size: 20.r,
                          color: const Color(0xFF6E6E8A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 18.h),

              // 2. Segmented Filter Tabs (Active, Completed, Rejected)
              Obx(
                () => Row(
                  children: [
                    Expanded(child: _buildFilterTab(title: "Active", index: 0)),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildFilterTab(title: "Completed", index: 1),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildFilterTab(title: "Rejected", index: 2),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // 5. Filtered Orders List
              Obx(() {
                final bool isLoading =
                    (controller.selectedFilterIndex.value == 0 &&
                        controller.isActiveLoading.value) ||
                    (controller.selectedFilterIndex.value == 1 &&
                        controller.isCompletedLoading.value) ||
                    (controller.selectedFilterIndex.value == 2 &&
                        controller.isRejectedLoading.value);

                if (isLoading) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFFC5392B),
                      ),
                    ),
                  );
                }

                final filteredList = controller.currentFilteredOrders;

                if (filteredList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 48.r,
                            color: const Color(0xFF9E9EB2),
                          ),
                          SizedBox(height: 12.h),
                          WidgetManager.customText(
                            text: "No orders found",
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4A4A6A),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredList.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final order = filteredList[index];
                        return _buildOrderCard(
                          order,
                          textPrimary,
                          textSecondary,
                        );
                      },
                    ),
                    _buildTabFooter(context),
                  ],
                );
              }),

              Obx(() {
                final int index = controller.selectedFilterIndex.value;
                final bool isAllFetched = (index == 0)
                    ? (controller.activeOrders.isNotEmpty &&
                          !controller.isActiveLoading.value &&
                          !controller.isActiveLoadingMore.value &&
                          (controller.activePage.value >=
                                  controller.activeTotalPages.value ||
                              controller.hasNoMoreActiveData.value))
                    : (index == 1)
                    ? (controller.completedOrders.isNotEmpty &&
                          !controller.isCompletedLoading.value &&
                          !controller.isCompletedLoadingMore.value &&
                          (controller.completedPage.value >=
                                  controller.completedTotalPages.value ||
                              controller.hasNoMoreCompletedData.value))
                    : (controller.rejectedOrders.isNotEmpty &&
                          !controller.isRejectedLoading.value &&
                          !controller.isRejectedLoadingMore.value &&
                          (controller.rejectedPage.value >=
                                  controller.rejectedTotalPages.value ||
                              controller.hasNoMoreRejectedData.value));
                return SizedBox(height: isAllFetched ? 0 : 10.h);
              }),
            ],
          ),
        ),
      ),
    );

    if (kIsWeb) {
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: 550, height: double.infinity, child: content),
      );
    }
    return content;
  }

  /// Segmented Filter Tab Button
  Widget _buildFilterTab({required String title, required int index}) {
    final bool isSelected = controller.selectedFilterIndex.value == index;
    const Color redColor = Color(0xFFC5392B);

    return GestureDetector(
      onTap: () => controller.changeFilterIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 11.h),
        decoration: BoxDecoration(
          color: isSelected ? redColor : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFF0F0F5), width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: redColor.withValues(alpha: 0.35),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF4A4A6A),
            ),
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ),
    );
  }

  /// Individual Order Card Component
  Widget _buildOrderCard(
    Map<String, dynamic> order,
    Color textPrimary,
    Color textSecondary,
  ) {
    final String statusType = order['statusType'] ?? '';
    final String storeName = order['storeName'] ?? '';
    final String address = order['address'] ?? '';
    final double amount = (order['amount'] as double? ?? 0.0);
    final String iconType = order['iconType'] ?? '';

    // Status Avatar Config
    Color avatarBg;
    Widget avatarIcon;

    if (statusType == 'delivered') {
      avatarBg = const Color(0xFFE8F6ED);
      avatarIcon = Icon(
        Icons.check_rounded,
        size: 20.r,
        color: const Color(0xFF109B5B),
      );
    } else if (statusType == 'rejected') {
      avatarBg = const Color(0xFFF2F3F7);
      avatarIcon = Icon(
        Icons.close_rounded,
        size: 18.r,
        color: const Color(0xFF9E9EB2),
      );
    } else {
      avatarBg = const Color(0xFFFEF4E8);
      avatarIcon = Icon(
        iconType == 'bike'
            ? Icons.two_wheeler_rounded
            : Icons.local_shipping_outlined,
        size: 20.r,
        color: const Color(0xFFD97706),
      );
    }

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.ORDER_DETAILS, arguments: order),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Avatar Icon Box
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: avatarBg,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(child: avatarIcon),
                ),

                SizedBox(width: 12.w),

                // Store Info & Status Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetManager.customText(
                        text: storeName,
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                      SizedBox(height: 2.h),
                      WidgetManager.customText(
                        text: address,
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w400,
                        color: textSecondary,
                      ),
                      // Status Badge Pill section removed
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                // Price & Chevron Right Arrow
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WidgetManager.customText(
                      text: "₹${amount.toStringAsFixed(2)}",
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20.r,
                      color: const Color(0xFFA0A0B0),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom footer for Active, Completed, and Rejected sections (Loader when fetching next page, or "All data fetched" banner)
  Widget _buildTabFooter(BuildContext context) {
    return Obx(() {
      final index = controller.selectedFilterIndex.value;

      // 1. Bottom loader when fetching next page
      final bool isLoadingMore = (index == 0)
          ? controller.isActiveLoadingMore.value
          : (index == 1)
          ? controller.isCompletedLoadingMore.value
          : controller.isRejectedLoadingMore.value;

      if (isLoadingMore) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Center(
            child: SizedBox(
              width: 24.r,
              height: 24.r,
              child: const CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFFC5392B),
              ),
            ),
          ),
        );
      }

      // 2. All data fetched text banner
      final bool hasAllFetched = (index == 0)
          ? (controller.activeOrders.isNotEmpty &&
                !controller.isActiveLoading.value &&
                !controller.isActiveLoadingMore.value &&
                (controller.activePage.value >=
                        controller.activeTotalPages.value ||
                    controller.hasNoMoreActiveData.value))
          : (index == 1)
          ? (controller.completedOrders.isNotEmpty &&
                !controller.isCompletedLoading.value &&
                !controller.isCompletedLoadingMore.value &&
                (controller.completedPage.value >=
                        controller.completedTotalPages.value ||
                    controller.hasNoMoreCompletedData.value))
          : (controller.rejectedOrders.isNotEmpty &&
                !controller.isRejectedLoading.value &&
                !controller.isRejectedLoadingMore.value &&
                (controller.rejectedPage.value >=
                        controller.rejectedTotalPages.value ||
                    controller.hasNoMoreRejectedData.value));

      if (hasAllFetched) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 16.h),
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.lightBlueAccent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: WidgetManager.customText(
              text: "All data fetched",
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }
}
