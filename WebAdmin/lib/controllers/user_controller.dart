import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:admin_app/models/user_model.dart';
import 'package:admin_app/service/user_service.dart';
import 'package:admin_app/utils/api_manager.dart';

class UserController extends GetxController {
  // Reactive list of all users
  final RxList<UserModel> users = <UserModel>[].obs;

  // Reactive list of dynamic roles from API
  final RxList<RoleModel> roles = <RoleModel>[].obs;

  // Summary state from API
  final Rxn<UserSummaryModel> summary = Rxn<UserSummaryModel>();

  // Loading, Submitting & Error states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingRoles = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  // Search and Filter states
  final RxString searchQuery = ''.obs;
  final RxString selectedRole = 'All'.obs;
  final RxString selectedStatus = 'All'.obs;

  // Pagination states
  final RxInt currentPage = 1.obs;
  final RxInt rowsPerPage = 10.obs;

  late final UserService _userService;

  @override
  void onInit() {
    super.onInit();
    _userService = Get.isRegistered<UserService>()
        ? Get.find<UserService>()
        : Get.put(UserService());
    fetchUsers();
    fetchRoles();
  }

  /// Calls getRoleList API from ApiManager (via UserService) and updates roles list.
  Future<void> fetchRoles() async {
    isLoadingRoles.value = true;
    try {
      final result = await _userService.getRoleList();
      if (result.isTokenExpired) {
        errorMessage.value = 'Session expired. Please log in again.';
        Get.offAllNamed('/login');
        return;
      }
      if (result.success || result.code == 200) {
        if (result.roles.isNotEmpty) {
          roles.assignAll(result.roles);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[UserController] Error fetching roles: $e');
      }
    } finally {
      isLoadingRoles.value = false;
    }
  }

  /// Calls getUserList API from ApiManager (via UserService) and updates user list & summary.
  Future<void> fetchUsers() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _userService.getUserList();

      if (result.isTokenExpired) {
        errorMessage.value = 'Session expired. Please log in again.';
        Get.offAllNamed('/login');
        return;
      }

      if (result.success || result.code == 200) {
        if (result.summary != null) {
          summary.value = result.summary;
        }
        if (result.users.isNotEmpty) {
          users.assignAll(result.users);
        } else {
          // If backend returns empty list, fall back to initial data for demo/preview
          _loadInitialUsers();
        }
        currentPage.value = 1;
      } else {
        errorMessage.value = result.message;
        if (users.isEmpty) {
          _loadInitialUsers();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[UserController] Error fetching users: $e');
      }
      errorMessage.value = 'Failed to load users';
      if (users.isEmpty) {
        _loadInitialUsers();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _loadInitialUsers() {
    // Demo data uses clearly fictional identifiers (example.com, 90000XXXXX)
    // to comply with data minimisation principles.
    // Replace with a real API call when the Users API endpoint is available.
    final List<UserModel> initialData = [
      // UserModel(
      //   id: '1',
      //   name: 'Demo User 01',
      //   email: 'user01@example.com',
      //   role: 'Driver',
      //   lastLogin: '20-08-2026 12:00 PM',
      //   status: 'Active',
      //   mobNo: '9000000001',
      // ),
      // UserModel(
      //   id: '2',
      //   name: 'Demo User 02',
      //   email: 'user02@example.com',
      //   role: 'Pilot',
      //   lastLogin: '22-08-2026 03:00 PM',
      //   status: 'Active',
      //   mobNo: '9000000002',
      // ),
      // UserModel(
      //   id: '3',
      //   name: 'Demo User 03',
      //   email: 'user03@example.com',
      //   role: 'Scheduler',
      //   lastLogin: '15-09-2026 3:00 PM',
      //   status: 'Inactive',
      //   mobNo: '9000000003',
      // ),
      // UserModel(
      //   id: '4',
      //   name: 'Demo User 04',
      //   email: 'user04@example.com',
      //   role: 'Manager',
      //   lastLogin: '01-10-2026 9:00 AM',
      //   status: 'Active',
      //   mobNo: '9000000004',
      // ),
      // UserModel(
      //   id: '5',
      //   name: 'Demo User 05',
      //   email: 'user05@example.com',
      //   role: 'Designer',
      //   lastLogin: '25-10-2026 1:30 PM',
      //   status: 'Active',
      //   mobNo: '9000000005',
      // ),
      // UserModel(
      //   id: '6',
      //   name: 'Demo User 06',
      //   email: 'user06@example.com',
      //   role: 'Developer',
      //   lastLogin: '05-11-2026 4:15 PM',
      //   status: 'Inactive',
      //   mobNo: '9000000006',
      // ),
      // UserModel(
      //   id: '7',
      //   name: 'Demo User 07',
      //   email: 'user07@example.com',
      //   role: 'Analyst',
      //   lastLogin: '10-12-2026 10:00 AM',
      //   status: 'Active',
      //   mobNo: '9000000007',
      // ),
      // UserModel(
      //   id: '8',
      //   name: 'Demo User 08',
      //   email: 'user08@example.com',
      //   role: 'Representative',
      //   lastLogin: '20-01-2027 2:45 PM',
      //   status: 'Active',
      //   mobNo: '9000000008',
      // ),
      // UserModel(
      //   id: '9',
      //   name: 'Demo User 09',
      //   email: 'user09@example.com',
      //   role: 'Researcher',
      //   lastLogin: '30-01-2027 11:00 AM',
      //   status: 'Inactive',
      //   mobNo: '9000000009',
      // ),
      // UserModel(
      //   id: '10',
      //   name: 'Demo User 10',
      //   email: 'user10@example.com',
      //   role: 'Admin',
      //   lastLogin: '15-02-2027 10:30 AM',
      //   status: 'Active',
      //   mobNo: '9000000010',
      // ),
    ];

    // Populate 50 entries to demonstrate real pagination
    final List<UserModel> extendedData = [];
    for (int i = 0; i < 5; i++) {
      for (var u in initialData) {
        extendedData.add(
          UserModel(
            id: '${extendedData.length + 1}',
            userName: u.userName,
            name: u.name,
            email: u.email,
            role: u.role,
            lastLogin: u.lastLogin,
            status: u.status,
            mobNo: u.mobNo,
            isOnline: u.isOnline,
          ),
        );
      }
    }

    users.assignAll(extendedData);
  }

  // Filtered Users Getter
  List<UserModel> get filteredUsers {
    return users.where((user) {
      final query = searchQuery.value.trim().toLowerCase();
      final cleanQueryDigits = query.replaceAll(RegExp(r'\D'), '');

      final matchesSearch =
          query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.userName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.mobNo.toLowerCase().contains(query) ||
          (user.contact != null &&
              user.contact!.toLowerCase().contains(query)) ||
          (cleanQueryDigits.isNotEmpty &&
              (user.mobNo
                      .replaceAll(RegExp(r'\D'), '')
                      .contains(cleanQueryDigits) ||
                  (user.contact != null &&
                      user.contact!
                          .replaceAll(RegExp(r'\D'), '')
                          .contains(cleanQueryDigits))));

      final matchesRole =
          selectedRole.value == 'All' ||
          selectedRole.value == 'Select Role' ||
          user.role == selectedRole.value;

      final matchesStatus =
          selectedStatus.value == 'All' ||
          selectedStatus.value == 'Select Status' ||
          selectedStatus.value == 'Online Status' ||
          (selectedStatus.value == 'Online' &&
              user.isOnline.toLowerCase() == 'true') ||
          (selectedStatus.value == 'Offline' &&
              user.isOnline.toLowerCase() != 'true');

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  // Paginated Users Getter
  List<UserModel> get paginatedUsers {
    final filtered = filteredUsers;
    if (filtered.isEmpty) return [];

    final startIndex = (currentPage.value - 1) * rowsPerPage.value;
    if (startIndex >= filtered.length) {
      return [];
    }
    final endIndex = (startIndex + rowsPerPage.value).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  int get totalPages {
    if (filteredUsers.isEmpty) return 1;
    return (filteredUsers.length / rowsPerPage.value).ceil();
  }

  int get startEntryIndex => filteredUsers.isEmpty
      ? 0
      : (currentPage.value - 1) * rowsPerPage.value + 1;

  int get endEntryIndex {
    final end = currentPage.value * rowsPerPage.value;
    return end > filteredUsers.length ? filteredUsers.length : end;
  }

  // Controller Actions
  void setSearchQuery(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
  }

  void setSelectedRole(String role) {
    selectedRole.value = role;
    currentPage.value = 1;
    final matchedRole = roles.firstWhereOrNull((r) => r.roleName == role);
    print("Selected Role: $role, roleKey: ${matchedRole?.roleKey ?? 'N/A'}");
    if (kDebugMode) {
      debugPrint(
        '[UserController] Selected Role: $role | roleKey: ${matchedRole?.roleKey}',
      );
    }
  }

  void setSelectedStatus(String status) {
    selectedStatus.value = status;
    currentPage.value = 1;
  }

  void setPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void setRowsPerPage(int rows) {
    rowsPerPage.value = rows;
    currentPage.value = 1;
  }

  /// Calls userAdd API endpoint (users/v1/add) via UserService with email, fullname, mobile, static rolekey and status
  Future<bool> addUser({
    required String name,
    required String email,
    required String mobile,
    String? role,
    String? status,
  }) async {
    isSubmitting.value = true;
    try {
      final int statusInt = status == 'Inactive' ? 0 : 1;

      final result = await _userService.addUser(
        email: email,
        fullname: name,
        mobile: mobile,
        rolekey: ApiManager.staticRoleKey,
        status: statusInt,
      );

      if (result.isTokenExpired) {
        Get.snackbar(
          'Session Expired',
          'Please log in again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed('/login');
        return false;
      }

      if (result.success) {
        Get.snackbar(
          'Success',
          result.message.isNotEmpty
              ? result.message
              : 'User "$name" added successfully!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        await fetchUsers();
        return true;
      } else {
        Get.snackbar(
          'Error',
          result.message.isNotEmpty ? result.message : 'Failed to add user',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[UserController] Error adding user: $e');
      }
      Get.snackbar(
        'Error',
        'An error occurred while adding user',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void deleteUser(String id) {
    final user = users.firstWhereOrNull((u) => u.id == id);
    if (user != null) {
      users.removeWhere((u) => u.id == id);
      Get.snackbar(
        'Deleted',
        'User "${user.name}" removed',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
