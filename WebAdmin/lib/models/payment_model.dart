import 'package:intl/intl.dart';

class PaymentModel {
  final String paymentKey;
  final String orderId;
  final String paymentId;
  final String utrRrn;
  final String paymentMethod;
  final String customerName;
  final String customerSubtext;
  final String createdOn;
  final String date;
  final String time;
  final String status;
  final String amount;
  final String isoCurrency;
  final String terminal;
  final String channel;

  PaymentModel({
    this.paymentKey = '',
    required this.orderId,
    required this.paymentId,
    required this.utrRrn,
    required this.paymentMethod,
    required this.customerName,
    this.customerSubtext = 'NA',
    this.createdOn = '',
    required this.date,
    required this.time,
    required this.status,
    required this.amount,
    this.isoCurrency = 'INR',
    this.terminal = '-',
    this.channel = '-',
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    String parseString(dynamic val, {String fallback = '-'}) {
      if (val == null) return fallback;
      final str = val.toString().trim();
      if (str.isEmpty || str == 'null') return fallback;
      return str;
    }

    final rawAmount =
        json['paymentamount'] ?? json['totalamount'] ?? json['amount'];
    String formattedAmount = '0.00';
    if (rawAmount != null) {
      if (rawAmount is num) {
        formattedAmount = rawAmount.toStringAsFixed(2);
      } else {
        var str = rawAmount.toString().trim();
        if (str.startsWith('₹') || str.startsWith('\$')) {
          str = str.substring(1).trim();
        }
        final n = double.tryParse(str);
        if (n != null) {
          formattedAmount = n.toStringAsFixed(2);
        } else {
          formattedAmount = str.isEmpty ? '-' : str;
        }
      }
    }

    final rawCreated = (json['createdon'] ?? '').toString().trim();
    String dateStr = '-';
    String timeStr = '-';

    if (rawCreated.isNotEmpty && rawCreated != '-' && rawCreated != 'null') {
      try {
        DateTime time = DateTime.parse(rawCreated);
        String formattedTime = DateFormat('hh:mm:ss a').format(time.toUtc());
        timeStr = formattedTime;
        dateStr = DateFormat(
          'dd-MM-yyyy',
        ).format(DateTime.parse(rawCreated.split("T")[0]));
      } catch (_) {
        dateStr = '-';
        timeStr = '-';
      }
    } else {
      dateStr = '-';
      timeStr = '-';
    }

    return PaymentModel(
      paymentKey: parseString(json['paymentkey']),
      orderId: parseString(json['salesorderid']),
      paymentId: parseString(json['paymentid']),
      utrRrn: parseString(json['transactionref']),
      paymentMethod: parseString(json['paymentmode']),
      customerName: parseString(json['customername']),
      createdOn: rawCreated,
      date: dateStr,
      time: timeStr,
      status: parseString(json['paymentstatus'], fallback: 'Pending'),
      amount: formattedAmount,
      isoCurrency: parseString(json['isocurrency'], fallback: 'INR'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentkey': paymentKey,
      'salesorderid': orderId,
      'paymentid': paymentId,
      'transactionref': utrRrn,
      'customername': customerName,
      'paymentmode': paymentMethod,
      'isocurrency': isoCurrency,
      'createdon': createdOn,
      'paymentstatus': status,
      'paymentamount': amount,
    };
  }
}
