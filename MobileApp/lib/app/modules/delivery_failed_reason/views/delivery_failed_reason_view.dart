import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/modules/delivery_failed_reason/controllers/delivery_failed_reason_controller.dart';

class DeliveryFailedReasonView
    extends GetView<DeliveryFailedReasonController> {
  const DeliveryFailedReasonView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF7F8FA);
    const Color textPrimary = Color(0xFF18181B);
    const Color textSecondary = Color(0xFF71717A);
    const Color redAccent = Color(0xFFD84338);
    const Color selectedCardBg = Color(0xFFFDE8E8);
    const Color unselectedBadgeBg = Color(0xFFF4F4F6);
    const Color unselectedBadgeIconColor = Color(0xFF71717A);
    const Color unselectedRadioBorder = Color(0xFFE4E4E7);
    const Color buttonGreyBg = Color(0xFFF2F3F7);

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
              WidgetManager.customText(
                text: "Customer unavailable",
                fontSize: 19.sp,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ],
          ),
        ),

        // Scrollable Body Content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),

                    // Section Heading Title
                    WidgetManager.customText(
                      text: "Why couldn’t this be delivered?",
                      fontSize: 17.5.sp,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),

                    SizedBox(height: 18.h),

                    // Failure Reasons Options List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.failureReasons.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 14.h),
                      itemBuilder: (context, index) {
                        final String reason = controller.failureReasons[index];

                        return Obx(() {
                          final bool isSelected =
                              controller.selectedOptionIndex.value == index;

                          return GestureDetector(
                            onTap: () => controller.selectOption(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 14.h,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected ? selectedCardBg : Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: isSelected
                                      ? redAccent
                                      : Colors.transparent,
                                  width: 1.6.w,
                                ),
                                boxShadow: isSelected
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.025),
                                          blurRadius: 10.r,
                                          offset: Offset(0, 3.h),
                                        ),
                                      ],
                              ),
                              child: Row(
                                children: [
                                  // Left Cancel Icon Badge
                                  Container(
                                    width: 44.r,
                                    height: 44.r,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? redAccent
                                          : unselectedBadgeBg,
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.cancel_outlined,
                                        size: 22.r,
                                        color: isSelected
                                            ? Colors.white
                                            : unselectedBadgeIconColor,
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 14.w),

                                  // Option Title
                                  Expanded(
                                    child: WidgetManager.customText(
                                      text: reason,
                                      fontSize: 14.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                  ),

                                  SizedBox(width: 8.w),

                                  // Right Radio Indicator
                                  Container(
                                    width: 22.r,
                                    height: 22.r,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? redAccent
                                            : unselectedRadioBorder,
                                        width: 2.w,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Container(
                                              width: 10.r,
                                              height: 10.r,
                                              decoration: const BoxDecoration(
                                                color: redAccent,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    ),

                    SizedBox(height: 28.h),

                    // Confirm delivery failed Button
                    Obx(() {
                      final bool isSelected =
                          controller.selectedOptionIndex.value >= 0;

                      return Container(
                        width: double.infinity,
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: isSelected ? redAccent : buttonGreyBg,
                          borderRadius: BorderRadius.circular(26.r),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: redAccent.withValues(alpha: 0.3),
                                    blurRadius: 14.r,
                                    offset: Offset(0, 5.h),
                                  ),
                                ]
                              : [],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: controller.isSubmitting.value
                                ? null
                                : controller.onConfirmDeliveryFailed,
                            borderRadius: BorderRadius.circular(26.r),
                            child: Center(
                              child: controller.isSubmitting.value
                                  ? SizedBox(
                                      width: 22.r,
                                      height: 22.r,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : WidgetManager.customText(
                                      text: "Confirm delivery failed",
                                      fontSize: 15.5.sp,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? Colors.white
                                          : textSecondary,
                                    ),
                            ),
                          ),
                        ),
                      );
                    }),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
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
