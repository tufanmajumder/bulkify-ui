import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/modules/earnings/controllers/earnings_controller.dart';

class EarningsView extends GetView<EarningsController> {
  const EarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color cardBg = Colors.white;
    const Color textPrimary = Color(0xFF1E1B2E);
    const Color textSecondary = Color(0xFF7E7E9A);
    const Color redBg = Color(0xFFC5392B);

    final Widget content = SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Page Title Header
              WidgetManager.customText(
                text: "Earnings",
                fontSize: 26.sp,
                fontWeight: FontWeight.w900,
                color: textPrimary,
                letterSpacing: -0.5,
              ),

              SizedBox(height: 20.h),

              // 2. Today's Earnings Banner Card (Clean & Sleek)
              Obx(
                () => Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  decoration: BoxDecoration(
                    color: redBg,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: redBg.withValues(alpha: 0.28),
                        blurRadius: 14.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetManager.customText(
                        text: "Today's Earnings",
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      SizedBox(height: 8.h),
                      WidgetManager.customText(
                        text:
                            "${controller.currencySymbol.value}${controller.earningsMain.value}${controller.earningsCents.value}",
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      SizedBox(height: 8.h),
                      WidgetManager.customText(
                        text:
                            "From ${controller.totalOrders.value} Completed Deliveries",
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // 3. Breakdown Section
              WidgetManager.customText(
                text: "Breakdown",
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: textPrimary,
                letterSpacing: -0.3,
              ),

              SizedBox(height: 10.h),

              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(22.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.035),
                        blurRadius: 14.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildBreakdownItem(
                        "Base Fare",
                        controller.baseFare.value,
                      ),
                      Divider(
                        color: const Color(0xFFF3F3F7),
                        height: 1.h,
                        thickness: 1.h,
                      ),
                      _buildBreakdownItem(
                        "Distance Bonus",
                        controller.distanceBonus.value,
                      ),
                      Divider(
                        color: const Color(0xFFF3F3F7),
                        height: 1.h,
                        thickness: 1.h,
                      ),
                      _buildBreakdownItem(
                        "Peak Hour Bonus",
                        controller.peakHourBonus.value,
                      ),
                      Divider(
                        color: const Color(0xFFF3F3F7),
                        height: 1.h,
                        thickness: 1.h,
                      ),
                      _buildBreakdownItem("Tips", controller.tips.value),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // 4. This Week Section
              WidgetManager.customText(
                text: "This Week",
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: textPrimary,
                letterSpacing: -0.3,
              ),

              SizedBox(height: 14.h),

              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.w,
                          vertical: 15.h,
                        ),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(22.r),
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
                            WidgetManager.customText(
                              text: controller.weeklyTotal.value,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                              letterSpacing: -0.3,
                            ),
                            SizedBox(height: 4.h),
                            WidgetManager.customText(
                              text: "Total Earned",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.w,
                          vertical: 15.h,
                        ),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(22.r),
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
                            WidgetManager.customText(
                              text: controller.weeklyDeliveries.value,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                              letterSpacing: -0.3,
                            ),
                            SizedBox(height: 4.h),
                            WidgetManager.customText(
                              text: "Deliveries",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //SizedBox(height: 20.h),
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

  /// Breakdown Item Helper Row Widget
  Widget _buildBreakdownItem(String label, String amount) {
    const Color textPrimary = Color(0xFF1E1B2E);
    const Color textSecondary = Color(0xFF5A6072);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          WidgetManager.customText(
            text: label,
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
          WidgetManager.customText(
            text: amount,
            fontSize: 15.5.sp,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ],
      ),
    );
  }
}
