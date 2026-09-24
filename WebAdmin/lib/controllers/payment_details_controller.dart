import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:admin_app/models/payment_model.dart';
import 'package:admin_app/service/payment_service.dart';

class PaymentDetailsController extends GetxController {
  final Rxn<PaymentModel> paymentDetail = Rxn<PaymentModel>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  late final PaymentService _paymentService;

  @override
  void onInit() {
    super.onInit();
    _paymentService = Get.isRegistered<PaymentService>()
        ? Get.find<PaymentService>()
        : Get.put(PaymentService());

    // Check if initial payment model was passed in arguments
    final arg = Get.arguments;
    if (arg is PaymentModel) {
      paymentDetail.value = arg;
      if (arg.paymentKey.isNotEmpty) {
        fetchPaymentDetails(arg.paymentKey);
      }
    }
  }

  /// Calls payments/v1/get-by-key API endpoint using paymentkey payload
  Future<void> fetchPaymentDetails(String paymentKey) async {
    if (paymentKey.trim().isEmpty) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _paymentService.getPaymentDetails(
        paymentKey: paymentKey.trim(),
      );

      if (result.isTokenExpired) {
        errorMessage.value = 'Session expired. Please log in again.';
        Get.offAllNamed('/login');
        return;
      }

      if (result.success && result.payment != null) {
        final current = paymentDetail.value;
        final fetched = result.payment!;

        paymentDetail.value = PaymentModel(
          paymentKey: fetched.paymentKey.isNotEmpty
              ? fetched.paymentKey
              : (current?.paymentKey ?? paymentKey),
          orderId: (fetched.orderId.isNotEmpty && fetched.orderId != '-')
              ? fetched.orderId
              : (current?.orderId ?? '-'),
          paymentId: (fetched.paymentId.isNotEmpty && fetched.paymentId != '-')
              ? fetched.paymentId
              : (current?.paymentId ?? '-'),
          utrRrn: (fetched.utrRrn.isNotEmpty && fetched.utrRrn != '-')
              ? fetched.utrRrn
              : (current?.utrRrn ?? '-'),
          paymentMethod:
              (fetched.paymentMethod.isNotEmpty && fetched.paymentMethod != '-')
              ? fetched.paymentMethod
              : (current?.paymentMethod ?? '-'),
          customerName:
              (fetched.customerName.isNotEmpty &&
                  fetched.customerName != 'Customer')
              ? fetched.customerName
              : (current?.customerName ?? 'Customer'),
          customerSubtext:
              (fetched.customerSubtext.isNotEmpty &&
                  fetched.customerSubtext != 'NA')
              ? fetched.customerSubtext
              : (current?.customerSubtext ?? '-'),
          createdOn: fetched.createdOn.isNotEmpty
              ? fetched.createdOn
              : (current?.createdOn ?? ''),
          date: (fetched.date.isNotEmpty && fetched.date != '-')
              ? fetched.date
              : (current?.date ?? '-'),
          time: (fetched.time.isNotEmpty && fetched.time != '-')
              ? fetched.time
              : (current?.time ?? '-'),
          status: (fetched.status.isNotEmpty && fetched.status != 'Pending')
              ? fetched.status
              : (current?.status ?? 'Pending'),
          amount: (fetched.amount.isNotEmpty && fetched.amount != '₹ 0.00')
              ? fetched.amount
              : (current?.amount ?? '₹ 0.00'),
          isoCurrency: fetched.isoCurrency.isNotEmpty
              ? fetched.isoCurrency
              : (current?.isoCurrency ?? 'INR'),
          terminal: (fetched.terminal.isNotEmpty && fetched.terminal != '-')
              ? fetched.terminal
              : (current?.terminal ?? '-'),
          channel: (fetched.channel.isNotEmpty && fetched.channel != '-')
              ? fetched.channel
              : (current?.channel ?? '-'),
        );
      } else {
        errorMessage.value = result.message;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PaymentDetailsController] Error fetching details: $e');
      }
      errorMessage.value = 'Failed to load payment details';
    } finally {
      isLoading.value = false;
    }
  }
}
