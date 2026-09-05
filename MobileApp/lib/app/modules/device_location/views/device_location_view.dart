import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/utils/color_manager.dart';
import '../../../data/utils/string_manager.dart';
import '../../../data/utils/widget_manager.dart';
import '../controllers/device_location_controller.dart';

class DeviceLocationView extends GetView<DeviceLocationController> {
  const DeviceLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgWhite = Colors.white;
    final Color primaryRed = ColorManager.red;

    return Scaffold(
      backgroundColor: bgWhite,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Central Illustration (Map Grid & Red Location Pin in Dashed Circle)
              _buildLocationIllustration(primaryRed),

              SizedBox(height: 48.h),

              // Title: Allow Location Access
              WidgetManager.customText(
                text: StringManager.allowLocationAccess,
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E1B2E),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12.h),

              // Subtitle: We need your location to find nearby orders...
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: WidgetManager.customText(
                  text: StringManager.locationAccessDescription,
                    fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5A6072),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // Button 1: Allow Location (Primary White & Red Rounded Pill Button)
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFcd463e), Color(0xFFE54B42)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryRed.withOpacity(0.35),
                        blurRadius: 16.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                  ),
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.allowLocationAccess,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? SizedBox(
                              width: 22.r,
                              height: 22.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : WidgetManager.customText(
                              text: StringManager.allowLocation,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Button 2: Not Now (Secondary Red Text Button)
              TextButton(
                onPressed: controller.skipLocation,
                child: WidgetManager.customText(
                  text: StringManager.notNow,
                    fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: primaryRed,
                ),
              ),

              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Custom Illustration recreating the screenshot with White & Red theme
  Widget _buildLocationIllustration(Color accentColor) {
    return SizedBox(
      width: 220.r,
      height: 220.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Dashed Border Circle in Red
          CustomPaint(
            size: Size(220.r, 220.r),
            painter: DashedCirclePainter(
              color: accentColor.withOpacity(0.35),
              strokeWidth: 1.5,
              dashes: 40,
            ),
          ),

          // Inner Light Red/White Circular Background Container
          Container(
            width: 170.r,
            height: 170.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.05),
              border: Border.all(
                color: accentColor.withOpacity(0.1),
                width: 1.w,
              ),
            ),
          ),

          // Isometric Map Floor Graphic
          Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(0.7),
            alignment: Alignment.center,
            child: Container(
              width: 140.r,
              height: 140.r,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: const Color(0xFFF7F7FA),
                border: Border.all(
                  color: const Color(0xFFEAEAEE),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: MapGridPainter(accentColor),
              ),
            ),
          ),

          // Shadow under pin
          Positioned(
            bottom: 75.r,
            child: Container(
              width: 24.w,
              height: 8.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.elliptical(12.w, 4.h)),
                color: accentColor.withOpacity(0.2),
              ),
            ),
          ),

          // Floating Center Location Pin Marker (Red Theme)
          Positioned(
            top: 55.r,
            child: Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [accentColor, const Color(0xFFE54B42)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.45),
                    blurRadius: 18.r,
                    offset: Offset(0, 6.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 36.r,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter for Dashed Circle
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashes;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashes = 36,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double dashAngle = (2 * 3.141592653589793) / dashes;
    for (int i = 0; i < dashes; i += 2) {
      canvas.drawArc(
        Rect.fromCircle(
            center: Offset(radius, radius), radius: radius - strokeWidth),
        i * dashAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for Isometric Map Grid pattern
class MapGridPainter extends CustomPainter {
  final Color accentColor;

  MapGridPainter(this.accentColor);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final Paint blockPaint = Paint()
      ..color = const Color(0xFFEFEFF4)
      ..style = PaintingStyle.fill;

    final Paint pinBlockPaint = Paint()
      ..color = accentColor.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    // Draw map blocks
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(10, 10, 50, 50), const Radius.circular(6)),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(75, 10, 55, 40), const Radius.circular(6)),
      pinBlockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(10, 75, 50, 55), const Radius.circular(6)),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(75, 65, 55, 65), const Radius.circular(6)),
      blockPaint,
    );

    // Draw roads (white lines)
    canvas.drawLine(
        Offset(0, size.height * 0.48), Offset(size.width, size.height * 0.48), roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.48, 0), Offset(size.width * 0.48, size.height), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
