import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/modules/map_webview/controllers/map_webview_controller.dart';

class MapWebviewView extends GetView<MapWebviewController> {
  const MapWebviewView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF7F8FA);
    const Color textPrimary = Color(0xFF18181B);
    const Color textSecondary = Color(0xFF71717A);
    const Color accentRed = Color(0xFFD84338);

    final Widget mainContent = Column(
      children: [
        // Top Custom AppBar (Back Button & Header Title)
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetManager.customText(
                      text: "Google Maps",
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                    Obx(
                      () => WidgetManager.customText(
                        text: controller.address.value,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: textSecondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // WebView Content Body
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
              top: 4.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 14.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                if (!kIsWeb)
                  WebViewWidget(controller: controller.webViewController)
                else
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64.r,
                            height: 64.r,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEBF3FE),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.map_outlined,
                              size: 32.r,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          WidgetManager.customText(
                            text: "Google Maps Navigation",
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                          SizedBox(height: 8.h),
                          Obx(
                            () => WidgetManager.customText(
                              text: controller.address.value,
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w400,
                              color: textSecondary,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),

                // Loader Overlay
                Obx(
                  () => controller.isLoading.value
                      ? Container(
                          color: Colors.white,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 32.r,
                                  height: 32.r,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: accentRed,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                WidgetManager.customText(
                                  text: "Loading Google Maps...",
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: textSecondary,
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
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
