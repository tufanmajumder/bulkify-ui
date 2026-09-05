import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/responsive.dart';
import '../user_profile_screen.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobileOrTablet =
        Responsive.isMobile(context) || Responsive.isTablet(context);
    final headerHeight = Responsive.h(context, 7.5).clamp(56.0, 72.0);
    final horizontalPadding = Responsive.dynamicPadding(context);

    return Container(
      height: headerHeight,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      margin: EdgeInsets.only(
        left: Responsive.w(context, 2),
        top: Responsive.w(context, 2),
        right: Responsive.w(context, 2),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(horizontalPadding * 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 5,
            offset: Offset(0, 0.5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Drawer toggle (mobile/tablet) + Section title
          Row(
            children: [
              if (isMobileOrTablet)
                IconButton(
                  icon: Icon(
                    Icons.menu_rounded,
                    color: const Color(0xFF1E293B),
                    size: Responsive.sp(context, 24),
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              //if (isMobileOrTablet) const SizedBox(width: 8),
            ],
          ),

          // Right side: Bell Notification & Profile Avatar
          Row(
            children: [
              // Bell Notification Icon with Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none_outlined,
                      color: const Color(0xFF64748B),
                      size: Responsive.sp(context, 22),
                    ),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: Responsive.w(context, 0.7).clamp(6.0, 10.0),
                      height: Responsive.w(context, 0.7).clamp(6.0, 10.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCF4340),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),

              // User Profile Avatar with Online Dot
              InkWell(
                onTap: () => Get.to(() => const UserProfileScreen()),
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: Responsive.sp(context, 18),
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: Icon(
                        Icons.person,
                        color: const Color(0xFF64748B),
                        size: Responsive.sp(context, 22),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: Responsive.w(context, 0.8).clamp(8.0, 12.0),
                        height: Responsive.w(context, 0.8).clamp(8.0, 12.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
