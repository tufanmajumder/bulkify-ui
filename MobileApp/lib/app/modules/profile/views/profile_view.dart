import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:bulkify/app/data/utils/color_manager.dart';
import 'package:bulkify/app/data/utils/string_manager.dart';
import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/modules/profile/controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color cardBg = Colors.white;
    const Color textPrimary = Color(0xFF1E1B2E);
    const Color textSecondary = Color(0xFF7E7E9A);
    const Color redBg = Color(0xFFC5392B);

    final Widget content = Scaffold(
      backgroundColor: ColorManager.pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 550),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Page Header Title & Loading Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WidgetManager.customText(
                        text: "Profile",
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                      Obx(() {
                        if (controller.isLoading.value) {
                          return SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: redBg,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),

                  SizedBox(height: 18.h),

                  // // 2. User Profile Summary Header Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 14.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Solid Red Circle Avatar (NO camera icon as requested)
                        Obx(() {
                          final String? path =
                              controller.profileImagePath.value;
                          final bool hasImage = path != null && path.isNotEmpty;

                          return Container(
                            width: 56.r,
                            height: 56.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: redBg,
                              image: hasImage
                                  ? DecorationImage(
                                      image: FileImage(File(path)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: hasImage
                                ? null
                                : Center(
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      size: 30.r,
                                      color: Colors.white,
                                    ),
                                  ),
                          );
                        }),
                        SizedBox(width: 14.w),
                        // Name & Partner ID Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () => WidgetManager.customText(
                                  text: controller.driverName.value,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Obx(
                                () => WidgetManager.customText(
                                  text:
                                      "${StringManager.defaultRole} · ID #${controller.partnerId.value}",
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 22.h),

                  // 3. Vehicle Section (ExpansionTile)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 14.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: false,
                        shape: const RoundedRectangleBorder(
                          side: BorderSide.none,
                        ),
                        collapsedShape: const RoundedRectangleBorder(
                          side: BorderSide.none,
                        ),
                        tilePadding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 4.h,
                        ),
                        childrenPadding: EdgeInsets.only(
                          left: 18.w,
                          right: 18.w,
                          bottom: 16.h,
                        ),
                        iconColor: textPrimary,
                        collapsedIconColor: textSecondary,
                        title: WidgetManager.customText(
                          text: "Vehicle",
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                        children: [
                          Divider(
                            color: const Color(0xFFF0F0F5),
                            height: 12.h,
                            thickness: 1.h,
                          ),
                          SizedBox(height: 8.h),
                          Obx(
                            () => Column(
                              children: [
                                _buildDetailRow(
                                  "Vehicle Type",
                                  controller.vehicleType.value,
                                ),
                                Divider(
                                  color: const Color(0xFFF0F0F5),
                                  height: 24.h,
                                  thickness: 1.h,
                                ),
                                _buildDetailRow(
                                  "Vehicle Name",
                                  controller.vehicleName.value,
                                ),
                                Divider(
                                  color: const Color(0xFFF0F0F5),
                                  height: 24.h,
                                  thickness: 1.h,
                                ),
                                _buildDetailRow(
                                  "Registration Number",
                                  controller.registrationNumber.value,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 22.h),

                  // 4. Emergency Contact Section (ExpansionTile)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 14.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: false,
                        shape: const RoundedRectangleBorder(
                          side: BorderSide.none,
                        ),
                        collapsedShape: const RoundedRectangleBorder(
                          side: BorderSide.none,
                        ),
                        tilePadding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 4.h,
                        ),
                        childrenPadding: EdgeInsets.only(
                          left: 18.w,
                          right: 18.w,
                          bottom: 16.h,
                        ),
                        iconColor: textPrimary,
                        collapsedIconColor: textSecondary,
                        title: WidgetManager.customText(
                          text: "Emergency Contact",
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                        children: [
                          Divider(
                            color: const Color(0xFFF0F0F5),
                            height: 12.h,
                            thickness: 1.h,
                          ),
                          SizedBox(height: 8.h),
                          Obx(
                            () => Column(
                              children: [
                                _buildDetailRow(
                                  "Name",
                                  controller.emergencyName.value,
                                ),
                                Divider(
                                  color: const Color(0xFFF0F0F5),
                                  height: 24.h,
                                  thickness: 1.h,
                                ),
                                _buildDetailRow(
                                  "Relation",
                                  controller.emergencyRelation.value,
                                ),
                                Divider(
                                  color: const Color(0xFFF0F0F5),
                                  height: 24.h,
                                  thickness: 1.h,
                                ),
                                _buildDetailRow(
                                  "Phone Number",
                                  controller.emergencyPhone.value,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 22.h),

                  // 5. UPI ID Section (ExpansionTile)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 14.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: false,
                        shape: const RoundedRectangleBorder(
                          side: BorderSide.none,
                        ),
                        collapsedShape: const RoundedRectangleBorder(
                          side: BorderSide.none,
                        ),
                        tilePadding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 4.h,
                        ),
                        childrenPadding: EdgeInsets.only(
                          left: 18.w,
                          right: 18.w,
                          bottom: 16.h,
                        ),
                        iconColor: textPrimary,
                        collapsedIconColor: textSecondary,
                        title: WidgetManager.customText(
                          text: "UPI ID",
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                        children: [
                          Divider(
                            color: const Color(0xFFF0F0F5),
                            height: 12.h,
                            thickness: 1.h,
                          ),
                          SizedBox(height: 8.h),
                          Obx(
                            () => _buildDetailRow(
                              "UPI ID",
                              controller.upiId.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 26.h),

                  // 6. Sign Out Pill Button
                  GestureDetector(
                    onTap: () => controller.logout(),
                    child: Container(
                      width: double.infinity,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: redBg,
                        borderRadius: BorderRadius.circular(22.r),
                        boxShadow: [
                          BoxShadow(
                            color: redBg.withValues(alpha: 0.3),
                            blurRadius: 10.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            size: 18.r,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8.w),
                          WidgetManager.customText(
                            text: "Sign Out",
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ],
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
    );

    if (kIsWeb) {
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: 550, height: double.infinity, child: content),
      );
    }
    return content;
  }

  /// Detail Label-Value Pair Row Widget
  Widget _buildDetailRow(String label, String value) {
    const Color textPrimary = Color(0xFF1E1B2E);
    const Color textSecondary = Color(0xFF7E7E9A);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        WidgetManager.customText(
          text: label,
          fontSize: 13.5.sp,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: WidgetManager.customText(
              text: value,
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
