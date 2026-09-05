import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/utils/widget_manager.dart';
import '../controllers/customer_unavailable_controller.dart';

class CustomerUnavailableView extends GetView<CustomerUnavailableController> {
  const CustomerUnavailableView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF7F8FA);
    const Color textPrimary = Color(0xFF18181B);
    const Color textSecondary = Color(0xFF71717A);
    const Color buttonGreyBg = Color(0xFFF2F3F7);
    const Color warningCircleBg = Color(0xFFFFF3E0);
    const Color warningIconColor = Color(0xFFE67E22);

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
                  children: [
                    SizedBox(height: 8.h),

                    // Main White Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 16.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 32.h,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Warning Exclamation Circle Badge
                          Container(
                            width: 60.r,
                            height: 60.r,
                            decoration: const BoxDecoration(
                              color: warningCircleBg,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.error_outline_rounded,
                                color: warningIconColor,
                                size: 28.r,
                              ),
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // 2. Dynamic Title
                          Obx(
                            () => WidgetManager.customText(
                              text:
                                  "Couldn't reach ${controller.customerName.value}?",
                              fontSize: 15.5.sp,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: 8.h),

                          // 3. Instruction Subtitle
                          WidgetManager.customText(
                            text:
                                "Try calling them, wait a few minutes, or\nmark this delivery as failed if you can't\nproceed.",
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w400,
                            color: textSecondary,
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // 1. Call customer Button (Grey Pill)
                    Container(
                      width: double.infinity,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: buttonGreyBg,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: controller.onCallCustomer,
                          borderRadius: BorderRadius.circular(25.r),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.call_outlined,
                                size: 19.r,
                                color: textPrimary,
                              ),
                              SizedBox(width: 8.w),
                              WidgetManager.customText(
                                text: "Call customer",
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // 2. Wait 5 minutes & retry Button (Grey Pill)
                    Container(
                      width: double.infinity,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: buttonGreyBg,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: controller.onWaitFiveMinutesAndRetry,
                          borderRadius: BorderRadius.circular(25.r),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 19.r,
                                color: textPrimary,
                              ),
                              SizedBox(width: 8.w),
                              WidgetManager.customText(
                                text: "Wait 5 minutes & retry",
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // 3. Mark delivery as failed Button (Light Muted Grey Pill)
                    Container(
                      width: double.infinity,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: buttonGreyBg,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: controller.onMarkDeliveryAsFailed,
                          borderRadius: BorderRadius.circular(25.r),
                          child: Center(
                            child: WidgetManager.customText(
                              text: "Mark delivery as failed",
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),

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
