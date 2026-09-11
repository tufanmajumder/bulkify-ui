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
    final raw = dateRaw.toString().trim();
    if (raw.isEmpty || raw == 'null' || raw == '-') return '-';

    DateTime? dt;
    // 1. Standard DateTime.tryParse (ISO 8601, "yyyy-MM-dd HH:mm:ss", etc.)
    dt = DateTime.tryParse(raw);
    if (dt == null && raw.contains(' ')) {
      dt = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    }

    // 2. Epoch integer check
    if (dt == null) {
      final epoch = int.tryParse(raw);
      if (epoch != null) {
        if (epoch > 100000000000) {
          dt = DateTime.fromMillisecondsSinceEpoch(epoch);
        } else {
          dt = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
        }
      }
    }

    // 3. Custom component parsing for common date patterns
    if (dt == null) {
      try {
        final parts = raw.split(RegExp(r'[\sT]+'));
        if (parts.isNotEmpty) {
          final datePart = parts[0];
          final timePart = parts.length > 1 ? parts[1] : '00:00:00';

          final dateComponents = datePart.split(RegExp(r'[-/.]'));
          int? yr, mo, dy;
          if (dateComponents.length == 3) {
            if (dateComponents[0].length == 4) {
              yr = int.tryParse(dateComponents[0]);
              mo = int.tryParse(dateComponents[1]);
              dy = int.tryParse(dateComponents[2]);
            } else if (dateComponents[2].length == 4) {
              yr = int.tryParse(dateComponents[2]);
              mo = int.tryParse(dateComponents[1]);
              dy = int.tryParse(dateComponents[0]);
            } else if (dateComponents[2].length == 2) {
              yr = 2000 + (int.tryParse(dateComponents[2]) ?? 0);
              mo = int.tryParse(dateComponents[1]);
              dy = int.tryParse(dateComponents[0]);
            }
          }

          final timeComponents = timePart.split(':');
          int hr = 0, min = 0, sec = 0;
          if (timeComponents.isNotEmpty) {
            hr = int.tryParse(timeComponents[0]) ?? 0;
          }
          if (timeComponents.length > 1) {
            min =
                int.tryParse(
                  timeComponents[1].replaceAll(RegExp(r'[^0-9]'), ''),
                ) ??
                0;
          }
          if (timeComponents.length > 2) {
            sec =
                int.tryParse(
                  timeComponents[2].replaceAll(RegExp(r'[^0-9]'), ''),
                ) ??
                0;
          }

          if (yr != null && mo != null && dy != null) {
            dt = DateTime(yr, mo, dy, hr, min, sec);
          }
        }
      } catch (_) {}
    }

    if (dt != null) {
      final dayStr = dt.day.toString().padLeft(2, '0');
      final monthStr = dt.month.toString().padLeft(2, '0');
      final yearStr = (dt.year % 100).toString().padLeft(2, '0');

      int hour = dt.hour;
      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      final hourStr = hour.toString().padLeft(2, '0');
      final minStr = dt.minute.toString().padLeft(2, '0');

      return '$dayStr-$monthStr-$yearStr $hourStr:$minStr $period';
    }

    return raw;
  }
}
