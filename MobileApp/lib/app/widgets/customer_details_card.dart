import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bulkify/app/data/utils/widget_manager.dart';

class CustomerDetailsCard extends StatelessWidget {
  final String? orderId;
  final String customerName;
  final String dropOffAddress;
  final String? customerPhone;
  final VoidCallback? onTapAddress;
  final VoidCallback? onTapCustomer;

  const CustomerDetailsCard({
    super.key,
    this.orderId,
    required this.customerName,
    required this.dropOffAddress,
    this.customerPhone,
    this.onTapAddress,
    this.onTapCustomer,
  });

  @override
  Widget build(BuildContext context) {
    const Color textPrimary = Color(0xFF18181B);
    const Color textSecondary = Color(0xFF71717A);
    const Color textCaption = Color(0xFFA0A0B0);
    const Color circleBg = Color(0xFFF4F4F6);
    const Color dividerColor = Color(0xFFF0F0F3);

    final String displayOrderId = (orderId != null && orderId!.isNotEmpty)
        ? (orderId!.startsWith('#') || orderId!.startsWith('Order')
            ? orderId!
            : "#$orderId")
        : "#O103490";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ORDER ID Row (matching image)
          Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: const BoxDecoration(
                  color: circleBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.assignment_outlined,
                    color: textSecondary,
                    size: 22.r,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetManager.customText(
                      text: "ORDER ID",
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: textCaption,
                    ),
                    SizedBox(height: 2.h),
                    WidgetManager.customText(
                      text: displayOrderId,
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),

          Divider(color: dividerColor, height: 28.h, thickness: 1.h),

          // 2. CUSTOMER Row
          GestureDetector(
            onTap: onTapCustomer,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: const BoxDecoration(
                    color: circleBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: textSecondary,
                      size: 22.r,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetManager.customText(
                        text: "CUSTOMER",
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: textCaption,
                      ),
                      SizedBox(height: 2.h),
                      WidgetManager.customText(
                        text: customerName.isNotEmpty
                            ? customerName
                            : "Aditya Shah",
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                      if (customerPhone != null &&
                          customerPhone!.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        WidgetManager.customText(
                          text: customerPhone!,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: textSecondary,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(color: dividerColor, height: 28.h, thickness: 1.h),

          // 3. DELIVERY ADDRESS Row
          GestureDetector(
            onTap: onTapAddress,
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: const BoxDecoration(
                    color: circleBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.location_on_outlined,
                      color: textSecondary,
                      size: 22.r,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetManager.customText(
                        text: "DELIVERY ADDRESS",
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: textCaption,
                      ),
                      SizedBox(height: 2.h),
                      WidgetManager.customText(
                        text: dropOffAddress.isNotEmpty
                            ? dropOffAddress
                            : "Flat 402, Oakwood Heights, Main Street, Bengaluru 560038",
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
