import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bulkify/app/data/service/auth_service.dart';
import 'package:bulkify/app/data/models/order/reject_model.dart';

class OrdersController extends GetxController {
  final AuthService _authService = AuthService();
  final ScrollController scrollController = ScrollController();

  // API & State for Active Orders
  final RxBool isActiveLoading = false.obs;
  final RxBool isActiveLoadingMore = false.obs;
  final Rxn<RejectedModel> activeModel = Rxn<RejectedModel>();
  final RxList<Map<String, dynamic>> activeOrders =
      <Map<String, dynamic>>[].obs;
  final RxInt activePage = 1.obs;
  final RxInt activeTotalPages = 1.obs;
  final int activePageSize = 6;
  final RxBool hasNoMoreActiveData = false.obs;

  // API & State for Completed Orders
  final RxBool isCompletedLoading = false.obs;
  final RxBool isCompletedLoadingMore = false.obs;
  final Rxn<RejectedModel> completedModel = Rxn<RejectedModel>();
  final RxList<Map<String, dynamic>> completedOrders =
      <Map<String, dynamic>>[].obs;
  final RxInt completedPage = 1.obs;
  final RxInt completedTotalPages = 1.obs;
  final int completedPageSize = 6;

  // API & State for Rejected Orders
  final RxBool isRejectedLoading = false.obs;
  final RxBool isRejectedLoadingMore = false.obs;
  final Rxn<RejectedModel> rejectedModel = Rxn<RejectedModel>();
  final RxList<Map<String, dynamic>> rejectedOrders =
      <Map<String, dynamic>>[].obs;
  final RxInt rejectedPage = 1.obs;
  final RxInt rejectedTotalPages = 1.obs;
  final int rejectedPageSize = 6;
  final RxBool hasNoMoreRejectedData = false.obs;

  // Selected Filter Index (0: Active, 1: Completed, 2: Rejected)
  final RxInt selectedFilterIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchActiveOrders(page: 1, isRefresh: true);
    fetchCompletedOrders(page: 1, isRefresh: true);
    fetchRejectedOrders(page: 1, isRefresh: true);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.hasClients &&
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 80) {
      if (selectedFilterIndex.value == 0) {
        loadMoreActiveOrders();
      } else if (selectedFilterIndex.value == 1) {
        loadMoreCompletedOrders();
      } else if (selectedFilterIndex.value == 2) {
        loadMoreRejectedOrders();
      }
    }
  }

  /// Fetch Active Orders from API using body: { "page": page, "pageSize": 6, "status": "Active" }
  Future<void> fetchActiveOrders({int page = 1, bool isRefresh = false}) async {
    if (isRefresh || page == 1) {
      isActiveLoading.value = true;
      activePage.value = 1;
      hasNoMoreActiveData.value = false;
    } else {
      isActiveLoadingMore.value = true;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? sessionId = prefs.getString('sessionId');
      print("Fetching active orders (page $page) with sessionId: $sessionId");

      final RejectedModel? response = await _authService.getOrderList(
        page: page,
        pagesize: activePageSize,
        status: "Active",
        sessionId: sessionId,
      );
      if (response != null) {
        activeModel.value = response;
        activePage.value = page;

        final data = response.data;
        if (data != null) {
          final int tPages =
              int.tryParse(data.totalPages?.toString() ?? '1') ?? 1;
          activeTotalPages.value = tPages > 0 ? tPages : 1;

          final items = data.items ?? [];
          final newItems = items.map((item) {
            final String method = (item.deliveryMethod?.toString() ?? '')
                .trim()
                .toLowerCase();
            final String iconType = (method == 'bike') ? 'bike' : 'van';
            return <String, dynamic>{
              'id': item.orderNumber?.toString() ?? '',
              'storeName': item.restaurantName?.toString() ?? '',
              'address': item.deliveryAddress?.toString() ?? '',
              'amount': double.tryParse(item.amount?.toString() ?? '0') ?? 0.0,
              'orderstatus': item.orderstatus?.toString(),
              'statusText': item.status?.toString() ?? 'Active',
              'statusType': 'active',
              'deliveryMethod': item.deliveryMethod?.toString() ?? '',
              'iconType': iconType,
            };
          }).toList();

          if (isRefresh || page == 1) {
            activeOrders.value = newItems;
          } else {
            activeOrders.addAll(newItems);
          }

          if (newItems.isEmpty ||
              newItems.length < activePageSize ||
              page >= activeTotalPages.value) {
            hasNoMoreActiveData.value = true;
          } else {
            hasNoMoreActiveData.value = false;
          }
        }
      }
    } catch (e) {
      print("Error fetching active orders: $e");
    } finally {
      isActiveLoading.value = false;
      isActiveLoadingMore.value = false;
    }
  }

  void loadMoreActiveOrders() {
    if (!isActiveLoading.value &&
        !isActiveLoadingMore.value &&
        activePage.value < activeTotalPages.value) {
      fetchActiveOrders(page: activePage.value + 1, isRefresh: false);
    }
  }

  final RxBool hasNoMoreCompletedData = false.obs;

  /// Fetch Completed Orders from API using body: { "page": page, "pageSize": 6, "status": "Completed" }
  Future<void> fetchCompletedOrders({
    int page = 1,
    bool isRefresh = false,
  }) async {
    if (isRefresh || page == 1) {
      isCompletedLoading.value = true;
      completedPage.value = 1;
      hasNoMoreCompletedData.value = false;
    } else {
      isCompletedLoadingMore.value = true;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? sessionId = prefs.getString('sessionId');
      print(
        "Fetching completed orders (page $page) with sessionId: $sessionId",
      );

      final RejectedModel? response = await _authService.getOrderList(
        page: page,
        pagesize: completedPageSize,
        status: "Completed",
        sessionId: sessionId,
      );
      if (response != null) {
        completedModel.value = response;
        completedPage.value = page;

        final data = response.data;
        if (data != null) {
          final int tPages =
              int.tryParse(data.totalPages?.toString() ?? '1') ?? 1;
          completedTotalPages.value = tPages > 0 ? tPages : 1;

          final items = data.items ?? [];
          final newItems = items.map((item) {
            final String method = (item.deliveryMethod?.toString() ?? '')
                .trim()
                .toLowerCase();
            final String iconType = (method == 'bike') ? 'bike' : 'van';
            return <String, dynamic>{
              'id': item.orderNumber?.toString() ?? '',
              'storeName': item.restaurantName?.toString() ?? '',
              'address': item.deliveryAddress?.toString() ?? '',
              'amount': double.tryParse(item.amount?.toString() ?? '0') ?? 0.0,
              'statusText': item.status?.toString() ?? 'Completed',
              'statusType': 'completed',
              'deliveryMethod': item.deliveryMethod?.toString() ?? '',
              'iconType': iconType,
            };
          }).toList();

          if (isRefresh || page == 1) {
            completedOrders.value = newItems;
          } else {
            completedOrders.addAll(newItems);
          }

          if (newItems.isEmpty ||
              newItems.length < completedPageSize ||
              page >= completedTotalPages.value) {
            hasNoMoreCompletedData.value = true;
          } else {
            hasNoMoreCompletedData.value = false;
          }
        }
      }
    } catch (e) {
      print("Error fetching completed orders: $e");
    } finally {
      isCompletedLoading.value = false;
      isCompletedLoadingMore.value = false;
    }
  }

  void loadMoreCompletedOrders() {
    if (!isCompletedLoading.value &&
        !isCompletedLoadingMore.value &&
        completedPage.value < completedTotalPages.value) {
      fetchCompletedOrders(page: completedPage.value + 1, isRefresh: false);
    }
  }

  /// Fetch Rejected Orders from API using body: { "page": page, "pageSize": 6, "status": "Rejected" }
  Future<void> fetchRejectedOrders({
    int page = 1,
    bool isRefresh = false,
  }) async {
    if (isRefresh || page == 1) {
      isRejectedLoading.value = true;
      rejectedPage.value = 1;
      hasNoMoreRejectedData.value = false;
    } else {
      isRejectedLoadingMore.value = true;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? sessionId = prefs.getString('sessionId');
      print("Fetching rejected orders (page $page) with sessionId: $sessionId");

      final RejectedModel? response = await _authService.getOrderList(
        page: page,
        pagesize: rejectedPageSize,
        status: "Rejected",
        sessionId: sessionId,
      );
      if (response != null) {
        rejectedModel.value = response;
        rejectedPage.value = page;

        final data = response.data;
        if (data != null) {
          final int tPages =
              int.tryParse(data.totalPages?.toString() ?? '1') ?? 1;
          rejectedTotalPages.value = tPages > 0 ? tPages : 1;

          final items = data.items ?? [];
          final newItems = items.map((item) {
            final String method = (item.deliveryMethod?.toString() ?? '')
                .trim()
                .toLowerCase();
            final String iconType = (method == 'bike') ? 'bike' : 'van';
            return <String, dynamic>{
              'id': item.orderNumber?.toString() ?? '',
              'storeName': item.restaurantName?.toString() ?? '',
              'address': item.deliveryAddress?.toString() ?? '',
              'amount': double.tryParse(item.amount?.toString() ?? '0') ?? 0.0,
              'statusText': item.status?.toString() ?? 'Rejected',
              'statusType': 'rejected',
              'deliveryMethod': item.deliveryMethod?.toString() ?? '',
              'iconType': iconType,
            };
          }).toList();

          if (isRefresh || page == 1) {
            rejectedOrders.value = newItems;
          } else {
            rejectedOrders.addAll(newItems);
          }

          if (newItems.isEmpty ||
              newItems.length < rejectedPageSize ||
              page >= rejectedTotalPages.value) {
            hasNoMoreRejectedData.value = true;
          } else {
            hasNoMoreRejectedData.value = false;
          }
        }
      }
    } catch (e) {
      print("Error fetching rejected orders: $e");
    } finally {
      isRejectedLoading.value = false;
      isRejectedLoadingMore.value = false;
    }
  }

  void loadMoreRejectedOrders() {
    if (!isRejectedLoading.value &&
        !isRejectedLoadingMore.value &&
        rejectedPage.value < rejectedTotalPages.value) {
      fetchRejectedOrders(page: rejectedPage.value + 1, isRefresh: false);
    }
  }

  void changeFilterIndex(int index) {
    selectedFilterIndex.value = index;
    if (index == 0) {
      if (activeOrders.isEmpty) {
        fetchActiveOrders(page: 1, isRefresh: true);
      }
    } else if (index == 1) {
      if (completedOrders.isEmpty) {
        fetchCompletedOrders(page: 1, isRefresh: true);
      }
    } else if (index == 2) {
      if (rejectedOrders.isEmpty) {
        fetchRejectedOrders(page: 1, isRefresh: true);
      }
    }
  }

  void refreshOrders() {
    if (selectedFilterIndex.value == 0) {
      fetchActiveOrders(page: 1, isRefresh: true);
    } else if (selectedFilterIndex.value == 1) {
      fetchCompletedOrders(page: 1, isRefresh: true);
    } else if (selectedFilterIndex.value == 2) {
      fetchRejectedOrders(page: 1, isRefresh: true);
    }
  }

  // Getter for filtered orders based on current tab
  List<Map<String, dynamic>> get currentFilteredOrders {
    if (selectedFilterIndex.value == 0) {
      return activeOrders;
    } else if (selectedFilterIndex.value == 1) {
      return completedOrders;
    } else {
      return rejectedOrders;
    }
  }
}
