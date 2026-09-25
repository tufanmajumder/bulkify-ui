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
  Future<void> fetchUsers({int page = 1, int? perpage}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _userService.getUserList(page: 1, perpage: 500);

      if (result.isTokenExpired) {
        errorMessage.value = 'Session expired. Please log in again.';
        Get.offAllNamed('/login');
        return;
      }

      if (result.success || result.code == 200) {
        if (result.summary != null) {
          summary.value = result.summary;
        }
        users.assignAll(result.users);
        if (currentPage.value > totalPages) {
          currentPage.value = 1;
        }
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
    final List<UserModel> initialData = [];

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
          user.role.toLowerCase() == selectedRole.value.toLowerCase();

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

  // Paginated Users Getter for the current page
  List<UserModel> get paginatedUsers {
    final list = filteredUsers;
    if (list.isEmpty) return [];
    final start = (currentPage.value - 1) * rowsPerPage.value;
    if (start >= list.length) return [];
    final end = (start + rowsPerPage.value).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int get totalPages {
    final count = filteredUsers.length;
    if (count == 0) return 1;
    return (count / rowsPerPage.value).ceil();
  }

  bool get hasMorePage => currentPage.value < totalPages;

  int get startEntryIndex {
    if (filteredUsers.isEmpty) return 0;
    return (currentPage.value - 1) * rowsPerPage.value + 1;
  }

  int get endEntryIndex {
    if (filteredUsers.isEmpty) return 0;
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
    if (page >= 1 &&
        page <= totalPages &&
        page != currentPage.value &&
        !isLoading.value) {
      currentPage.value = page;
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages && !isLoading.value) {
      currentPage.value = currentPage.value + 1;
    }
  }

  void prevPage() {
    if (currentPage.value > 1 && !isLoading.value) {
      currentPage.value = currentPage.value - 1;
    }
  }

  void setRowsPerPage(int rows) {
    rowsPerPage.value = rows;
    currentPage.value = 1;
  }

  /// Calls userAdd API endpoint (users/v1/add) via UserService with email, fullname, mobile, dynamic rolekey and status
  Future<bool> addUser({
    required String name,
    required String email,
    required String mobile,
    String? role,
    String? status,
  }) async {
    isSubmitting.value = true;
    try {
      final int statusInt = 2;

      String targetRoleKey = ApiManager.staticRoleKey;
      if (role != null && role.isNotEmpty) {
        final matchedRole = roles.firstWhereOrNull(
          (r) =>
              r.roleName.toLowerCase() == role.toLowerCase() ||
              r.roleKey == role,
        );
        if (matchedRole != null && matchedRole.roleKey.isNotEmpty) {
          targetRoleKey = matchedRole.roleKey;
        } else {
          targetRoleKey = role;
        }
      }

      if (kDebugMode) {
        debugPrint(
          '[UserController] Adding user "$name" with role: "$role", resolved roleKey: "$targetRoleKey"',
        );
      }

      final result = await _userService.addUser(
        email: email,
        fullname: name,
        mobile: mobile,
        rolekey: targetRoleKey,
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
