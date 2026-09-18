import 'package:intl/intl.dart';

class OrderModel {
  final String id;
  final String salesorderId;
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
    this.salesorderId = '',
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
    String? salesorderId,
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
      salesorderId: salesorderId ?? this.salesorderId,
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
    final salesIdRaw =
        json['salesorder_id'] ??
        json['salesorder_number'] ??
        json['ordernumber'] ??
        json['id'] ??
        json['_id'] ??
        '-';
    final salesIdStr = salesIdRaw.toString().trim();

    // Extract ID ("salesorder_number", "ordernumber", "salesorder_id", "order_number")
    final idRaw =
        json['salesorder_number'] ??
        json['ordernumber'] ??
        json['salesorder_id'] ??
        json['order_number'] ??
        json['orderNo'] ??
        json['id'] ??
        json['_id'] ??
        json['order_id'] ??
        json['orderId'] ??
        '-';
    final idDisplay = idRaw.toString().trim();

    // Extract Date & Time ("created_time", "created_at", "salesorder_date", "date")
    final dateRaw = json['created_time'];
    final dateStr = _formatCreatedTime(dateRaw);

    // Extract Customer Name ("customer_name", "customerName", "name", "customer")
    final customerRaw =
        json['customer_name'] ??
        json['customerName'] ??
        json['name'] ??
        json['customer'];
    String customerStr = '-';
    if (customerRaw != null &&
        customerRaw.toString().trim().isNotEmpty &&
        customerRaw.toString().trim() != 'null') {
      customerStr = customerRaw.toString().trim();
    }

    // Extract Company / Restaurant Name ("company_name", "restaurantname", "resturentname")
    final companyRaw =
        json['company_name'] ??
        json['restaurantname'] ??
        json['resturentname'] ??
        json['company_name'] ??
        json['company'] ??
        json['restaurant_name'] ??
        json['resturent_name'] ??
        json['restaurantName'] ??
        json['companyName'];
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

    // Extract Customer Email / Delivery Address ("customer_email", "deliveryaddress")
    final emailRaw =
        json['customer_email'] ??
        json['deliveryaddress'] ??
        json['delivery_address'] ??
        json['customerEmail'] ??
        json['email'] ??
        json['address'] ??
        '-';
    String emailStr = emailRaw != null ? emailRaw.toString().trim() : '-';

    // Extract Payment Status
    final paymentRaw = json['paid_status'] ?? '-';
    String paymentStr = paymentRaw != null ? paymentRaw.toString().trim() : '-';

    // Extract Order Status ("status", "orderstatus", "salesorder_status")
    final statusRaw = json['shipped_status'] ?? '-';
    String statusStr = statusRaw != null ? statusRaw.toString().trim() : '-';

    // Extract Amount ("total", "amount", "grand_total")
    final amountRaw = json['total'] ?? '0.00';
    String amountStr = amountRaw != null
        ? "${double.parse(amountRaw.toString().trim()).toStringAsFixed(2)}"
        : '0.00';

    return OrderModel(
      id: idDisplay,
      salesorderId: salesIdStr,
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
      print("input...$inputString");
      DateTime dateTime = DateTime.parse(inputString);
      String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
      String formattedTime = DateFormat('hh:mm:ss a').format(dateTime);
      DateTime parsedDate = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss",
      ).parse(inputString);
      String formattedResult1 = DateFormat("hh:mm:ss a").format(parsedDate);
      String formattedResult11 = DateFormat("dd-MM-yyyy").format(parsedDate);
      print(formattedTime);
      print(formattedDate);
      //print(formattedResult);
      print(formattedResult1);
      print(formattedResult11);
      return '$formattedResult11 $formattedResult1';
    } catch (_) {
      DateTime? dt = DateTime.tryParse(inputString);
      if (dt == null && inputString.contains(' ')) {
        dt = DateTime.tryParse(inputString.replaceFirst(' ', 'T'));
      }
      if (dt != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(dt);
        String formattedTime = DateFormat('hh:mm:ss a').format(dt);
        print(formattedTime);
        return '$formattedDate $formattedTime';
      }
      return inputString;
    }
  }
}
