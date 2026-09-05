import 'package:get/get.dart';
import '../models/user_model.dart';

class UserController extends GetxController {
  // Reactive list of all users
  final RxList<UserModel> users = <UserModel>[].obs;

  // Search and Filter states
  final RxString searchQuery = ''.obs;
  final RxString selectedRole = 'All'.obs;
  final RxString selectedStatus = 'All'.obs;

  // Pagination states
  final RxInt currentPage =
      3.obs; // Page 3 selected as shown in reference image
  final RxInt rowsPerPage = 10.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialUsers();
  }

  void _loadInitialUsers() {
    final List<UserModel> initialData = [
      UserModel(
        id: '1',
        name: 'Jordan Stevenson',
        email: 'jordan@gmail.com',
        role: 'Driver',
        lastLogin: '20-08-2026 12:00 PM',
        status: 'Active',
        mobNo: '7980123456',
      ),
      UserModel(
        id: '2',
        name: 'Emily Carter',
        email: 'emily.carter@yahoo.com',
        role: 'Pilot',
        lastLogin: '22-08-2026 03:00 PM',
        status: 'Active',
        mobNo: '7980234567',
      ),
      UserModel(
        id: '3',
        name: 'Emily Carter',
        email: 'emily.carter@email.com',
        role: 'Scheduler',
        lastLogin: '15-09-2026 3:00 PM',
        status: 'Inactive',
        mobNo: '9123456789',
      ),
      UserModel(
        id: '4',
        name: 'Michael Johnson',
        email: 'michael.j@gmail.com',
        role: 'Manager',
        lastLogin: '01-10-2026 9:00 AM',
        status: 'Active',
        mobNo: '8456789012',
      ),
      UserModel(
        id: '5',
        name: 'Samantha Lee',
        email: 'samantha_lee@hotmail.com',
        role: 'Designer',
        lastLogin: '25-10-2026 1:30 PM',
        status: 'Active',
        mobNo: '6543217890',
      ),
      UserModel(
        id: '6',
        name: 'David Smith',
        email: 'david.smith@yahoo.com',
        role: 'Developer',
        lastLogin: '05-11-2026 4:15 PM',
        status: 'Inactive',
        mobNo: '7890123456',
      ),
      UserModel(
        id: '7',
        name: 'Nina Patel',
        email: 'nina.patel@outlook.com',
        role: 'Analyst',
        lastLogin: '10-12-2026 10:00 AM',
        status: 'Active',
        mobNo: '2345678901',
      ),
      UserModel(
        id: '8',
        name: 'Liam Brown',
        email: 'liam.brown@live.com',
        role: 'Representative',
        lastLogin: '20-01-2027 2:45 PM',
        status: 'Active',
        mobNo: '3456789012',
      ),
      UserModel(
        id: '9',
        name: 'Sophia Davis',
        email: 'sophia.davis@school.edu',
        role: 'Researcher',
        lastLogin: '30-01-2027 11:00 AM',
        status: 'Inactive',
        mobNo: '4567890123',
      ),
      UserModel(
        id: '10',
        name: 'Oliver Taylor',
        email: 'oliver.taylor@gmail.com',
        role: 'Admin',
        lastLogin: '15-02-2027 10:30 AM',
        status: 'Active',
        mobNo: '5678901234',
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
