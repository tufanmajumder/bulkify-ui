import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/models/payment_model.dart';

class PaymentController extends GetxController {
  final RxList<PaymentModel> payments = <PaymentModel>[].obs;
  final RxBool isLoading = false.obs;

  // Stat Summary Cards matching image
  final RxString completedCount = '19,860'.obs;
  final RxString completedChange = '(-14%)'.obs;

  final RxString pendingPaymentCount = '237'.obs;
  final RxString pendingChange = '(+42%)'.obs;

  final RxString refundCount = '4,567'.obs;
  final RxString refundChange = '(+18%)'.obs;

  final RxString failedCount = '21,459'.obs;
  final RxString failedChange = '(+29%)'.obs;

  // Filters & Pagination
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'All'.obs;
  final RxInt currentPage = 3.obs; // Selected page 3 as in image
  final RxInt rowsPerPage = 10.obs;

  final List<String> statusOptions = [
    'All',
    'Success',
    'Pending',
    'Failed',
    'Refund',
  ];

  @override
  void onInit() {
    super.onInit();
    loadMockPayments();
  }

  void loadMockPayments() {
    isLoading.value = true;
    final List<PaymentModel> list = [
      PaymentModel(
        orderId: 'ORD1234567890',
        paymentId: 'pay123456582536',
        utrRrn: '2352412563259',
        paymentMethod: 'Bank Transfer',
        customerName: 'Christian Teigland',
        customerSubtext: 'NA',
        date: '05-10-26',
        time: '9:30 AM',
        status: 'Success',
        amount: '₹ 25652.00',
      ),
      PaymentModel(
        orderId: 'ORD1234567891',
        paymentId: 'pay123456582537',
        utrRrn: '2352412563260',
        paymentMethod: 'Credit Card',
        customerName: 'Emma Johnson',
        customerSubtext: 'NA',
        date: '05-10-26',
        time: '10:00 AM',
        status: 'Success',
        amount: '₹ 15000.00',
      ),
      PaymentModel(
        orderId: 'ORD1234567892',
        paymentId: 'pay123456582538',
        utrRrn: '2352412563261',
        paymentMethod: 'PayPal',
        customerName: 'Michael Smith',
        customerSubtext: 'NA',
        date: '05-10-26',
        time: '10:30 AM',
        status: 'Pending',
        amount: '₹ 18000.00',
      ),
      PaymentModel(
        orderId: 'ORD1234567893',
        paymentId: 'pay123456582539',
        utrRrn: '2352412563262',
        paymentMethod: 'Debit Card',
        customerName: 'Julia Roberts',
        customerSubtext: 'NA',
        date: '05-10-26',
        time: '11:00 AM',
        status: 'Failed',
        amount: '₹ 5000.00',
      ),
      PaymentModel(
        orderId: 'ORD1234567894',
        paymentId: 'pay123456582540',
        utrRrn: '2352412563263',
        paymentMethod: 'Net Banking',
        customerName: 'David Brown',
        customerSubtext: 'NA',
        date: '05-10-26',
        time: '11:30 AM',
        status: 'Success',
        amount: '₹ 35000.00',
      ),
      PaymentModel(
        orderId: 'ORD1234567895',
        paymentId: 'pay123456582541',
        utrRrn: '2352412563264',
        paymentMethod: 'Cash',
        customerName: 'Sophia Wilson',
        customerSubtext: 'NA',
        date: '05-10-26',
        time: '12:00 PM',
        status: 'Success',
        amount: '₹ 9000.00',
      ),
      PaymentModel(
        orderId: 'ORD1234567896',
        paymentId: 'pay123456582542',
        utrRrn: '2352412563265',
        paymentMethod: 'Cryptocurrency',
        customerName: 'Liam Taylor',
        customerSubtext: 'NA',
        date: '05-10-26',
        time: '12:30 PM',
        status: 'Success',
        amount: '₹ 12000.00',
      ),
    ];

    // Generate total of 50 items for pagination demo
    final List<String> names = [
      'Olivia Martinez',
      'James Anderson',
      'Isabella Thomas',
      'Benjamin White',
      'Mia Harris',
      'Ethan Martin',
      'Charlotte Clark',
      'Alexander Rodriguez',
      'Amelia Lewis',
      'Henry Walker',
    ];
    final List<String> methods = [
      'UPI',
      'Bank Transfer',
      'Net Banking',
      'Credit Card',
      'Debit Card',
    ];
    final List<String> statuses = ['Success', 'Pending', 'Failed', 'Success'];

    for (int i = 7; i < 50; i++) {
      list.add(
        PaymentModel(
          orderId: 'ORD12345678${90 + i}',
          paymentId: 'pay123456582${536 + i}',
          utrRrn: '2352412563${259 + i}',
          paymentMethod: methods[i % methods.length],
          customerName: names[i % names.length],
          customerSubtext: 'NA',
          date: '05-10-26',
          time: '${(9 + (i % 8))}:30 AM',
          status: statuses[i % statuses.length],
          amount: '₹ ${(10000 + i * 450)}.00',
        ),
      );
    }

    payments.assignAll(list);
    isLoading.value = false;
  }

  // Filtered payments getter
  List<PaymentModel> get filteredPayments {
    return payments.where((p) {
      final matchesSearch = searchQuery.value.isEmpty ||
          p.orderId.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          p.paymentId.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          p.utrRrn.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          p.customerName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          p.paymentMethod.toLowerCase().contains(searchQuery.value.toLowerCase());

      final matchesStatus = selectedStatus.value == 'All' ||
          p.status.toLowerCase() == selectedStatus.value.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // Paginated payments getter
  List<PaymentModel> get paginatedPayments {
    final filtered = filteredPayments;
    int start = (currentPage.value - 1) * rowsPerPage.value;
    if (start >= filtered.length) {
      start = 0;
    }
    int end = start + rowsPerPage.value;
    if (end > filtered.length) {
      end = filtered.length;
    }
    if (filtered.isEmpty) return [];
    return filtered.sublist(start, end);
  }

  int get totalPages {
    if (filteredPayments.isEmpty) return 1;
    return (filteredPayments.length / rowsPerPage.value).ceil();
  }

  int get startEntryIndex => filteredPayments.isEmpty
      ? 0
      : (currentPage.value - 1) * rowsPerPage.value + 1;

  int get endEntryIndex {
    if (filteredPayments.isEmpty) return 0;
    final end = currentPage.value * rowsPerPage.value;
    return end > filteredPayments.length ? filteredPayments.length : end;
  }

  void setSearchQuery(String val) {
    searchQuery.value = val;
    currentPage.value = 1;
  }

  void setStatusFilter(String? val) {
    if (val == null) return;
    selectedStatus.value = val;
    currentPage.value = 1;
  }

  void setPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
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
                      date: '05-10-26',
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
}
