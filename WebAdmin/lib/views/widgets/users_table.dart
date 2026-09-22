import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/controllers/user_controller.dart';
import 'package:admin_app/models/user_model.dart';
import 'package:admin_app/utils/responsive.dart';
import 'package:admin_app/views/user_profile_screen.dart';

class UsersTable extends StatelessWidget {
  const UsersTable({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController controller = Get.find<UserController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          final users = controller.paginatedUsers;
          final double minTableWidth = 1050.0;
          final double tableWidth = constraints.maxWidth < minTableWidth
              ? minTableWidth
              : constraints.maxWidth;
          final horizontalPadding = 20.0;
          final verticalPadding = 16.0;
          final borderColor = const Color(0xFFE2E8F0);

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: borderColor),
                right: BorderSide(color: borderColor),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  children: [
                    // Table Header Row
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: borderColor)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 20,
                            child: _buildHeaderCell(context, 'NAME'),
                          ),
                          Expanded(
                            flex: 20,
                            child: _buildHeaderCell(context, 'EMAIL'),
                          ),
                          Expanded(
                            flex: 15,
                            child: _buildHeaderCell(context, 'MOBILE'),
                          ),
                          Expanded(
                            flex: 15,
                            child: _buildHeaderCell(context, 'ROLE'),
                          ),
                          Expanded(
                            flex: 15,
                            child: _buildHeaderCell(context, 'LAST LOGIN'),
                          ),
                          Expanded(
                            flex: 10,
                            child: Center(
                              child: _buildHeaderCell(context, 'STATUS'),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: _buildHeaderCell(context, 'ACTION'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Loading state
                    if (controller.isLoading.value)
                      Container(
                        padding: const EdgeInsets.all(40),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFCF4340),
                          ),
                        ),
                      )
                    // Empty / Error State if no users
                    else if (users.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Text(
                            controller.errorMessage.value.isNotEmpty
                                ? controller.errorMessage.value
                                : 'No users found',
                            style: TextStyle(
                              color: const Color(0xFF94A3B8),
                              fontSize: Responsive.sp(context, 14),
                            ),
                          ),
                        ),
                      )
                    // Table Data Rows
                    else
                      ...users.map(
                        (user) => _buildDataRow(context, controller, user),
                      ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        color: const Color(0xFF475569),
        fontSize: Responsive.sp(context, 12),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildDataRow(
    BuildContext context,
    UserController controller,
    UserModel user,
  ) {
    final bool isActive = user.status.toLowerCase() == 'active';
    final horizontalPadding = 20.0;
    final verticalPadding = 16.0;
    final borderColor = const Color(0xFFF1F5F9);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NAME Column (20%)
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  color: user.isOnline == 'true'
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                  size: 8,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    user.name,
                    style: TextStyle(
                      color: const Color(0xFF475569),
                      fontSize: Responsive.sp(context, 13.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // EMAIL Column (20%)
          Expanded(
            flex: 20,
            child: Text(
              user.email,
              style: TextStyle(
                color: const Color(0xFF475569),
                fontSize: Responsive.sp(context, 13.5),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // MOBILE Column (15%)
          Expanded(
            flex: 15,
            child: Builder(
              builder: (context) {
                final rawMobile = user.mobNo.isNotEmpty
                    ? user.mobNo
                    : (user.contact ?? '');
                final cleanMobile = rawMobile
                    .replaceAll(RegExp(r'^\+91[\s-]*'), '')
                    .replaceAll('+91', '')
                    .trim();
                return Text(
                  cleanMobile.isNotEmpty ? cleanMobile : '-',
                  style: TextStyle(
                    color: const Color(0xFF475569),
                    fontSize: Responsive.sp(context, 13.5),
                    fontWeight: FontWeight.w400,
                  ),
                );
              },
            ),
          ),

          // ROLE Column (15%)
          Expanded(
            flex: 15,
            child: Text(
              user.role,
              style: TextStyle(
                color: const Color(0xFF475569),
                fontSize: Responsive.sp(context, 13.5),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // LAST LOGIN Column (15%)
          Expanded(
            flex: 15,
            child: Text(
              user.lastLogin.isNotEmpty ? user.lastLogin : '-',
              style: TextStyle(
                color: const Color(0xFF475569),
                fontSize: Responsive.sp(context, 13.5),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // STATUS Column (10%)
          Expanded(
            flex: 10,
            child: Text(
              textAlign: TextAlign.center,
              user.status,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444),
                fontSize: Responsive.sp(context, 13.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ACTION Column (5%)
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFF64748B),
                  size: 18,
                ),
                tooltip: 'Show Options',
                onSelected: (val) {
                  if (val == 'View Details') {
                    Get.to(
                      () => const UserProfileScreen(),
                      routeName: '/user-profile',
                      arguments: user,
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'View Details',
                    child: Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
