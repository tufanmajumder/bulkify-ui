import 'package:intl/intl.dart';

class OrderModel {
  final String id;
  final String orderkey;
  final String date;
  final String customerName;
  final String companyName;
  final String customerEmail;
  final String paymentStatus; // 'Paid', 'Pending', 'Failed', 'Refunded'
  final String
  orderStatus; // 'Delivered', 'Dispatched', 'Out for Delivery', 'Ready to Pickup', 'Cancelled'
  final String amount;

  OrderModel({
    required this.id,
    this.orderkey = '',
    required this.date,
    required this.customerName,
    this.companyName = '',
    required this.customerEmail,
    required this.paymentStatus,
    required this.orderStatus,
    required this.amount,
  });

  OrderModel copyWith({
    String? id,
    String? orderkey,
    String? date,
    String? customerName,
    String? companyName,
    String? customerEmail,
    String? paymentStatus,
    String? orderStatus,
    String? amount,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderkey: orderkey ?? this.orderkey,
      date: date ?? this.date,
      customerName: customerName ?? this.customerName,
      companyName: companyName ?? this.companyName,
      customerEmail: customerEmail ?? this.customerEmail,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      amount: amount ?? this.amount,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Extract salesorder_id specifically
    final salesIdRaw = json['orderkey'];
    final salesIdStr = salesIdRaw.toString().trim();

    // Extract ID ("ordernumber", "salesorder_number", "salesorderid", "orderkey")
    final idRaw = json['ordernumber'] ?? '-';
    final idDisplay = idRaw.toString().trim();

    // Extract Date & Time ("orderdate", "created_time", "created_at", "date")
    final dateRaw = json['orderdate'];
    final dateStr = _formatCreatedTime(dateRaw);

    // Extract Customer Name ("customername", "customer_name", "customerName", "name", "customer")
    final customerRaw = json['customername'];
    String customerStr = '-';
    if (customerRaw != null &&
        customerRaw.toString().trim().isNotEmpty &&
        customerRaw.toString().trim() != 'null') {
      customerStr = customerRaw.toString().trim();
    }

    // Extract Company / Restaurant Name ("company_name", "restaurantname", "resturentname")
    final companyRaw = json['companyname'];
    String companyStr = '';
    if (companyRaw != null &&
        companyRaw.toString().trim().isNotEmpty &&
        companyRaw.toString().trim() != 'null') {
      companyStr = companyRaw.toString().trim();
    }

    // Fallback if customerName is empty but companyName exists
    if (customerStr == '-' && companyStr.isNotEmpty) {
      customerStr = companyStr;
      companyStr = '';
    }

    // Extract Customer Email / Delivery Address ("customeremail", "customer_email", "deliveryaddress")
    final emailRaw = json['customeremail'] ?? '-';
    String emailStr = emailRaw != null ? emailRaw.toString().trim() : '-';

    // Extract Payment Status ("paymentstatus", "payment_status", "paid_status")
    final paymentRaw = json['paymentstatus'] ?? '-';
    String paymentStr = paymentRaw != null ? paymentRaw.toString().trim() : '-';

    // Extract Order Status ("orderstatus", "order_status", "shippingstatus", "shipped_status", "status")
    final statusRaw = json['shippingstatus'] ?? '-';
    String statusStr = statusRaw != null ? statusRaw.toString().trim() : '-';

    // Extract Amount ("finalamount", "grandtotal", "total", "amount")
    final amountRaw = json['finalamount'] ?? '0.00';
    String amountStr = '0.00';
    if (amountRaw != null) {
      final parsed = double.tryParse(amountRaw.toString().trim());
      if (parsed != null) {
        amountStr = parsed.toStringAsFixed(2);
      } else {
        amountStr = amountRaw.toString().trim();
      }
    }

    return OrderModel(
      id: idDisplay,
      orderkey: salesIdStr,
      date: dateStr,
      customerName: customerStr,
      companyName: companyStr,
      customerEmail: emailStr,
      paymentStatus: paymentStr,
      orderStatus: statusStr,
      amount: amountStr,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'customerName': customerName,
    'companyName': companyName,
    'customerEmail': customerEmail,
    'paymentStatus': paymentStatus,
    'orderStatus': orderStatus,
    'amount': amount,
  };

  static String _formatCreatedTime(dynamic dateRaw) {
    if (dateRaw == null) return '-';
    final String inputString = dateRaw.toString().trim();
    if (inputString.isEmpty || inputString == 'null' || inputString == '-') {
      return '-';
    }

    try {
      DateTime dateTime = DateTime.parse(inputString);
      String formattedDate = DateFormat(
        'dd-MM-yyyy',
      ).format(dateTime.toLocal());
      String formattedTime = DateFormat(
        'hh:mm:ss a',
      ).format(dateTime.toLocal());
      return '$formattedDate $formattedTime';
    } catch (_) {
      DateTime? dt = DateTime.tryParse(inputString);
      if (dt == null && inputString.contains(' ')) {
        dt = DateTime.tryParse(inputString.replaceFirst(' ', 'T'));
      }
      if (dt != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(dt.toLocal());
        String formattedTime = DateFormat('hh:mm:ss a').format(dt.toLocal());
        return '$formattedDate $formattedTime';
      }
      return inputString;
    }
  }
}
