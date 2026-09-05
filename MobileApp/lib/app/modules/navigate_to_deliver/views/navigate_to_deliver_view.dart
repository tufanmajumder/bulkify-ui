import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/utils/widget_manager.dart';
import '../../../widgets/customer_details_card.dart';
import '../controllers/navigate_to_deliver_controller.dart';

class NavigateToDeliverView extends GetView<NavigateToDeliverController> {
  const NavigateToDeliverView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF7F8FA);
    const Color textPrimary = Color(0xFF18181B);
    const Color textSecondary = Color(0xFF71717A);
    const Color textCaption = Color(0xFFA0A0B0);
    const Color circleBg = Color(0xFFF4F4F6);
    const Color dividerColor = Color(0xFFF0F0F3);
    const Color buttonGreyBg = Color(0xFFF2F3F7);
    const Color buttonBlueBg = Color(0xFF3B82F6);
    const Color buttonRedBg = Color(0xFFD84338);

    final Widget mainContent = Column(
      children: [
        // Top Navigation AppBar
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
                text: "Navigate to Delivery",
                fontSize: 19.sp,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ],
          ),
        ),

        // Scrollable Main Content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),

                    // Customer & Delivery Address Card
                    Obx(
                      () => CustomerDetailsCard(
                        customerName: controller.customerName.value,
                        dropOffAddress: controller.deliveryAddress.value,
                        onTapAddress: controller.onOpenGoogleMaps,
                        onTapCustomer: controller.onCallCustomer,
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // Order Value Row
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          WidgetManager.customText(
                            text: "Order value",
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                          WidgetManager.customText(
                            text:
                                "₹${controller.orderValue.value.toStringAsFixed(2)}",
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF111111),
                            letterSpacing: -0.5,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // 1. Call Customer Button (Grey Pill)
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
                                size: 20.r,
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

                    // 2. Open Google Maps Button (Blue Pill)
                    Container(
                      width: double.infinity,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: buttonBlueBg,
                        borderRadius: BorderRadius.circular(25.r),
                        boxShadow: [
                          BoxShadow(
                            color: buttonBlueBg.withValues(alpha: 0.3),
                            blurRadius: 12.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: controller.onOpenGoogleMaps,
                          borderRadius: BorderRadius.circular(25.r),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 20.r,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.w),
                              WidgetManager.customText(
                                text: "Open Google Maps",
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // 3. Arrived at delivery location Button (Red Pill)
                    Container(
                      width: double.infinity,
                      height: 52.h,
                      decoration: BoxDecoration(
                        color: buttonRedBg,
                        borderRadius: BorderRadius.circular(26.r),
                        boxShadow: [
                          BoxShadow(
                            color: buttonRedBg.withValues(alpha: 0.3),
                            blurRadius: 14.r,
                            offset: Offset(0, 5.h),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: controller.onArrivedAtLocation,
                          borderRadius: BorderRadius.circular(26.r),
                          child: Center(
                            child: WidgetManager.customText(
                              text: "Arrived at delivery location",
                              fontSize: 15.5.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),
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
