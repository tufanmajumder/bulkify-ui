import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/controllers/user_controller.dart';
import 'package:admin_app/utils/responsive.dart';
import 'add_user_dialog.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController controller = Get.find<UserController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        final double controlHeight = 38.0;
        final fontSize = Responsive.sp(context, 13);
        final borderColor = const Color(0xFFE2E8F0);
        final mutedTextColor = const Color(0xFF94A3B8);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            border: Border.all(color: borderColor),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Left Controls Group: Page size selector (10 v) + Export button
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Obx(
                    () => Container(
                      height: controlHeight,
                      width: 72,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: controller.rowsPerPage.value,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: mutedTextColor,
                            size: 20,
                          ),
                          style: TextStyle(
                            color: const Color(0xFF475569),
                            fontSize: fontSize,
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              controller.setRowsPerPage(newValue);
                            }
                          },
                          items: <int>[5, 10, 20, 50]
                              .map<DropdownMenuItem<int>>((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value'),
                                );
                              })
                              .toList(),
                        ),
                      ),
                    ),
                  ),

                  // Export Button (Export ⬆)
                  OutlinedButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'Export',
                        'Exporting user data...',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: Text(
                      'Export',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        fontSize: fontSize,
                      ),
                    ),
                    label: const Icon(
                      Icons.download_outlined,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8EBEF),
                      side: BorderSide.none,
                      elevation: 0,
                      minimumSize: Size(0, controlHeight),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),

              // Filter Controls Group (Search + Select Role + Select Status + Add New User)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Search User Field
                  SizedBox(
                    width: isMobile ? (constraints.maxWidth - 40) : 240.0,
                    height: controlHeight,
                    child: TextField(
                      onChanged: (val) => controller.setSearchQuery(val),
                      style: TextStyle(
                        fontSize: fontSize,
                        color: const Color(0xFF1E293B),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search User',
                        hintStyle: TextStyle(
                          color: mutedTextColor,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 0,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFCF4340),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Select Role Dropdown
                  Obx(() {
                    final dynamicRoles = controller.roles
                        .map((r) => r.roleName)
                        .toList();
                    final List<String> roleItems = [
                      'Select Role',
                      ...dynamicRoles,
                    ];
                    final currentRole =
                        roleItems.contains(controller.selectedRole.value)
                        ? controller.selectedRole.value
                        : 'Select Role';

                    return Container(
                      height: controlHeight,
                      width: isMobile ? (constraints.maxWidth - 40) : 190.0,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: controller.selectedRole.value == 'All'
                              ? 'Select Role'
                              : currentRole,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: mutedTextColor,
                            size: 20,
                          ),
                          style: TextStyle(
                            color:
                                (controller.selectedRole.value == 'All' ||
                                    controller.selectedRole.value ==
                                        'Select Role')
                                ? mutedTextColor
                                : const Color(0xFF475569),
                            fontSize: fontSize,
                            fontWeight: FontWeight.w400,
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              controller.setSelectedRole(
                                newValue == 'Select Role' ? 'All' : newValue,
                              );
                            }
                          },
                          items: roleItems.map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: value == 'Select Role'
                                      ? mutedTextColor
                                      : const Color(0xFF475569),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }),

                  // Status Dropdown
                  Obx(
                    () => Container(
                      height: controlHeight,
                      width: isMobile ? (constraints.maxWidth - 40) : 190.0,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value:
                              (controller.selectedStatus.value == 'All' ||
                                  controller.selectedStatus.value ==
                                      'Select Status')
                              ? 'Online Status'
                              : controller.selectedStatus.value,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: mutedTextColor,
                            size: 20,
                          ),
                          style: TextStyle(
                            color:
                                (controller.selectedStatus.value == 'All' ||
                                    controller.selectedStatus.value ==
                                        'Select Status' ||
                                    controller.selectedStatus.value ==
                                        'Online Status')
                                ? mutedTextColor
                                : const Color(0xFF475569),
                            fontSize: fontSize,
                            fontWeight: FontWeight.w400,
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              controller.setSelectedStatus(
                                newValue == 'Online Status' ? 'All' : newValue,
                              );
                            }
                          },
                          items: <String>['Online Status', 'Online', 'Offline']
                              .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color: value == 'Online Status'
                                          ? mutedTextColor
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ),
                    ),
                  ),

                  // Add New User Button
                  ElevatedButton.icon(
                    onPressed: () {
                      showAddUserDrawer(context);
                    },
                    icon: const Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Add New User',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: fontSize,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCF4340),
                      elevation: 0,
                      minimumSize: Size(0, controlHeight),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
