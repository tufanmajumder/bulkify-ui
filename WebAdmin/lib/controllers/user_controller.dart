import 'package:get/get.dart';
import 'package:admin_app/models/user_model.dart';

class UserController extends GetxController {
  // Reactive list of all users
  final RxList<UserModel> users = <UserModel>[].obs;

  // Search and Filter states
  final RxString searchQuery = ''.obs;
  final RxString selectedRole = 'All'.obs;
  final RxString selectedStatus = 'All'.obs;

  // Pagination states
  final RxInt currentPage = 3.obs;
  final RxInt rowsPerPage = 10.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialUsers();
  }

  void _loadInitialUsers() {
    // Demo data uses clearly fictional identifiers (example.com, 90000XXXXX)
    // to comply with data minimisation principles.
    // Replace with a real API call when the Users API endpoint is available.
    final List<UserModel> initialData = [
      UserModel(
        id: '1',
        name: 'Demo User 01',
        email: 'user01@example.com',
        role: 'Driver',
        lastLogin: '20-08-2026 12:00 PM',
        status: 'Active',
        mobNo: '9000000001',
      ),
      UserModel(
        id: '2',
        name: 'Demo User 02',
        email: 'user02@example.com',
        role: 'Pilot',
        lastLogin: '22-08-2026 03:00 PM',
        status: 'Active',
        mobNo: '9000000002',
      ),
      UserModel(
        id: '3',
        name: 'Demo User 03',
        email: 'user03@example.com',
        role: 'Scheduler',
        lastLogin: '15-09-2026 3:00 PM',
        status: 'Inactive',
        mobNo: '9000000003',
      ),
      UserModel(
        id: '4',
        name: 'Demo User 04',
        email: 'user04@example.com',
        role: 'Manager',
        lastLogin: '01-10-2026 9:00 AM',
        status: 'Active',
        mobNo: '9000000004',
      ),
      UserModel(
        id: '5',
        name: 'Demo User 05',
        email: 'user05@example.com',
        role: 'Designer',
        lastLogin: '25-10-2026 1:30 PM',
        status: 'Active',
        mobNo: '9000000005',
      ),
      UserModel(
        id: '6',
        name: 'Demo User 06',
        email: 'user06@example.com',
        role: 'Developer',
        lastLogin: '05-11-2026 4:15 PM',
        status: 'Inactive',
        mobNo: '9000000006',
      ),
      UserModel(
        id: '7',
        name: 'Demo User 07',
        email: 'user07@example.com',
        role: 'Analyst',
        lastLogin: '10-12-2026 10:00 AM',
        status: 'Active',
        mobNo: '9000000007',
      ),
      UserModel(
        id: '8',
        name: 'Demo User 08',
        email: 'user08@example.com',
        role: 'Representative',
        lastLogin: '20-01-2027 2:45 PM',
        status: 'Active',
        mobNo: '9000000008',
      ),
      UserModel(
        id: '9',
        name: 'Demo User 09',
        email: 'user09@example.com',
        role: 'Researcher',
        lastLogin: '30-01-2027 11:00 AM',
        status: 'Inactive',
        mobNo: '9000000009',
      ),
      UserModel(
        id: '10',
        name: 'Demo User 10',
        email: 'user10@example.com',
        role: 'Admin',
        lastLogin: '15-02-2027 10:30 AM',
        status: 'Active',
        mobNo: '9000000010',
      ),
    ];

    // Populate 50 entries to demonstrate real pagination
    final List<UserModel> extendedData = [];
    for (int i = 0; i < 5; i++) {
      for (var u in initialData) {
        extendedData.add(
          UserModel(
            id: '${extendedData.length + 1}',
            name: u.name,
            email: u.email,
            role: u.role,
            lastLogin: u.lastLogin,
            status: u.status,
            mobNo: u.mobNo,
          ),
        );
      }
    }

    users.assignAll(extendedData);
  }

  // Filtered Users Getter
  List<UserModel> get filteredUsers {
    return users.where((user) {
      final matchesSearch =
          searchQuery.value.isEmpty ||
          user.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          user.email.toLowerCase().contains(searchQuery.value.toLowerCase());

      final matchesRole =
          selectedRole.value == 'All' ||
          selectedRole.value == 'Select Role' ||
          user.role == selectedRole.value;

      final matchesStatus =
          selectedStatus.value == 'All' ||
          selectedStatus.value == 'Select Status' ||
          user.status == selectedStatus.value;

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

  void addUser({
    required String name,
    required String email,
    String? contact,
    required String role,
    required String status,
    required String mobNo,
  }) {
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      contact: contact,
      role: role,
      lastLogin: '28-08-2026 11:20 AM',
      status: status,
      mobNo: mobNo,
    );
    users.insert(0, newUser);
    Get.snackbar(
      'Success',
      'User "$name" added successfully!',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
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
