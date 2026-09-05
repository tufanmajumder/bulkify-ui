import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileController extends GetxController {
  // User Profile Basic & Personal Info (Reactive)
  final RxString name = 'Chrish Teigland'.obs;
  final RxString email = 'teigland1991@gmail.com'.obs;
  final RxString role = 'Driver'.obs;
  final RxString status = 'Active'.obs;
  final RxString mobile = '+91 98765 4321'.obs;
  final RxString emergencyContact = '+91 98765 01234'.obs;
  final RxString whatsapp = '+91 98765 01234'.obs;
  final RxString avatarUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'.obs;
  final RxString tasksDone = '1.23k'.obs;
  final RxString projectsDone = '568'.obs;

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
  final RxInt currentPage = 1.obs;
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
    _loadInitialInvoices();
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
      {'id': '#4910', 'total': '\$3428', 'date': '22 Oct 2026'},
      {'id': '#4909', 'total': '\$2872', 'date': '18 Oct 2026'},
      {'id': '#4908', 'total': '\$4077', 'date': '01 Feb 2026'},
      {'id': '#4907', 'total': '\$2060', 'date': '08 Dec 2025'},
      {'id': '#4906', 'total': '\$3128', 'date': '10 Sep 2025'},
      {'id': '#4905', 'total': '\$2032', 'date': '30 Nov 2025'},
      {'id': '#4904', 'total': '\$2230', 'date': '19 Nov 2025'},
      {'id': '#4903', 'total': '\$5612', 'date': '12 Apr 2025'},
      {'id': '#4902', 'total': '\$5293', 'date': '01 Aug 2025'},
      {'id': '#4901', 'total': '\$1980', 'date': '15 May 2025'},
    ];

    // Expand to 50 items for pagination testing
    final List<Map<String, String>> extended = [];
    for (int i = 0; i < 5; i++) {
      for (var inv in baseInvoices) {
        final idNum = 4910 - extended.length;
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
              const Text('Status: Paid', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
      value ? 'Two-Factor Authentication Enabled' : 'Two-Factor Authentication Disabled',
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
