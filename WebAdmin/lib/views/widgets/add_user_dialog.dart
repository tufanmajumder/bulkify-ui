import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:admin_app/controllers/user_controller.dart';
import 'package:admin_app/utils/responsive.dart';

class AddUserDrawer extends StatefulWidget {
  const AddUserDrawer({super.key});

  @override
  State<AddUserDrawer> createState() => _AddUserDrawerState();
}

class _AddUserDrawerState extends State<AddUserDrawer> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _mobNoController = TextEditingController();
  String? _selectedRole;
  String? _selectedStatus;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _mobNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserController controller = Get.find<UserController>();
    final drawerWidth = Responsive.isMobile(context)
        ? MediaQuery.of(context).size.width * 0.88
        : 420.0;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: drawerWidth,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                spreadRadius: 2,
                offset: Offset(-4, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Header with Title and Close 'X' Button
              Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 16.0,
                  top: 24.0,
                  bottom: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Add New User',
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 18),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: const Color(0xFF64748B),
                        size: Responsive.sp(context, 22),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Scrollable Form Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name
                        Text(
                          'Full Name',
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 13),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 14),
                            color: const Color(0xFF1E293B),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Full name is required'
                              : null,
                          decoration: InputDecoration(
                            hintText: 'John Doe',
                            hintStyle: TextStyle(
                              fontSize: Responsive.sp(context, 14),
                              color: const Color(0xFF94A3B8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCF4340),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFEF4444),
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email Address
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 13),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 14),
                            color: const Color(0xFF1E293B),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!GetUtils.isEmail(value.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'john.doe@example.com',
                            hintStyle: TextStyle(
                              fontSize: Responsive.sp(context, 14),
                              color: const Color(0xFF94A3B8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCF4340),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFEF4444),
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Contact Field
                        Text(
                          'Contact',
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 13),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _contactController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 14),
                            color: const Color(0xFF1E293B),
                          ),
                          decoration: InputDecoration(
                            hintText: '202 555 0111',
                            hintStyle: TextStyle(
                              fontSize: Responsive.sp(context, 14),
                              color: const Color(0xFF94A3B8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCF4340),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Select Role Dropdown
                        Text(
                          'Select Role',
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 13),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedRole,
                          hint: Text(
                            'Select Role',
                            style: TextStyle(
                              fontSize: Responsive.sp(context, 14),
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 14),
                            color: const Color(0xFF1E293B),
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: const Color(0xFF64748B),
                            size: Responsive.sp(context, 20),
                          ),
                          items: ['Driver', 'Support Admin']
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() => _selectedRole = val);
                          },
                          validator: (value) =>
                              value == null ? 'Please select a role' : null,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCF4340),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFEF4444),
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Select Status Dropdown
                        Text(
                          'Select Status',
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 13),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedStatus,
                          hint: Text(
                            'Select Status',
                            style: TextStyle(
                              fontSize: Responsive.sp(context, 14),
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 14),
                            color: const Color(0xFF1E293B),
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: const Color(0xFF64748B),
                            size: Responsive.sp(context, 20),
                          ),
                          items: ['Active', 'Inactive', 'Pending']
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() => _selectedStatus = val);
                          },
                          validator: (value) =>
                              value == null ? 'Please select a status' : null,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCF4340),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFEF4444),
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Action Buttons: Submit & Cancel
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  controller.addUser(
                                    name: _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    contact: _contactController.text.trim(),
                                    role: _selectedRole!,
                                    status: _selectedStatus!,
                                    mobNo: _mobNoController.text.trim(),
                                  );
                                  Navigator.of(context).pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFCF4340),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                              ),
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: Responsive.sp(context, 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F5F9),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                  fontSize: Responsive.sp(context, 14),
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}

/// Helper function to open the Add User slide-over drawer panel with slide animation and dimmed backdrop
void showAddUserDrawer(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss Add User Drawer',
    barrierColor: const Color(0x73000000),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, anim1, anim2) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, anim1, anim2, child) {
      final curvedValue = CurvedAnimation(
        parent: anim1,
        curve: Curves.easeOutCubic,
      ).value;
      return Transform.translate(
        offset: Offset((1.0 - curvedValue) * 420, 0),
        child: const AddUserDrawer(),
      );
    },
  );
}
