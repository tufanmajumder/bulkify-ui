import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/controllers/user_controller.dart';
import 'package:admin_app/models/user_model.dart';
import 'package:admin_app/utils/responsive.dart';

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
                            flex: 3,
                            child: _buildHeaderCell(context, 'NAME'),
                          ),
                          Expanded(
                            flex: 4,
                            child: _buildHeaderCell(context, 'EMAIL'),
                          ),
                          Expanded(
                            flex: 2,
                            child: _buildHeaderCell(context, 'MOBILE'),
                          ),
                          Expanded(
                            flex: 2,
                            child: _buildHeaderCell(context, 'ROLE'),
                          ),
                          Expanded(
                            flex: 3,
                            child: _buildHeaderCell(context, 'LAST LOGIN'),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: _buildHeaderCell(context, 'STATUS'),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: _buildHeaderCell(context, 'ACTION'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Empty State if no users
                    if (users.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Text(
                            'No users found matching criteria.',
                            style: TextStyle(
                              color: const Color(0xFF94A3B8),
                              fontSize: Responsive.sp(context, 14),
                            ),
                          ),
                        ),
                      ),

                    // Table Data Rows
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
        children: [
          // NAME Column
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(Icons.circle, color: Colors.grey[600], size: 8),
                const SizedBox(width: 6),
                Text(
                  user.name,
                  style: TextStyle(
                    color: const Color(0xFF475569),
                    fontSize: Responsive.sp(context, 13.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // EMAIL Column
          Expanded(
            flex: 4,
            child: Text(
              user.email,
              style: TextStyle(
                color: const Color(0xFF475569),
                fontSize: Responsive.sp(context, 13.5),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // MOBILE Column
          Expanded(
            flex: 2,
            child: Text(
              user.mobNo.isNotEmpty ? user.mobNo : (user.contact ?? '-'),
              style: TextStyle(
                color: const Color(0xFF475569),
                fontSize: Responsive.sp(context, 13.5),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // ROLE Column
          Expanded(
            flex: 2,
            child: Text(
              user.role,
              style: TextStyle(
                color: const Color(0xFF475569),
                fontSize: Responsive.sp(context, 13.5),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // LAST LOGIN Column
          Expanded(
            flex: 3,
            child: Text(
              user.lastLogin,
              style: TextStyle(
                color: const Color(0xFF475569),
                fontSize: Responsive.sp(context, 13.5),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // STATUS Column (Plain colored text as shown in screenshot)
          Expanded(
            flex: 2,
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

          // ACTION Column (3-dots vertical icon)
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
