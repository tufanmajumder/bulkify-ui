import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/service/auth_service.dart';
import 'package:admin_app/views/order_list_screen.dart';
import 'package:admin_app/views/users_screen.dart';

class Sidebar extends StatefulWidget {
  final bool isDrawer;
  final String? activeRoute;
  const Sidebar({super.key, this.isDrawer = false, this.activeRoute});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _isHovered = false;

  @override
  void dispose() {
    _isHovered = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpanded = widget.isDrawer || _isHovered;
    final double collapsedWidth = 72.0;
    final double expandedWidth = 240.0;
    final double currentWidth = isExpanded ? expandedWidth : collapsedWidth;

    final currentRoute = widget.activeRoute ?? Get.currentRoute;
    final routeLower = currentRoute.toLowerCase();

    final isOrdersActive =
        currentRoute == '/orders' || routeLower.contains('order');
    final isUsersActive =
        currentRoute == '/users' ||
        currentRoute == '/user-profile' ||
        routeLower.contains('user');
    final isDashboardActive =
        currentRoute == '/dashboard' ||
        (currentRoute == '/' && !isOrdersActive);

    return MouseRegion(
      onEnter: (_) {
        if (!widget.isDrawer && !_isHovered) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isHovered = true;
              });
            }
          });
        }
      },
      onExit: (_) {
        if (!widget.isDrawer && _isHovered) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isHovered = false;
              });
            }
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: currentWidth,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isExpanded ? 0.08 : 0.04),
              blurRadius: isExpanded ? 16 : 4,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 16.0 : 14.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: isExpanded
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                // Brand Logo Area
                _buildLogo(isExpanded),
                const SizedBox(height: 28),

                // Navigation Items
                _buildNavItem(
                  icon: Icons.home_outlined,
                  label: 'Dashboard',
                  isSelected:
                      isDashboardActive && !isOrdersActive && !isUsersActive,
                  isExpanded: isExpanded,
                  onTap: () {
                    Get.offAll(
                      () => const UsersScreen(),
                      routeName: '/dashboard',
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildNavItem(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Orders',
                  isSelected: isOrdersActive,
                  isExpanded: isExpanded,
                  onTap: () {
                    Get.offAll(
                      () => const OrderListScreen(),
                      routeName: '/orders',
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildNavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Users',
                  isSelected: isUsersActive,
                  isExpanded: isExpanded,
                  onTap: () {
                    Get.offAll(() => const UsersScreen(), routeName: '/users');
                  },
                ),
                const SizedBox(height: 12),
                _buildNavItem(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  isSelected: false,
                  isExpanded: isExpanded,
                  onTap: () async {
                    await AuthService.clearAuthToken();
                    Get.offAllNamed('/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isExpanded) {
    if (!isExpanded) {
      return SizedBox(
        height: 40,
        width: 44,
        child: Center(
          child: Image.asset(
            'bulkifyShortLogo.png',
            height: 32,
            width: 32,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.storefront_rounded,
              color: Color(0xFFCF4340),
              size: 28,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 40,
      width: double.infinity,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Image.asset(
          'bulkifyLogo.png',
          height: 36,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Text(
            'BULKIFY',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFCF4340),
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    final activeBg = const Color(0xFFCF4340);

    if (!isExpanded) {
      // Collapsed Icon-Only Button (44x44 centered)
      return InkWell(
        onTap: onTap,
        hoverColor: isSelected ? Colors.transparent : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeBg.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              size: 22,
            ),
          ),
        ),
      );
    }

    // Expanded Full Menu Button
    return InkWell(
      onTap: onTap,
      hoverColor: isSelected ? Colors.transparent : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 44,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeBg.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
