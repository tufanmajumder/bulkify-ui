import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/models/user_model.dart';
import 'package:admin_app/service/user_service.dart';
import 'package:admin_app/controllers/user_controller.dart';

class UserProfileController extends GetxController {
  // Loading & State
  final RxBool isLoading = false.obs;
  final RxString userkey = ''.obs;

  // User Profile Basic & Personal Info (Reactive)
  final RxString name = ''.obs;
  final RxString basicName = ''.obs;
  final RxString email = ''.obs;
  final RxString role = ''.obs;
  final RxString status = ''.obs;
  final RxString mobile = ''.obs;
  final RxString emergencyContact = ''.obs;
  final RxString whatsapp = ''.obs;
  final RxString avatarUrl = 'assets/user_avatar.jpg'.obs;
  final RxString tasksDone = '-'.obs;
  final RxString projectsDone = '-'.obs;

  // Tabs state
  final RxInt selectedTabIndex = 0.obs;
  final List<Map<String, dynamic>> tabs = [
    {'title': 'Overview', 'icon': Icons.group_outlined},
    {'title': 'Security', 'icon': Icons.lock_outline},
    {'title': 'Billing & Plans', 'icon': Icons.bookmark_border},
    {'title': 'Notifications', 'icon': Icons.notifications_none_outlined},
    {'title': 'Connections', 'icon': Icons.link},
  ];

  // Invoices & Pagination State
  final RxList<Map<String, String>> invoices = <Map<String, String>>[].obs;
  final RxInt rowsPerPage = 10.obs;
  final RxInt currentPage = 3.obs;
  final RxString invoiceSearchQuery = ''.obs;

  // Security Tab State
  final RxBool twoFactorEnabled = true.obs;
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Billing Tab State
  final RxString currentPlan = 'Standard Admin Plan'.obs;
  final RxString planBillingCycle = 'Monthly'.obs;
  final RxString planPrice = '\$49/month'.obs;
  final RxString cardLastFour = '4242'.obs;
  final RxString cardExpiry = '12/28'.obs;

  // Notifications Tab State
  final RxBool emailNotifications = true.obs;
  final RxBool pushNotifications = true.obs;
  final RxBool smsAlerts = false.obs;
  final RxBool marketingEmails = false.obs;

  // Connections Tab State
  final RxList<Map<String, dynamic>> connectedApps = <Map<String, dynamic>>[
    {
      'name': 'Google Account',
      'description': 'Calendar and Contacts Sync',
      'connected': true,
      'icon': Icons.g_mobiledata,
    },
    {
      'name': 'GitHub',
      'description': 'Repository and CI/CD Integrations',
      'connected': true,
      'icon': Icons.code,
    },
    {
      'name': 'Slack Workspace',
      'description': 'Real-time alert notifications',
      'connected': false,
      'icon': Icons.chat_bubble_outline,
    },
    {
      'name': 'Zoom',
      'description': 'Automated meeting scheduling',
      'connected': false,
      'icon': Icons.video_camera_front_outlined,
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is UserModel && args.id.isNotEmpty) {
      userkey.value = args.id;
      setUserModel(args);
    } else if (args is String && args.trim().isNotEmpty) {
      userkey.value = args.trim();
    } else if (args is Map && args.containsKey('userkey')) {
      userkey.value = args['userkey'].toString();
    }

    // Lookup in UserController if registered & fields are empty
    if (userkey.value.isNotEmpty && Get.isRegistered<UserController>()) {
      try {
        final userCtrl = Get.find<UserController>();
        final matched = userCtrl.users.firstWhereOrNull(
          (u) => u.id == userkey.value || u.userKey == userkey.value,
        );
        if (matched != null) {
          setUserModel(matched);
        }
      } catch (_) {}
    }

    if (kDebugMode) {
      debugPrint('[UserProfileController] userkey: ${userkey.value}');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userkey.value.isNotEmpty) {
        fetchUserDetails(userkey.value);
      }
    });
    _loadInitialInvoices();
  }

  /// Calls ApiManager.userDetails (users/v1/get-by-key) via UserService with userkey & token.
  Future<void> fetchUserDetails([String? targetUserKey]) async {
    final String keyToFetch =
        (targetUserKey != null && targetUserKey.trim().isNotEmpty)
        ? targetUserKey.trim()
        : userkey.value;
    if (keyToFetch.isEmpty) return;

    isLoading.value = true;
    try {
      final UserService userService = Get.isRegistered<UserService>()
          ? Get.find<UserService>()
          : Get.put(UserService());

      final result = await userService.getUserDetails(userkey: keyToFetch);
      if (result.isTokenExpired) {
        Get.offAllNamed('/login');
        return;
      }

      if (result.user != null) {
        setUserModel(result.user!);
      }
      if (result.rawData != null) {
        populateFromRawMap(result.rawData!);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[UserProfileController] Error in fetchUserDetails: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void setUserModel(UserModel u) {
    if (u.name.isNotEmpty) {
      name.value = u.name;
      basicName.value = u.name;
    }
    if (u.email.isNotEmpty) email.value = u.email;
    if (u.role.isNotEmpty) role.value = u.role;
    if (u.status.isNotEmpty) status.value = u.status;
    final mob = u.mobNo.isNotEmpty ? u.mobNo : (u.contact ?? '');
    if (mob.isNotEmpty) {
      mobile.value = mob;
      emergencyContact.value = mob;
      whatsapp.value = mob;
    }
  }

  void populateFromRawMap(Map<String, dynamic> raw) {
    final nameVal =
        raw['name']?.toString() ??
        raw['fullname']?.toString() ??
        raw['full_name']?.toString() ??
        raw['first_name']?.toString() ??
        raw['display_name']?.toString() ??
        raw['userName']?.toString() ??
        raw['username']?.toString() ??
        raw['user_name']?.toString() ??
        '';
    if (nameVal.isNotEmpty && nameVal != 'null') {
      name.value = nameVal;
      basicName.value = nameVal;
    }

    final emailVal =
        raw['email']?.toString() ??
        raw['emailid']?.toString() ??
        raw['email_id']?.toString() ??
        raw['emailAddress']?.toString() ??
        raw['email_address']?.toString() ??
        '';
    if (emailVal.isNotEmpty && emailVal != 'null') {
      email.value = emailVal;
    }

    final roleVal =
        raw['rolename']?.toString() ??
        raw['role_name']?.toString() ??
        raw['roleName']?.toString() ??
        raw['role_title']?.toString() ??
        raw['user_role']?.toString() ??
        raw['role']?.toString() ??
        '';
    if (roleVal.isNotEmpty && roleVal != 'null') {
      role.value = roleVal;
    }

    final statusVal =
        raw['status']?.toString() ??
        raw['user_status']?.toString() ??
        raw['is_active']?.toString() ??
        '';
    if (statusVal.isNotEmpty && statusVal != 'null') {
      if (statusVal == '1' ||
          statusVal.toLowerCase() == 'active' ||
          statusVal.toLowerCase() == 'true') {
        status.value = 'Active';
      } else if (statusVal == '0' ||
          statusVal.toLowerCase() == 'inactive' ||
          statusVal.toLowerCase() == 'false') {
        status.value = 'Inactive';
      } else {
        status.value = statusVal;
      }
    }

    final mobVal =
        raw['mobile']?.toString() ??
        raw['mobNo']?.toString() ??
        raw['mob_no']?.toString() ??
        raw['mobile_no']?.toString() ??
        raw['mobile_number']?.toString() ??
        raw['contact']?.toString() ??
        raw['phone']?.toString() ??
        raw['phone_number']?.toString() ??
        '';
    if (mobVal.isNotEmpty && mobVal != 'null') {
      mobile.value = mobVal;
      final emergencyVal =
          raw['emergency_contact']?.toString() ??
          raw['emergencyContact']?.toString() ??
          raw['emergency_phone']?.toString() ??
          raw['emergency_mobile']?.toString() ??
          raw['alt_contact']?.toString() ??
          mobVal;
      emergencyContact.value =
          (emergencyVal.isNotEmpty && emergencyVal != 'null')
          ? emergencyVal
          : mobVal;

      final waVal =
          raw['whatsapp']?.toString() ??
          raw['whatsapp_no']?.toString() ??
          raw['whatsapp_number']?.toString() ??
          raw['whatsapp_phone']?.toString() ??
          mobVal;
      whatsapp.value = (waVal.isNotEmpty && waVal != 'null') ? waVal : mobVal;
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void _loadInitialInvoices() {
    final List<Map<String, String>> baseInvoices = [
      // {'id': '#4910', 'total': '₹ 3428', 'date': '22-10-2019'},
      // {'id': '#4911', 'total': '₹ 2875', 'date': '23-10-2019'},
      // {'id': '#4912', 'total': '₹ 3150', 'date': '24-10-2019'},
      // {'id': '#4913', 'total': '₹ 3980', 'date': '25-10-2019'},
      // {'id': '#4914', 'total': '₹ 2500', 'date': '26-10-2019'},
      // {'id': '#4915', 'total': '₹ 4500', 'date': '27-10-2019'},
      // {'id': '#4916', 'total': '₹ 3700', 'date': '28-10-2019'},
      // {'id': '#4917', 'total': '₹ 4300', 'date': '29-10-2019'},
      // {'id': '#4918', 'total': '₹ 3600', 'date': '30-10-2019'},
      // {'id': '#4919', 'total': '₹ 2900', 'date': '31-10-2019'},
    ];

    // Expand to 50 items for pagination matching screenshot
    final List<Map<String, String>> extended = [];
    for (int i = 0; i < 5; i++) {
      for (var inv in baseInvoices) {
        final idNum = 4910 + extended.length;
        extended.add({
          'id': '#$idNum',
          'total': inv['total']!,
          'date': inv['date']!,
        });
      }
    }
    invoices.assignAll(extended);
  }

  // Filtered Invoices
  List<Map<String, String>> get filteredInvoices {
    if (invoiceSearchQuery.value.isEmpty) {
      return invoices;
    }
    final q = invoiceSearchQuery.value.toLowerCase();
    return invoices.where((inv) {
      return inv['id']!.toLowerCase().contains(q) ||
          inv['total']!.toLowerCase().contains(q) ||
          inv['date']!.toLowerCase().contains(q);
    }).toList();
  }

  // Paginated Invoices
  List<Map<String, String>> get paginatedInvoices {
    final list = filteredInvoices;
    if (list.isEmpty) return [];

    final startIndex = (currentPage.value - 1) * rowsPerPage.value;
    if (startIndex >= list.length) return [];

    final endIndex = (startIndex + rowsPerPage.value).clamp(0, list.length);
    return list.sublist(startIndex, endIndex);
  }

  int get totalPages {
    if (filteredInvoices.isEmpty) return 1;
    return (filteredInvoices.length / rowsPerPage.value).ceil();
  }

  int get startEntryIndex => filteredInvoices.isEmpty
      ? 0
      : (currentPage.value - 1) * rowsPerPage.value + 1;

  int get endEntryIndex {
    final end = currentPage.value * rowsPerPage.value;
    return end > filteredInvoices.length ? filteredInvoices.length : end;
  }

  // Tab Action
  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  // Invoice Pagination & Actions
  void setPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void setRowsPerPage(int rows) {
    rowsPerPage.value = rows;
    currentPage.value = 1;
  }

  void deleteInvoice(String id) {
    invoices.removeWhere((inv) => inv['id'] == id);
    Get.snackbar(
      'Deleted',
      'Invoice $id has been deleted',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void exportInvoices() {
    Get.snackbar(
      'Export Successful',
      'Exported ${filteredInvoices.length} invoices to CSV',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFCF4340),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  void viewInvoice(String id) {
    final inv = invoices.firstWhereOrNull((item) => item['id'] == id);
    if (inv != null) {
      Get.defaultDialog(
        title: 'Invoice Details',
        titleStyle: const TextStyle(fontWeight: FontWeight.bold),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invoice ID: ${inv['id']}'),
              const SizedBox(height: 8),
              Text('Total Amount: ${inv['total']}'),
              const SizedBox(height: 8),
              Text('Issued Date: ${inv['date']}'),
              const SizedBox(height: 8),
              const Text(
                'Status: Paid',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        textConfirm: 'Close',
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFFCF4340),
        onConfirm: () => Get.back(),
      );
    }
  }

  // Profile Actions
  void toggleSuspendStatus() {
    if (status.value == 'Active') {
      status.value = 'Suspended';
      Get.snackbar(
        'Account Suspended',
        'User ${name.value} is now suspended.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } else {
      status.value = 'Active';
      Get.snackbar(
        'Account Activated',
        'User ${name.value} is now Active.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void updateProfileInfo({
    required String newName,
    required String newEmail,
    required String newMobile,
    required String newRole,
    required String newEmergency,
    required String newWhatsapp,
  }) {
    name.value = newName;
    email.value = newEmail;
    mobile.value = newMobile;
    role.value = newRole;
    emergencyContact.value = newEmergency;
    whatsapp.value = newWhatsapp;

    Get.snackbar(
      'Profile Updated',
      'User profile updated successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  // Security Actions
  void changePassword() {
    final currentPass = currentPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all password fields.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPass.length < 8) {
      Get.snackbar(
        'Error',
        'New password must be at least 8 characters.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPass != confirmPass) {
      Get.snackbar(
        'Error',
        'New password and confirmation do not match.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();

    Get.snackbar(
      'Success',
      'Password updated successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  void toggleTwoFactor(bool value) {
    twoFactorEnabled.value = value;
    Get.snackbar(
      '2FA Update',
      value
          ? 'Two-Factor Authentication Enabled'
          : 'Two-Factor Authentication Disabled',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Connection Actions
  void toggleAppConnection(int index) {
    final current = connectedApps[index]['connected'] as bool;
    connectedApps[index]['connected'] = !current;
    connectedApps.refresh();
    final appName = connectedApps[index]['name'];
    Get.snackbar(
      'Connection Updated',
      !current ? 'Connected to $appName' : 'Disconnected from $appName',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
