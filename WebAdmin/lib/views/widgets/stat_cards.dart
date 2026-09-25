import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/controllers/user_controller.dart';
import 'package:admin_app/utils/asset_manager.dart';
import 'package:admin_app/utils/responsive.dart';

class StatCards extends StatelessWidget {
  const StatCards({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController controller = Get.find<UserController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final double cardWidth = width < 550
            ? width
            : width < 1100
            ? (width - 16) / 2
            : (width - 48) / 4;

        return Obx(() {
          final summary = controller.summary.value;
          final inactiveCount = controller.users
              .where((u) => u.status == 'Inactive')
              .length;

          final activeUsersVal = summary != null
              ? '${summary.activeUsers}'
              : '0';
          final pendingUsersVal = summary != null
              ? '${summary.pendingUsers}'
              : '0';
          final inactiveUsersVal = summary != null
              ? '${summary.inactiveUsers}'
              : '${0}';
          final activeSessionVal = summary != null
              ? '${summary.activeSession}'
              : '0';

          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatCard(
                context: context,
                width: cardWidth,
                title: 'Active Users',
                value: activeUsersVal,
                //percentage: '(-14%)',
                isNegative: true,
                //subtitle: 'Last week analytics',
                icon: AssetManager.userCheck,
                iconBgColor: const Color(0xFFE8F8F0),
                iconColor: const Color(0xFF22C55E),
              ),
              _buildStatCard(
                context: context,
                width: cardWidth,
                title: 'Pending Users',
                value: pendingUsersVal,
                //percentage: '(+42%)',
                isNegative: false,
                //subtitle: 'Last week analytics',
                icon: AssetManager.userSearch,
                iconBgColor: const Color(0xFFFFF4E5),
                iconColor: const Color(0xFFF97316),
              ),
              _buildStatCard(
                context: context,
                width: cardWidth,
                title: 'Inactive Users',
                value: inactiveUsersVal,
                //percentage: '(+18%)',
                isNegative: false,
                //subtitle: 'Last week analytics',
                icon: AssetManager.userPlus,
                iconBgColor: const Color(0xFFFFEAEA),
                iconColor: const Color(0xFFEF4444),
              ),
              _buildStatCard(
                context: context,
                width: cardWidth,
                title: 'Online Users',
                value: activeSessionVal,
                //percentage: '(+29%)',
                isNegative: false,
                //subtitle: 'Total Users',
                icon: AssetManager.exportUser,
                iconBgColor: const Color(0xFFEFE8FF),
                iconColor: const Color(0xFF8B5CF6),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required double width,
    required String title,
    required String value,
    // required String percentage,
    required bool isNegative,
    //required String subtitle,
    required String icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    final padding = Responsive.w(context, 1.5).clamp(16.0, 24.0);

    return Container(
      width: width,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: Responsive.sp(context, 14),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.all(
                  Responsive.w(context, 0.4).clamp(4.0, 8.0),
                ),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  icon,
                  color: iconColor,
                  width: Responsive.sp(context, 20),
                ),
              ),
            ],
          ),
          //SizedBox(height: Responsive.h(context, 0.9).clamp(8.0, 14.0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontSize: Responsive.sp(context, 24),
                  fontWeight: FontWeight.bold,
                ),
              ),
              // const SizedBox(width: 8),
              // Text(
              //   percentage,
              //   style: TextStyle(
              //     color: isNegative
              //         ? const Color(0xFFEF4444)
              //         : const Color(0xFF22C55E),
              //     fontSize: Responsive.sp(context, 13),
              //     fontWeight: FontWeight.w400,
              //   ),
              // ),
            ],
          ),
          // SizedBox(height: Responsive.h(context, 0.6).clamp(6.0, 8.0)),
          // Text(
          //   subtitle,
          //   style: TextStyle(
          //     color: const Color(0xFF94A3B8),
          //     fontSize: Responsive.sp(context, 12),
          //   ),
          // ),
        ],
      ),
    );
  }
}
