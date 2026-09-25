import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/models/order_model.dart';
import 'package:admin_app/service/auth_service.dart';
import 'package:admin_app/service/order_service.dart';
import 'package:admin_app/utils/widget_manager.dart';
import 'package:admin_app/views/order_details_screen.dart';

class OrderController extends GetxController {
  final OrderService _orderService = Get.put(OrderService());

  // Reactive list of all orders
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMorePage = false.obs;

  // Stat summary counters matching the exact image
  final RxString completedCount = '12,689'.obs;
  final RxString pendingPaymentCount = '56'.obs;
  final RxString refundedCount = '124'.obs;
  final RxString failedCount = '32'.obs;

  // Search & Pagination states
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt rowsPerPage = 10.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders({int? page, int? perPage}) async {
    isLoading.value = true;
    final int targetPage = page ?? currentPage.value;
    final int targetPerPage = perPage ?? rowsPerPage.value;
    try {
      final token = await AuthService.getAuthToken();
      print("token....$token");
      if (token.trim().isEmpty) {
        if (kDebugMode) {
          debugPrint('[OrderController] No token — redirecting to login');
        }
        await _handleTokenExpired();
        return;
      }

      final result = await _orderService.getOrderListResult(
        page: targetPage,
        perPage: targetPerPage,
        token: token,
      );

      if (result.isTokenExpired) {
        if (kDebugMode) {
          debugPrint('[OrderController] Token expired — redirecting to login');
        }
        await _handleTokenExpired();
        return;
      }

      if (kDebugMode) {
        debugPrint(
          '[OrderController] Fetched ${result.orders.length} orders. HasMorePage: ${result.hasMorePage}',
        );
      }

      orders.assignAll(result.orders);
      currentPage.value = targetPage;
      rowsPerPage.value = targetPerPage;
      hasMorePage.value = result.hasMorePage;
    } catch (e) {
      if (kDebugMode) debugPrint('[OrderController] Error fetching orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleTokenExpired() async {
    await AuthService.clearAuthToken();
    WidgetManager.showAlertSnackBar('Session expired. Please log in again.');
    Get.offAllNamed('/login');
  }

  // Filtered Orders Getter
  List<OrderModel> get filteredOrders {
    if (searchQuery.value.isEmpty) {
      return orders;
    }
    final q = searchQuery.value.toLowerCase();
    return orders.where((order) {
      return order.id.toLowerCase().contains(q) ||
          order.customerName.toLowerCase().contains(q) ||
          order.customerEmail.toLowerCase().contains(q) ||
          order.orderStatus.toLowerCase().contains(q) ||
          order.paymentStatus.toLowerCase().contains(q) ||
          order.amount.toLowerCase().contains(q);
    }).toList();
  }

  // Paginated Orders Getter
  List<OrderModel> get paginatedOrders {
    return filteredOrders;
  }

  bool get effectiveHasMorePage {
    if (searchQuery.value.isNotEmpty) {
      return (currentPage.value * rowsPerPage.value) < filteredOrders.length;
    }
    return hasMorePage.value;
  }

  int get totalPages {
    if (searchQuery.value.isNotEmpty) {
      final count = filteredOrders.length;
      if (count == 0) return 1;
      return (count / rowsPerPage.value).ceil();
    }
    return (!isLoading.value && hasMorePage.value)
        ? currentPage.value + 1
        : currentPage.value;
  }

  List<int> get visiblePageNumbers {
    final maxPage = totalPages;
    int startPage = (maxPage - 4).clamp(1, maxPage);
    List<int> pages = [];
    for (int i = startPage; i <= maxPage; i++) {
      pages.add(i);
    }
    return pages;
  }

  int get startEntryIndex => filteredOrders.isEmpty
      ? 0
      : (currentPage.value - 1) * rowsPerPage.value + 1;

  int get endEntryIndex => filteredOrders.isEmpty
      ? 0
      : (currentPage.value - 1) * rowsPerPage.value + filteredOrders.length;

  // Controller Actions
  void setSearchQuery(String query) {
    if (isLoading.value) return;
    searchQuery.value = query;
    currentPage.value = 1;
    fetchOrders(page: 1);
  }

  void nextPage() {
    if (!isLoading.value && hasMorePage.value) {
      fetchOrders(page: currentPage.value + 1);
    }
  }

  void previousPage() {
    if (!isLoading.value && currentPage.value > 1) {
      fetchOrders(page: currentPage.value - 1);
    }
  }

  void prevPage() => previousPage();

  void goToFirstPage() {
    if (!isLoading.value && currentPage.value > 1) {
      fetchOrders(page: 1);
    }
  }

  void goToLastPage() {
    if (!isLoading.value && hasMorePage.value) {
      fetchOrders(page: totalPages);
    }
  }

  void setPage(int page) {
    if (!isLoading.value && page >= 1 && page != currentPage.value) {
      fetchOrders(page: page);
    }
  }

  void setRowsPerPage(int rows) {
    if (!isLoading.value) {
      fetchOrders(page: 1, perPage: rows);
    }
  }

  void exportOrders() {
    Get.snackbar(
      'Export Successful',
      'Order list exported successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void deleteOrder(String id) {
    orders.removeWhere((o) => o.id == id);
    Get.snackbar(
      'Deleted',
      'Order $id removed successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void viewOrderDetails(OrderModel order) {
    Get.to(
      () => const OrderDetailsScreen(),
      arguments: order,
      routeName: '/order-details',
    );
  }
}
