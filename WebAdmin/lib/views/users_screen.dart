import 'package:admin_app/views/widgets/pagination.dart';
import 'package:admin_app/views/widgets/users_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/controllers/user_controller.dart';
import 'package:admin_app/utils/responsive.dart';
import 'widgets/sidebar.dart';
import 'widgets/header.dart';
import 'widgets/stat_cards.dart';
import 'widgets/filter_bar.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate GetX Controller hjh
    Get.put(UserController());

    final isMobileOrTablet =
        Responsive.isMobile(context) || Responsive.isTablet(context);
    final dynamicPadding = Responsive.dynamicPadding(context);
    final spacingHeight = Responsive.h(context, 3).clamp(16.0, 32.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      drawer: isMobileOrTablet
          ? const Drawer(
              backgroundColor: Colors.white,
              child: Sidebar(isDrawer: true, activeRoute: '/users'),
            )
          : null,
      body: Stack(
        children: [
          // Main Section (Header + Body)
          Padding(
            padding: EdgeInsets.only(left: isMobileOrTablet ? 0.0 : 72.0),
            child: Column(
              children: [
                // Top Navigation Header Bar
                const Header(),

                // Scrollable Content Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(dynamicPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stat Summary Cards (Responsive Grid)
                        const StatCards(),
                        SizedBox(height: spacingHeight),

                        // Users Content Box (Filter Bar + Table + Pagination)
                        const Column(
                          children: [
                            FilterBar(),
                            UsersTable(),
                            PaginationControls(),
                          ],
                        ),
                        SizedBox(height: spacingHeight * 1.2),

                        // Page Footer
                        Container(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: Responsive.sp(context, 13),
                                  color: const Color(0xFF64748B),
                                ),
                                children: const [
                                  TextSpan(text: '© Developed by '),
                                  TextSpan(
                                    text: 'Digital Trident Solutions LLC',
                                    style: TextStyle(
                                      color: Color(0xFFCF4340),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Left Sidebar Overlay (Desktop > 1024px)
          if (!isMobileOrTablet)
            const Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Sidebar(activeRoute: '/users'),
            ),
        ],
      ),
    );
  }
}
