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
    final rawAmount = json['paymentamount'] ?? json['totalamount'] ?? json['amount'];
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
          formattedAmount = str;
        }
      }
    }

    final rawCreated = (json['createdon']).toString();
    String dateStr = '-';
    String timeStr = '-';

    if (rawCreated.isNotEmpty && rawCreated != '-') {
      DateTime time = DateTime.parse(rawCreated);
      // 2. Format directly using UTC time (forces it to stay 12:24)
      String formattedTime = DateFormat('hh:mm:ss a').format(time.toUtc());
      print(formattedTime);
      timeStr = formattedTime;
      dateStr = DateFormat(
        'dd-MM-yyyy',
      ).format(DateTime.parse(rawCreated.split("T")[0]));
    } else {
      dateStr = '-';
      timeStr = '-';
    }

    // final terminalVal = json['terminal'];
    // final channelVal = json['channel'];

    return PaymentModel(
      paymentKey: (json['paymentkey'] ?? "-").toString(),
      orderId: (json['salesorderid'] ?? '-').toString(),
      paymentId: (json['paymentid'] ?? '-').toString(),
      utrRrn: (json['transactionref'] ?? '-').toString(),
      paymentMethod: (json['paymentmode'] ?? '-').toString(),
      customerName: (json['customername'] ?? 'Customer').toString(),
      createdOn: rawCreated,
      date: dateStr,
      time: timeStr,
      status: (json['paymentstatus'] ?? 'Pending').toString(),
      amount: formattedAmount,
      isoCurrency: (json['isocurrency'] ?? 'INR').toString(),
      // terminal:
      //     (terminalVal != null &&
      //         terminalVal.toString().trim().isNotEmpty &&
      //         terminalVal.toString() != 'null')
      //     ? terminalVal.toString()
      //     : '-',
      // channel:
      //     (channelVal != null &&
      //         channelVal.toString().trim().isNotEmpty &&
      //         channelVal.toString() != 'null')
      //     ? channelVal.toString()
      //     : '-',
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
