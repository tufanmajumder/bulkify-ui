import 'package:flutter/material.dart';
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
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isSearchingMode = false.obs;
  final RxString selectedRole = 'All'.obs;
  final RxString selectedStatus = 'All'.obs;

  // Pagination states
  final RxInt currentPage = 1.obs;
  final RxInt rowsPerPage = 10.obs;
  final RxBool hasMorePage = false.obs;
  final RxInt totalUsers = 0.obs;
  final RxInt totalPages = 1.obs;

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
      // if (kDebugMode) {
      //   debugPrint('[UserController] Error fetching roles: $e');
      // }
    } finally {
      isLoadingRoles.value = false;
    }
  }

  /// Calls getUserList or searchUser API from ApiManager (via UserService) and updates user list & summary.
  Future<void> fetchUsers({int page = 1, int? perpage}) async {
    isLoading.value = true;
    errorMessage.value = '';
    final int targetPerPage = perpage ?? rowsPerPage.value;
    rowsPerPage.value = targetPerPage;

    try {
      final UserListResult result;
      final String query = searchController.text.trim();
      if (isSearchingMode.value && query.isNotEmpty) {
        result = await _userService.searchUser(registeredmobile: query);
        if (result.users.isEmpty) {
          users.clear();
          errorMessage.value =
              (result.message.isNotEmpty && result.message != 'success')
              ? result.message
              : 'User not found';
          return;
        }
      } else {
        String targetRoleKey = selectedRole.value;
        if (targetRoleKey != 'All' && targetRoleKey != 'Select Role') {
          final matchedRole = roles.firstWhereOrNull(
            (r) =>
                r.roleName.toLowerCase() == targetRoleKey.toLowerCase() ||
                r.roleKey == targetRoleKey,
          );
          if (matchedRole != null && matchedRole.roleKey.isNotEmpty) {
            targetRoleKey = matchedRole.roleKey;
          }
        }

        result = await _userService.getUserList(
          page: page,
          perpage: targetPerPage,
          onlineStatus: selectedStatus.value,
          rolekey: targetRoleKey,
        );
      }

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

        if (result.pageContext != null) {
          currentPage.value = result.pageContext!.page;
          hasMorePage.value = result.pageContext!.hasMorePage;
          if (result.pageContext!.totalPages > 0) {
            totalPages.value = result.pageContext!.totalPages;
          } else if (result.pageContext!.totalRecords > 0) {
            totalPages.value =
                (result.pageContext!.totalRecords / targetPerPage).ceil();
          } else {
            totalPages.value = hasMorePage.value
                ? currentPage.value + 1
                : currentPage.value;
          }

          if (result.pageContext!.totalRecords > 0) {
            totalUsers.value = result.pageContext!.totalRecords;
          } else if (result.pageContext!.totalPages > 0) {
            totalUsers.value =
                result.pageContext!.totalPages * targetPerPage;
          }
        } else {
          currentPage.value = page;
          hasMorePage.value = result.users.length >= targetPerPage;
          totalUsers.value = 0;
          totalPages.value = hasMorePage.value
              ? currentPage.value + 1
              : currentPage.value;
        }
      } else {
        errorMessage.value = result.message.isNotEmpty
            ? result.message
            : 'User not found';
        if (users.isEmpty && !isSearchingMode.value) {
          _loadInitialUsers();
        }
      }
    } catch (e) {
      // if (kDebugMode) {
      //   debugPrint('[UserController] Error fetching users: $e');
      // }
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
          isSearchingMode.value ||
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
          user.role.toLowerCase() == selectedRole.value.toLowerCase() ||
          roles.any(
            (r) =>
                (r.roleName.toLowerCase() == selectedRole.value.toLowerCase() ||
                    r.roleKey == selectedRole.value) &&
                (r.roleKey == user.role ||
                    r.roleName.toLowerCase() == user.role.toLowerCase()),
          );

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
    final filtered = filteredUsers;
    if (filtered.isEmpty) return [];

    // If backend returns more items than rowsPerPage (e.g. client-side filtering), slice locally
    if (filtered.length > rowsPerPage.value) {
      int start = (currentPage.value - 1) * rowsPerPage.value;
      if (start < 0 || start >= filtered.length) {
        return filtered;
      }
      int end = start + rowsPerPage.value;
      if (end > filtered.length) {
        end = filtered.length;
      }
      return filtered.sublist(start, end);
    }

    return filtered;
  }

  int get computedTotalPages {
    if (totalPages.value > 0) {
      return totalPages.value;
    }
    if (totalUsers.value > 0 && rowsPerPage.value > 0) {
      final t = (totalUsers.value / rowsPerPage.value).ceil();
      return t > 0 ? t : 1;
    }

    int pages = currentPage.value;
    if (hasMorePage.value) {
      pages = currentPage.value + 1;
    }

    return pages > 0 ? pages : 1;
  }

  List<int> get visiblePageNumbers {
    final maxPage = computedTotalPages;
    if (maxPage <= 3) {
      return List.generate(maxPage > 0 ? maxPage : 1, (i) => i + 1);
    }
    final current = currentPage.value;
    int start = current - 1;
    int end = current + 1;
    if (start < 1) {
      start = 1;
      end = 3;
    } else if (end > maxPage) {
      end = maxPage;
      start = maxPage - 2;
    }
    List<int> pages = [];
    for (int i = start; i <= end; i++) {
      pages.add(i);
    }
    return pages;
  }

  int get startEntryIndex {
    if (filteredUsers.isEmpty) return 0;
    return (currentPage.value - 1) * rowsPerPage.value + 1;
  }

  int get endEntryIndex {
    if (filteredUsers.isEmpty) return 0;
    return (currentPage.value - 1) * rowsPerPage.value +
        paginatedUsers.length;
  }

  int get displayTotalCount {
    if (totalUsers.value > 0) return totalUsers.value;
    if (filteredUsers.isEmpty) return 0;
    return (currentPage.value - 1) * rowsPerPage.value +
        paginatedUsers.length;
  }

  // Controller Actions
  void setSearchQuery(String query) {
    searchQuery.value = query;
    if (searchController.text != query) {
      searchController.text = query;
      searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: searchController.text.length),
      );
    }
    currentPage.value = 1;
  }

  void searchUsers() {
    if (isLoading.value) return;
    final query = searchController.text.trim();
    if (query.isEmpty) {
      clearSearchQuery();
      return;
    }
    isSearchingMode.value = true;
    searchQuery.value = query;
    currentPage.value = 1;
    fetchUsers();
  }

  void clearSearchQuery() {
    searchController.clear();
    searchQuery.value = '';
    isSearchingMode.value = false;
    currentPage.value = 1;
    fetchUsers();
  }

  void setSelectedRole(String role) {
    selectedRole.value = role;
    currentPage.value = 1;
    fetchUsers();
  }

  void setSelectedStatus(String status) {
    selectedStatus.value = status;
    currentPage.value = 1;
    fetchUsers();
  }

  void setPage(int page) {
    if (page >= 1 && page != currentPage.value && !isLoading.value) {
      fetchUsers(page: page, perpage: rowsPerPage.value);
    }
  }

  void nextPage() {
    if ((hasMorePage.value || currentPage.value < computedTotalPages) &&
        !isLoading.value) {
      fetchUsers(page: currentPage.value + 1, perpage: rowsPerPage.value);
    }
  }

  void prevPage() {
    if (currentPage.value > 1 && !isLoading.value) {
      fetchUsers(page: currentPage.value - 1, perpage: rowsPerPage.value);
    }
  }

  void goToFirstPage() {
    if (currentPage.value > 1 && !isLoading.value) {
      fetchUsers(page: 1, perpage: rowsPerPage.value);
    }
  }

  void goToLastPage() {
    if (isLoading.value) return;
    final targetLastPage = computedTotalPages;
    if (targetLastPage >= 1 && targetLastPage != currentPage.value) {
      fetchUsers(page: targetLastPage, perpage: rowsPerPage.value);
    }
  }

  void setRowsPerPage(int rows) {
    rowsPerPage.value = rows;
    fetchUsers(page: 1, perpage: rows);
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

      //if (kDebugMode) {
      // debugPrint(
      //   '[UserController] Adding user "$name" with role: "$role", resolved roleKey: "$targetRoleKey"',
      // );
      //}

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
      // if (kDebugMode) {
      //   debugPrint('[UserController] Error adding user: $e');
      // }
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
