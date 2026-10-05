import 'package:intl/intl.dart';
import 'order_model.dart';

class SearchOrderItem {
  final String sku;
  final String name;
  final double rate;
  final int quantity;
  final double itemTotal;
  final String description;

  SearchOrderItem({
    required this.sku,
    required this.name,
    required this.rate,
    required this.quantity,
    required this.itemTotal,
    required this.description,
  });

  factory SearchOrderItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val != null) return double.tryParse(val.toString()) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    return SearchOrderItem(
      sku: json['sku']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      rate: parseDouble(json['rate']),
      quantity: parseInt(json['quantity']),
      itemTotal: parseDouble(json['item_total']),
      description: json['description']?.toString() ?? '',
    );
  }
}

class SearchOrderModel {
  final String orderkey;
  final String orgkey;
  final String salesorderid;
  final String ordernumber;
  final String ordertype;
  final String orderstatus;
  final String orderdate;
  final String ordersource;
  final String createdtime;
  final String? invoicenumber;
  final String customername;
  final String mobilenumber;
  final String phonenumber;
  final String customeremail;
  final String shippingstatus;
  final String deliverydate;
  final List<SearchOrderItem> items;
  final int itemcount;
  final String isocurrency;
  final double grandtotal;
  final double discount;
  final double taxamount;
  final double finalamount;
  final double dueamount;
  final String paymentstatus;

  SearchOrderModel({
    required this.orderkey,
    required this.orgkey,
    required this.salesorderid,
    required this.ordernumber,
    required this.ordertype,
    required this.orderstatus,
    required this.orderdate,
    required this.ordersource,
    required this.createdtime,
    this.invoicenumber,
    required this.customername,
    required this.mobilenumber,
    required this.phonenumber,
    required this.customeremail,
    required this.shippingstatus,
    required this.deliverydate,
    required this.items,
    required this.itemcount,
    required this.isocurrency,
    required this.grandtotal,
    required this.discount,
    required this.taxamount,
    required this.finalamount,
    required this.dueamount,
    required this.paymentstatus,
  });

  factory SearchOrderModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val != null) return double.tryParse(val.toString()) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val != null) return int.tryParse(val.toString()) ?? 0;
      return 0;
    }

    List<SearchOrderItem> parsedItems = [];
    if (json['items'] is List) {
      for (var item in json['items']) {
        if (item is Map<String, dynamic>) {
          parsedItems.add(SearchOrderItem.fromJson(item));
        } else if (item is Map) {
          parsedItems.add(
            SearchOrderItem.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return SearchOrderModel(
      orderkey: json['orderkey']?.toString() ?? '',
      orgkey: json['orgkey']?.toString() ?? '',
      salesorderid: json['salesorderid']?.toString() ?? '',
      ordernumber: json['ordernumber']?.toString() ?? '',
      ordertype: json['ordertype']?.toString() ?? '',
      orderstatus: json['orderstatus']?.toString() ?? '',
      orderdate: json['orderdate']?.toString() ?? '',
      ordersource: json['ordersource']?.toString() ?? '',
      createdtime: json['createdtime']?.toString() ?? '',
      invoicenumber: json['invoicenumber']?.toString(),
      customername: json['customername']?.toString() ?? '',
      mobilenumber: json['mobilenumber']?.toString() ?? '',
      phonenumber: json['phonenumber']?.toString() ?? '',
      customeremail: json['customeremail']?.toString() ?? '',
      shippingstatus: json['shippingstatus']?.toString() ?? '',
      deliverydate: json['deliverydate']?.toString() ?? '',
      items: parsedItems,
      itemcount: parseInt(json['itemcount']),
      isocurrency: json['isocurrency']?.toString() ?? '',
      grandtotal: parseDouble(json['grandtotal']),
      discount: parseDouble(json['discount']),
      taxamount: parseDouble(json['taxamount']),
      finalamount: parseDouble(json['finalamount']),
      dueamount: parseDouble(json['dueamount']),
      paymentstatus: json['paymentstatus']?.toString() ?? '',
    );
  }

  /// Converts SearchOrderModel into OrderModel for display in the order list table
  OrderModel toOrderModel() {
    String formattedDate = '-';
    if (createdtime.isNotEmpty && createdtime != 'null') {
      try {
        DateTime dateTime = DateTime.parse(createdtime);
        String datePart = DateFormat('dd-MM-yyyy').format(dateTime.toLocal());
        String timePart = DateFormat('hh:mm:ss a').format(dateTime.toLocal());
        formattedDate = '$datePart $timePart';
      } catch (_) {
        formattedDate = createdtime;
      }
    }

    String formattedPaymentStatus = paymentstatus;
    if (paymentstatus.toLowerCase() == 'paid') {
      formattedPaymentStatus = 'Paid';
    } else if (paymentstatus.toLowerCase() == 'unpaid') {
      formattedPaymentStatus = 'Unpaid';
    } else if (paymentstatus.toLowerCase() == 'pending') {
      formattedPaymentStatus = 'Pending';
    }

    String formattedOrderStatus = shippingstatus;
    if (shippingstatus.toLowerCase() == 'fulfilled') {
      formattedOrderStatus = 'Fulfilled';
    } else if (shippingstatus.toLowerCase() == 'pending') {
      formattedOrderStatus = 'Pending';
    }

    return OrderModel(
      id: ordernumber.isNotEmpty ? ordernumber : '-',
      orderkey: orderkey.isNotEmpty ? orderkey : salesorderid,
      date: formattedDate,
      customerName: customername.isNotEmpty ? customername : '-',
      companyName: '',
      customerEmail: customeremail.isNotEmpty ? customeremail : '-',
      paymentStatus: formattedPaymentStatus,
      orderStatus: formattedOrderStatus,
      amount: finalamount.toStringAsFixed(2),
    );
  }
}
