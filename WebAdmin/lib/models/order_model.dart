import 'package:intl/intl.dart';

class OrderModel {
  final String id;
  final String orderkey;
  final String date;
  final String customerName;
  final String companyName;
  final String channel;
  final String customerEmail;
  final String paymentStatus; // 'Paid', 'Pending', 'Failed', 'Refunded'
  final String orderStatus; // 'Confirmed', 'Accepted', 'Pending', 'Cancelled'
  final String shippingStatus; // 'Pending', 'Packed', 'In transit', 'Delivered'
  final String amount;

  OrderModel({
    required this.id,
    this.orderkey = '',
    required this.date,
    required this.customerName,
    this.companyName = '',
    this.channel = '',
    required this.customerEmail,
    required this.paymentStatus,
    required this.orderStatus,
    this.shippingStatus = '',
    required this.amount,
  });

  OrderModel copyWith({
    String? id,
    String? orderkey,
    String? date,
    String? customerName,
    String? companyName,
    String? channel,
    String? customerEmail,
    String? paymentStatus,
    String? orderStatus,
    String? shippingStatus,
    String? amount,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderkey: orderkey ?? this.orderkey,
      date: date ?? this.date,
      customerName: customerName ?? this.customerName,
      companyName: companyName ?? this.companyName,
      channel: channel ?? this.channel,
      customerEmail: customerEmail ?? this.customerEmail,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      shippingStatus: shippingStatus ?? this.shippingStatus,
      amount: amount ?? this.amount,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Extract salesorder_id specifically
    final salesIdRaw = json['orderkey'] ?? '';
    final salesIdStr = salesIdRaw.toString().trim();

    // Extract ID ("ordernumber", "salesorder_number", "salesorderid", "orderkey")
    final idRaw = json['ordernumber'] ?? '-';
    final idDisplay = idRaw.toString().trim();

    // Extract Date & Time ("createdtime", "created_time", "created_at", "date", "order_date", "orderdate")
    final dateRaw = json['createdtime'];
    final dateStr = _formatCreatedTime(dateRaw);

    // Extract Customer Name ("customername", "customer_name", "customerName", "name", "customer", "contact_name")
    final customerRaw = json['customername'];
    String customerStr = '-';
    if (customerRaw != null &&
        customerRaw.toString().trim().isNotEmpty &&
        customerRaw.toString().trim() != 'null') {
      customerStr = _formatTitleCase(customerRaw.toString().trim());
    }

    // Extract Company / Restaurant Name ("companyname", "company_name", "restaurantname", "resturentname", "company")
    final companyRaw =
        json['companyname'] ??
        json['company_name'] ??
        json['companyName'] ??
        json['company'] ??
        json['restaurantname'] ??
        json['restaurant_name'] ??
        json['resturentname'];
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

    // Extract Customer Email / Delivery Address ("customeremail", "customer_email", "email", "deliveryaddress", "delivery_address")
    final emailRaw = json['customeremail'] ?? '-';
    String emailStr = emailRaw != null ? emailRaw.toString().trim() : '-';

    // Extract Channel ("channel", "channel_name", "channelName")
    final channelRaw =
        json['channel'] ?? json['channel_name'] ?? json['channelName'];
    String channelStr =
        channelRaw != null ? channelRaw.toString().trim() : '';

    // Extract Payment Status ("paymentstatus", "payment_status", "paid_status", "status")
    final paymentRaw = json['paymentstatus'] ?? '-';
    String paymentStr = paymentRaw != null ? paymentRaw.toString().trim() : '-';

    // Extract Order Status ("orderstatus", "order_status", "salesorder_status", "status")
    final orderStatusRaw =
        json['orderstatus'] ??
        json['order_status'] ??
        json['salesorder_status'] ??
        json['salesorderstatus'] ??
        json['status'];
    String orderStatusStr = '-';
    if (orderStatusRaw != null &&
        orderStatusRaw.toString().trim().isNotEmpty &&
        orderStatusRaw.toString().trim() != 'null') {
      orderStatusStr = orderStatusRaw.toString().trim();
    }

    // Extract Shipping Status ("shippingstatus", "shipping_status", "shipped_status")
    final shippingStatusRaw = json['shippingstatus'] ?? 'Pending';
    String shippingStatusStr = shippingStatusRaw != null
        ? shippingStatusRaw.toString().trim()
        : 'Pending';

    // Extract Amount ("finalamount", "final_amount", "grandtotal", "grand_total", "total", "amount")
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
      channel: channelStr,
      customerEmail: emailStr,
      paymentStatus: paymentStr,
      orderStatus: orderStatusStr,
      shippingStatus: shippingStatusStr,
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
    'shippingStatus': shippingStatus,
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

  static String _formatTitleCase(String input) {
    final clean = input.trim();
    if (clean.isEmpty || clean == 'null' || clean == '-') return clean;
    return clean
        .split(RegExp(r'\s+'))
        .map((w) => w.isEmpty
            ? ''
            : (w.length == 1
                ? w.toUpperCase()
                : w[0].toUpperCase() + w.substring(1).toLowerCase()))
        .join(' ');
  }
}
