class PaymentModel {
  final String orderId;
  final String paymentId;
  final String utrRrn;
  final String paymentMethod;
  final String customerName;
  final String customerSubtext;
  final String date;
  final String time;
  final String status;
  final String amount;

  PaymentModel({
    required this.orderId,
    required this.paymentId,
    required this.utrRrn,
    required this.paymentMethod,
    required this.customerName,
    this.customerSubtext = 'NA',
    required this.date,
    required this.time,
    required this.status,
    required this.amount,
  });
}
