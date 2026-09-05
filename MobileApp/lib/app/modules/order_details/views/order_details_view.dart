import 'package:bulkify/app/data/utils/color_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:bulkify/app/data/utils/string_manager.dart';
import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/widgets/order_items_card.dart';
import 'package:bulkify/app/modules/order_details/controllers/order_details_controller.dart';

class OrderDetailsView extends GetView<OrderDetailsController> {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF7F8FA);
    const Color textPrimary = Color(0xFF18181B);
    const Color textSecondary = Color(0xFF71717A);
    const Color textCaption = Color(0xFFA0A0B0);
    const Color circleBg = Color(0xFFF4F4F6);
    const Color dividerColor = Color(0xFFF0F0F3);
    const Color buttonColor = Color(0xFFD84338);

    final Widget mainContent = Column(
      children: [
        // Top Custom AppBar (Back Button & Title)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: textPrimary,
                      size: 24.r,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Obx(
                () => Expanded(
                  child: WidgetManager.customText(
                    text: "Order #${controller.orderId.value}",
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scrollable Body
        Expanded(
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            //physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),

                    // Items List Section Card
                    Obx(() => OrderItemsCard(items: controller.items.toList())),

                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Fixed Bottom Section (Total & Start Order Button)
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: bgColor,
            constraints: const BoxConstraints(maxWidth: 550),
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
              top: 12.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Total Row
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WidgetManager.customText(
                        text: "Total Amount",
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                      WidgetManager.customText(
                        text:
                            "₹ ${controller.orderTotal.value.toStringAsFixed(2)}",
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w900,
                        color: ColorManager.simpleGreen,
                        letterSpacing: -0.3,
                      ),
                    ],
                  ),
                ),

                // Order Picked / Confirm Pickup Button (Hidden for Completed / Rejected tabs or when orderstatus is not 'Accepted')
                Obx(() {
                  final String st = controller.statusType.value.toLowerCase();
                  final bool isFromCompletedOrRejected =
                      st == 'completed' ||
                      st == 'rejected' ||
                      st == 'delivered';

                  final bool isAccepted =
                      controller.orderstatus.value.trim().toLowerCase() ==
                      'accepted';

                  if (isFromCompletedOrRejected || !isAccepted) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 14.h),
                      Container(
                        width: double.infinity,
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(26.r),
                          boxShadow: [
                            BoxShadow(
                              color: buttonColor.withValues(alpha: 0.3),
                              blurRadius: 14.r,
                              offset: Offset(0, 5.h),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: controller.onStartOrder,
                            borderRadius: BorderRadius.circular(26.r),
                            child: Center(
                              child: WidgetManager.customText(
                                text: StringManager.orderPicked,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: kIsWeb
            ? Center(
                child: SizedBox(
                  width: 550,
                  height: double.infinity,
                  child: mainContent,
                ),
              )
            : mainContent,
      ),
    );
  }
}
