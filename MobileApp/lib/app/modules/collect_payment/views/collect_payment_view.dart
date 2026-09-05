import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/utils/widget_manager.dart';
import '../controllers/collect_payment_controller.dart';

class CollectPaymentView extends GetView<CollectPaymentController> {
  const CollectPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF7F8FA);
    const Color textPrimary = Color(0xFF18181B);
    const Color textSecondary = Color(0xFF71717A);
    const Color buttonRedBg = Color(0xFFD84338);
    const Color buttonGreyBg = Color(0xFFF2F3F7);
    const Color iconCircleBg = Color(0xFFFDE8E8);

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
                text: "Collect payment",
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
                        vertical: 28.h,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Amount to collect Label
                          WidgetManager.customText(
                            text: "Amount to collect",
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),

                          SizedBox(height: 4.h),

                          // 2. Amount Display
                          Obx(
                            () => WidgetManager.customText(
                              text:
                                  "₹${controller.orderValue.value.toStringAsFixed(2)}",
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),

                          SizedBox(height: 22.h),

                          // 3. QR Code Container
                          Container(
                            width: 210.r,
                            height: 210.r,
                            padding: EdgeInsets.all(14.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: const Color(0xFFF0F0F3),
                                width: 1.5.w,
                              ),
                            ),
                            child: CustomPaint(painter: _QrCodePainter()),
                          ),

                          SizedBox(height: 18.h),

                          // 4. UPI ID
                          Obx(
                            () => WidgetManager.customText(
                              text: controller.upiId.value,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: textSecondary,
                            ),
                          ),

                          SizedBox(height: 14.h),

                          // 5. Store Name & Order Number Badge
                          Obx(
                            () => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: iconCircleBg,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.storefront_rounded,
                                    color: buttonRedBg,
                                    size: 18.r,
                                  ),
                                  SizedBox(width: 8.w),
                                  WidgetManager.customText(
                                    text:
                                        "${controller.storeName.value} · Order #${controller.orderId.value}",
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // 1. I've received the payment Button (Red Pill)
                    Obx(
                      () => Container(
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
                            onTap: controller.isProcessing.value
                                ? null
                                : controller.onReceivedPayment,
                            borderRadius: BorderRadius.circular(26.r),
                            child: Center(
                              child: controller.isProcessing.value
                                  ? SizedBox(
                                      width: 22.r,
                                      height: 22.r,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : WidgetManager.customText(
                                      text: "I’ve received the payment",
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // 2. Customer already paid online Button (Grey Pill)
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
                          onTap: controller.onAlreadyPaidOnline,
                          borderRadius: BorderRadius.circular(25.r),
                          child: Center(
                            child: WidgetManager.customText(
                              text: "Customer already paid online",
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
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
