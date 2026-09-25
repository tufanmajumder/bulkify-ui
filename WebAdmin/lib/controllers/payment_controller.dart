import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/models/payment_model.dart';
import 'package:admin_app/service/payment_service.dart';
import 'package:admin_app/views/payment_details_screen.dart';

class PaymentController extends GetxController {
  final RxList<PaymentModel> payments = <PaymentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Stat Summary Cards matching design
  final RxString completedCount = '19,860'.obs;
  final RxString completedChange = '(-14%)'.obs;

  final RxString pendingPaymentCount = '237'.obs;
  final RxString pendingChange = '(+42%)'.obs;

  final RxString refundCount = '4,567'.obs;
  final RxString refundChange = '(+18%)'.obs;

  final RxString failedCount = '21,459'.obs;
  final RxString failedChange = '(+29%)'.obs;

  // Filters & Pagination State
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'All'.obs;
  final RxInt currentPage = 1.obs;
  final RxInt rowsPerPage = 2.obs;
  final RxBool hasMorePage = false.obs;
  final RxInt totalPayments = 0.obs;
  final RxInt totalPages = 1.obs;

  final List<String> statusOptions = [
    'All',
    'Success',
    'Pending',
    'Failed',
    'Refund',
  ];

  late final PaymentService _paymentService;

  @override
  void onInit() {
    super.onInit();
    _paymentService = Get.isRegistered<PaymentService>()
        ? Get.find<PaymentService>()
        : Get.put(PaymentService());
    fetchPayments(page: 1);
  }

  /// Calls payments/v1/list API endpoint via PaymentService
  Future<void> fetchPayments({int page = 1, int? perpage}) async {
    isLoading.value = true;
    errorMessage.value = '';
    final int targetPerPage = perpage ?? rowsPerPage.value;
    rowsPerPage.value = targetPerPage;

    try {
      final result = await _paymentService.getPaymentList(
        page: page,
        perpage: targetPerPage,
      );

      if (result.isTokenExpired) {
        errorMessage.value = 'Session expired. Please log in again.';
        Get.offAllNamed('/login');
        return;
      }

      if (result.success || result.code == 200) {
        if (result.payments.isNotEmpty) {
          payments.assignAll(result.payments);
        } else if (page == 1) {
          payments.clear();
        }

        if (result.pageContext != null) {
          currentPage.value = result.pageContext!.page;
          hasMorePage.value = result.pageContext!.hasMorePage;
          totalPayments.value = result.pageContext!.total > 0
              ? result.pageContext!.total
              : result.payments.length;
          totalPages.value = result.pageContext!.totalPages > 0
              ? result.pageContext!.totalPages
              : (hasMorePage.value ? currentPage.value + 1 : (currentPage.value > 0 ? currentPage.value : 1));
        } else {
          currentPage.value = page;
          hasMorePage.value = result.payments.length >= targetPerPage;
          totalPayments.value = result.payments.length;
          totalPages.value = hasMorePage.value ? page + 1 : page;
        }
      } else {
        errorMessage.value = result.message;
        if (payments.isEmpty) {
          loadMockPayments();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PaymentController] Error fetching payments: $e');
      }
      errorMessage.value = 'Failed to load payments';
      if (payments.isEmpty) {
        loadMockPayments();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void loadMockPayments() {
    final List<PaymentModel> list = [
      // PaymentModel(
      //   orderId: 'ORD1234567890',
      //   paymentId: 'pay123456582536',
      //   utrRrn: '2352412563259',
      //   paymentMethod: 'Bank Transfer',
      //   customerName: 'Christian Teigland',
      //   customerSubtext: 'NA',
      //   date: '05-10-2026',
      //   time: '9:30 AM',
      //   status: 'Success',
      //   amount: '₹ 25652.00',
      // ),
      // PaymentModel(
      //   orderId: 'ORD1234567891',
      //   paymentId: 'pay123456582537',
      //   utrRrn: '2352412563260',
      //   paymentMethod: 'Credit Card',
      //   customerName: 'Emma Johnson',
      //   customerSubtext: 'NA',
      //   date: '05-10-2026',
      //   time: '10:00 AM',
      //   status: 'Success',
      //   amount: '₹ 15000.00',
      // ),
      // PaymentModel(
      //   orderId: 'ORD1234567892',
      //   paymentId: 'pay123456582538',
      //   utrRrn: '2352412563261',
      //   paymentMethod: 'PayPal',
      //   customerName: 'Michael Smith',
      //   customerSubtext: 'NA',
      //   date: '05-10-2026',
      //   time: '10:30 AM',
      //   status: 'Pending',
      //   amount: '₹ 18000.00',
      // ),
      // PaymentModel(
      //   orderId: 'ORD1234567893',
      //   paymentId: 'pay123456582539',
      //   utrRrn: '2352412563262',
      //   paymentMethod: 'Debit Card',
      //   customerName: 'Julia Roberts',
      //   customerSubtext: 'NA',
      //   date: '05-10-2026',
      //   time: '11:00 AM',
      //   status: 'Failed',
      //   amount: '₹ 5000.00',
      // ),
      // PaymentModel(
      //   orderId: 'ORD1234567894',
      //   paymentId: 'pay123456582540',
      //   utrRrn: '2352412563263',
      //   paymentMethod: 'Net Banking',
      //   customerName: 'David Brown',
      //   customerSubtext: 'NA',
      //   date: '05-10-2026',
      //   time: '11:30 AM',
      //   status: 'Success',
      //   amount: '₹ 35000.00',
      // ),
    ];

    payments.assignAll(list);
    totalPayments.value = list.length;
    totalPages.value = (list.length / rowsPerPage.value).ceil();
    hasMorePage.value = false;
  }

  // Filtered payments getter
  List<PaymentModel> get filteredPayments {
    return payments.where((p) {
      final query = searchQuery.value.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          p.orderId.toLowerCase().contains(query) ||
          p.paymentId.toLowerCase().contains(query) ||
          p.utrRrn.toLowerCase().contains(query) ||
          p.customerName.toLowerCase().contains(query) ||
          p.paymentMethod.toLowerCase().contains(query);

      final matchesStatus = selectedStatus.value == 'All' ||
          selectedStatus.value == 'Select Status' ||
          p.status.toLowerCase() == selectedStatus.value.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // Paginated payments getter
  List<PaymentModel> get paginatedPayments {
    final filtered = filteredPayments;
    if (filtered.isEmpty) return [];

    // If backend returns more items than rowsPerPage, slice locally for strict pagination display
    if (filtered.length > rowsPerPage.value) {
      int start = (currentPage.value - 1) * rowsPerPage.value;
      if (start < 0 || start >= filtered.length) {
        start = 0;
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
    final total = displayTotalCount;
    if (total > 0 && rowsPerPage.value > 0) {
      return (total / rowsPerPage.value).ceil();
    }
    if (hasMorePage.value) {
      return currentPage.value + 1;
    }
    return currentPage.value > 0 ? currentPage.value : 1;
  }

  int get startEntryIndex {
    if (filteredPayments.isEmpty) return 0;
    return (currentPage.value - 1) * rowsPerPage.value + 1;
  }

  int get endEntryIndex {
    if (filteredPayments.isEmpty) return 0;
    final end = startEntryIndex + paginatedPayments.length - 1;
    final total = displayTotalCount;
    if (total > 0 && end > total) {
      return total;
    }
    return end;
  }

  int get displayTotalCount {
    if (totalPayments.value > 0) return totalPayments.value;
    return filteredPayments.length;
  }

  void setSearchQuery(String val) {
    searchQuery.value = val;
    fetchPayments(page: 1);
  }

  void setStatusFilter(String? val) {
    if (val == null) return;
    selectedStatus.value = val;
    fetchPayments(page: 1);
  }

  void setPage(int page) {
    if (page >= 1 && page != currentPage.value && !isLoading.value) {
      fetchPayments(page: page, perpage: rowsPerPage.value);
    }
  }

  void nextPage() {
    if ((hasMorePage.value || currentPage.value < computedTotalPages) && !isLoading.value) {
      fetchPayments(page: currentPage.value + 1, perpage: rowsPerPage.value);
    }
  }

  void previousPage() {
    if (currentPage.value > 1 && !isLoading.value) {
      fetchPayments(page: currentPage.value - 1, perpage: rowsPerPage.value);
    }
  }

  void setRowsPerPage(int rows) {
    rowsPerPage.value = rows;
    fetchPayments(page: 1, perpage: rows);
  }

  void initiateNewPayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final orderIdController = TextEditingController();
        final amountController = TextEditingController();
        final customerController = TextEditingController();

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: const [
              Icon(Icons.add_card_rounded, color: Color(0xFFCF4340)),
              SizedBox(width: 8),
              Text(
                'Initiate New Payment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: orderIdController,
                  decoration: const InputDecoration(
                    labelText: 'Order ID',
                    hintText: 'e.g. ORD1234567897',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: customerController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name',
                    hintText: 'e.g. Christian Teigland',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (₹)',
                    hintText: 'e.g. 15000.00',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCF4340),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                if (orderIdController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  payments.insert(
                    0,
                    PaymentModel(
                      orderId: orderIdController.text.trim(),
                      paymentId:
                          'pay${DateTime.now().millisecondsSinceEpoch}',
                      utrRrn:
                          '${DateTime.now().microsecondsSinceEpoch}'.substring(0, 13),
                      paymentMethod: 'Bank Transfer',
                      customerName: customerController.text.trim().isEmpty
                          ? 'Customer'
                          : customerController.text.trim(),
                      date: '05-10-2026',
                      time: '1:00 PM',
                      status: 'Pending',
                      amount: '₹ ${amountController.text.trim()}',
                    ),
                  );
                  Navigator.pop(context);
                  Get.snackbar(
                    'Success',
                    'Payment initiated successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF10B981),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                  );
                }
              },
              child: const Text('Initiate'),
            ),
          ],
        );
      },
    );
  }

  void viewPaymentDetails(PaymentModel item) {
    Get.to(
      () => PaymentDetailsScreen(payment: item),
      routeName: '/payment-details',
      arguments: item,
    );
  }
}
