import 'package:bulkify/app/data/utils/color_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/modules/collect_payment/controllers/collect_payment_controller.dart';

class CollectPaymentView extends GetView<CollectPaymentController> {
  const CollectPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF7F8FA);
    const Color textPrimary = Color(0xFF18181B);
    const Color textSecondary = Color(0xFF71717A);
    const Color buttonRedBg = Color(0xFFD84338);

    final Widget mainContent = Column(
      children: [
        // Top Custom AppBar (Back Button & Title)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final shouldLeave = await _showLeaveTransactionDialog(
                    context,
                  );
                  if (shouldLeave) {
                    Get.back();
                  }
                },
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
                text: "Collect Payment",
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
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Column(
                  children: [
                    SizedBox(height: 4.h),

                    // 1. Store Name & Order Number Header Card (matches top of both screens in image)
                    Obx(
                      () => Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF2F0),
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44.r,
                              height: 44.r,
                              decoration: BoxDecoration(
                                color: buttonRedBg,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.storefront_rounded,
                                  color: Colors.white,
                                  size: 22.r,
                                ),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                WidgetManager.customText(
                                  text: controller.storeName.value.isNotEmpty
                                      ? controller.storeName.value
                                      : "Fresh Mart",
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                                SizedBox(height: 2.h),
                                WidgetManager.customText(
                                  text:
                                      controller.orderId.value.startsWith(
                                            'Order',
                                          ) ||
                                          controller.orderId.value.startsWith(
                                            '#',
                                          )
                                      ? controller.orderId.value
                                      : "Order #${controller.orderId.value}",
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: textSecondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // 2. Main White Card
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
                          // QR Code Container / Regenerate QR Container
                          Obx(() {
                            final bool isExpired = controller.isTimerExpired;
                            return Container(
                              width: 260.r,
                              height: 260.r,
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(
                                  color: const Color(0xFFF0F0F3),
                                  width: 1.5.w,
                                ),
                              ),
                              child: isExpired
                                  ? Center(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: controller.regenerateQr,
                                          borderRadius: BorderRadius.circular(
                                            22.r,
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 24.w,
                                              vertical: 13.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: buttonRedBg,
                                              borderRadius:
                                                  BorderRadius.circular(22.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: buttonRedBg.withValues(
                                                    alpha: 0.3,
                                                  ),
                                                  blurRadius: 12.r,
                                                  offset: Offset(0, 4.h),
                                                ),
                                              ],
                                            ),
                                            child: WidgetManager.customText(
                                              text: "Regenerate QR",
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : CustomPaint(painter: _QrCodePainter()),
                            );
                          }),

                          // Waiting for payment section (Disappears when timer is 00:00)
                          Obx(() {
                            if (controller.isTimerExpired) {
                              return SizedBox(height: 28.h);
                            }
                            return Column(
                              children: [
                                SizedBox(height: 24.h),
                                WidgetManager.customText(
                                  text:
                                      "Waiting for payment · ${controller.formattedTimer}",
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: textSecondary,
                                ),
                                SizedBox(height: 24.h),
                              ],
                            );
                          }),

                          // Amount to collect section
                          WidgetManager.customText(
                            text: "Amount to collect",
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),

                          SizedBox(height: 4.h),

                          Obx(
                            () => WidgetManager.customText(
                              text:
                                  "₹ ${controller.orderValue.value.toStringAsFixed(2)}",
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w900,
                              color: ColorManager.simpleGreen,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: controller.onGetDeliveryCode,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Text(
                          "success",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: ColorManager.simpleGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await _showLeaveTransactionDialog(context);
        if (shouldLeave) {
          Get.back();
        }
      },
      child: Scaffold(
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
      ),
    );
  }

  /// Confirmation dialog before leaving payment transaction
  Future<bool> _showLeaveTransactionDialog(BuildContext context) async {
    final bool? shouldLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        contentPadding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 12.h),
        content: WidgetManager.customText(
          text: "Do you want to leave the transaction?",
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF18181B),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: WidgetManager.customText(
              text: "No",
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF71717A),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD84338),
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: WidgetManager.customText(
              text: "Yes",
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }
}

/// CustomPainter to render a realistic, crisp QR Code pattern matching the design
class _QrCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint darkPaint = Paint()..color = const Color(0xFF18181B);
    final double cellSize = size.width / 21;

    // Draw Top-Left, Top-Right, Bottom-Left Finder Patterns
    _drawFinderPattern(canvas, darkPaint, 0, 0, cellSize);
    _drawFinderPattern(canvas, darkPaint, 14 * cellSize, 0, cellSize);
    _drawFinderPattern(canvas, darkPaint, 0, 14 * cellSize, cellSize);

    // Grid data pattern boolean map (21x21 QR Version 1 layout)
    final List<List<int>> grid = [
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1],
      [0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0],
      [1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1],
      [1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0],
      [0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1],
    ];

    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        // Skip finder pattern zones
        if ((r < 7 && c < 7) || (r < 7 && c >= 14) || (r >= 14 && c < 7)) {
          continue;
        }
        if (grid[r][c] == 1) {
          final RRect rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(
              c * cellSize + cellSize * 0.05,
              r * cellSize + cellSize * 0.05,
              cellSize * 0.9,
              cellSize * 0.9,
            ),
            Radius.circular(cellSize * 0.2),
          );
          canvas.drawRRect(rect, darkPaint);
        }
      }
    }
  }

  void _drawFinderPattern(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double cellSize,
  ) {
    // Outer 7x7 square
    final RRect outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, 7 * cellSize, 7 * cellSize),
      Radius.circular(cellSize * 1.5),
    );
    canvas.drawRRect(outer, paint);

    // Inner 5x5 white square
    final Paint whitePaint = Paint()..color = Colors.white;
    final RRect middle = RRect.fromRectAndRadius(
      Rect.fromLTWH(x + cellSize, y + cellSize, 5 * cellSize, 5 * cellSize),
      Radius.circular(cellSize * 1.0),
    );
    canvas.drawRRect(middle, whitePaint);

    // Inner 3x3 dark square
    final RRect inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        x + 2 * cellSize,
        y + 2 * cellSize,
        3 * cellSize,
        3 * cellSize,
      ),
      Radius.circular(cellSize * 0.6),
    );
    canvas.drawRRect(inner, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
