import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/utils/widget_manager.dart';

class CustomerDetailsCard extends StatefulWidget {
  final String customerName;
  final String dropOffAddress;
  final String? customerPhone;
  final bool initiallyExpanded;
  final bool isCollapsible;
  final VoidCallback? onTapAddress;
  final VoidCallback? onTapCustomer;

  const CustomerDetailsCard({
    super.key,
    required this.customerName,
    required this.dropOffAddress,
    this.customerPhone,
    this.initiallyExpanded = false,
    this.isCollapsible = true,
    this.onTapAddress,
    this.onTapCustomer,
  });

  @override
  State<CustomerDetailsCard> createState() => _CustomerDetailsCardState();
}

class _CustomerDetailsCardState extends State<CustomerDetailsCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    const Color textPrimary = Color(0xFF18181B);
    const Color textSecondary = Color(0xFF71717A);
    const Color textCaption = Color(0xFFA0A0B0);
    const Color circleBg = Color(0xFFF4F4F6);
    const Color dividerColor = Color(0xFFF0F0F3);

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
          // 1. Header Row (Customer details + Dropdown Arrow)
          InkWell(
            onTap: widget.isCollapsible
                ? () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(12.r),
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
                  child: WidgetManager.customText(
                    text: "Customer details",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                if (widget.isCollapsible)
                  AnimatedRotation(
                    turns: _isExpanded ? 0 : -0.25,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: textPrimary,
                      size: 24.r,
                    ),
                  ),
              ],
            ),
          ),

          // 2. Collapsible Details Content
          AnimatedCrossFade(
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 18.h),

                // Customer Row
                GestureDetector(
                  onTap: widget.onTapCustomer,
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
                              text: widget.customerName.isNotEmpty
                                  ? widget.customerName
                                  : "Aditya Shah",
                              fontSize: 15.5.sp,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                            if (widget.customerPhone != null &&
                                widget.customerPhone!.isNotEmpty) ...[
                              SizedBox(height: 2.h),
                              WidgetManager.customText(
                                text: widget.customerPhone!,
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

                // Drop Off Address Row
                GestureDetector(
                  onTap: widget.onTapAddress,
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
                              text: "DROP OFF TO",
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: textCaption,
                            ),
                            SizedBox(height: 2.h),
                            WidgetManager.customText(
                              text: widget.dropOffAddress.isNotEmpty
                                  ? widget.dropOffAddress
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
            secondChild: const SizedBox.shrink(),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
