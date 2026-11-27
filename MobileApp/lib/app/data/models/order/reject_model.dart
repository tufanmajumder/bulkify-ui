import 'dart:convert';

RejectedModel rejectedModelFromJson(String str) =>
    RejectedModel.fromJson(json.decode(str));

String rejectedModelToJson(RejectedModel data) => json.encode(data.toJson());

class RejectedModel {
  dynamic success;
  dynamic message;
  dynamic code;
  dynamic encrypted;
  Data? data;

  RejectedModel({
    this.success,
    this.message,
    this.code,
    this.encrypted,
    this.data,
  });

  factory RejectedModel.fromJson(dynamic input) {
    if (input == null) return RejectedModel();
    if (input is String) return rejectedModelFromJson(input);
    if (input is! Map) return RejectedModel();

    final json = Map<String, dynamic>.from(input);

    Data? dataObj;
    if (json["data"] != null) {
      if (json["data"] is Map) {
        dataObj = Data.fromJson(Map<String, dynamic>.from(json["data"]));
      } else if (json["data"] is List) {
        dataObj = Data(
          items: (json["data"] as List).map((x) => Item.fromJson(x)).toList(),
          page: json["page"] ?? 1,
          pageSize: json["pagesize"] ?? 10,
          totalCount: (json["data"] as List).length,
          totalPages: 1,
        );
      }
    } else if (json["items"] != null && json["items"] is List) {
      dataObj = Data.fromJson(json);
    }

    return RejectedModel(
      success: json["success"],
      message: json["message"],
      code: json["code"],
      encrypted: json["encrypted"],
      data: dataObj,
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "code": code,
    "encrypted": encrypted,
    "data": data?.toJson(),
  };
}

class Data {
  List<Item>? items;
  dynamic page;
  dynamic pageSize;
  dynamic totalCount;
  dynamic totalPages;

  Data({
    this.items,
    this.page,
    this.pageSize,
    this.totalCount,
    this.totalPages,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    dynamic rawItems = json["items"] ?? json["orders"] ?? json["orderlist"] ?? json["data"];
    List<Item> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems
          .map((x) => Item.fromJson(x is Map ? Map<String, dynamic>.from(x) : {}))
          .toList();
    }

    return Data(
      items: parsedItems,
      page: json["page"],
      pageSize: json["pagesize"] ?? json["pageSize"],
      totalCount: json["totalcount"] ?? json["totalCount"],
      totalPages: json["totalpages"] ?? json["totalPages"],
    );
  }

  Map<String, dynamic> toJson() => {
    "items": items != null
        ? List<dynamic>.from(items!.map((x) => x.toJson()))
        : [],
    "page": page,
    "pagesize": pageSize,
    "totalcount": totalCount,
    "totalpages": totalPages,
  };
}

class Item {
  dynamic orderNumber;
  dynamic orderKey;
  dynamic restaurantName;
  dynamic deliveryAddress;
  dynamic amount;
  dynamic orderstatus;
  dynamic status;
  dynamic deliveryMethod;
  dynamic customerName;
  dynamic customerPhone;
  dynamic totalTax;
  dynamic taxes;
  List<Map<String, dynamic>> items;
  Map<String, dynamic> raw;

  Item({
    this.orderNumber,
    this.orderKey,
    this.restaurantName,
    this.deliveryAddress,
    this.amount,
    this.orderstatus,
    this.status,
    this.deliveryMethod,
    this.customerName,
    this.customerPhone,
    this.totalTax,
    this.taxes,
    this.items = const [],
    this.raw = const {},
  });

  factory Item.fromJson(dynamic rawJson) {
    if (rawJson == null || rawJson is! Map) {
      return Item();
    }
    final json = Map<String, dynamic>.from(rawJson);

    String store = '';
    if (json["restaurantname"] != null &&
        json["restaurantname"].toString().trim().isNotEmpty) {
      store = json["restaurantname"].toString().trim();
    } else if (json["restaurantName"] != null &&
        json["restaurantName"].toString().trim().isNotEmpty) {
      store = json["restaurantName"].toString().trim();
    } else if (json["storename"] != null &&
        json["storename"].toString().trim().isNotEmpty) {
      store = json["storename"].toString().trim();
    } else if (json["storeName"] != null &&
        json["storeName"].toString().trim().isNotEmpty) {
      store = json["storeName"].toString().trim();
    } else if (json["store"] != null) {
      if (json["store"] is Map) {
        store = (json["store"]["name"] ?? json["store"]["storename"] ?? '')
            .toString()
            .trim();
      } else {
        store = json["store"].toString().trim();
      }
    }

    String address = '';
    if (json["deliveryaddress"] != null &&
        json["deliveryaddress"].toString().trim().isNotEmpty) {
      address = json["deliveryaddress"].toString().trim();
    } else if (json["deliveryAddress"] != null &&
        json["deliveryAddress"].toString().trim().isNotEmpty) {
      address = json["deliveryAddress"].toString().trim();
    } else if (json["address"] != null &&
        json["address"].toString().trim().isNotEmpty) {
      address = json["address"].toString().trim();
    } else if (json["drop"] != null) {
      if (json["drop"] is Map) {
        address = (json["drop"]["address"] ??
                json["drop"]["addressline"] ??
                json["drop"]["city"] ??
                '')
            .toString()
            .trim();
      } else {
        address = json["drop"].toString().trim();
      }
    }

    final String resolvedOrderKey = (json["orderkey"] ??
            json["orderKey"] ??
            json["order_key"] ??
            json["id"] ??
            '')
        .toString()
        .trim();

    final String resolvedOrderNum = (json["ordernumber"] ??
            json["orderNumber"] ??
            json["order_number"] ??
            (resolvedOrderKey.isNotEmpty ? resolvedOrderKey : ''))
        .toString()
        .trim();

    final resolvedAmount =
        json["amount"] ?? json["total"] ?? json["payout"] ?? json["price"] ?? 0;
    final resolvedStatus =
        json["status"] ?? json["orderstatus"] ?? json["orderStatus"] ?? json["state"];
    final resolvedOrderStatus =
        json["orderstatus"] ?? json["orderStatus"] ?? json["status"] ?? json["state"];
    final resolvedMethod = json["deliverymethod"] ??
        json["deliveryMethod"] ??
        json["delivermethod"] ??
        json["method"] ??
        'van';

    String custName = '';
    if (json["customer"] != null) {
      if (json["customer"] is Map) {
        custName = (json["customer"]["name"] ??
                json["customer"]["fullname"] ??
                json["customer"]["userName"] ??
                '')
            .toString()
            .trim();
      } else {
        custName = json["customer"].toString().trim();
      }
    }
    if (custName.isEmpty) {
      custName = (json["customername"] ??
              json["customerName"] ??
              json["clientname"] ??
              json["clientName"] ??
              (json["drop"] is Map ? (json["drop"]["name"] ?? json["drop"]["contactname"] ?? json["drop"]["customername"]) : '') ??
              (json["recipient"] is Map ? (json["recipient"]["name"] ?? json["recipient"]["fullname"]) : '') ??
              '')
          .toString()
          .trim();
    }

    String custPhone = '';
    if (json["customer"] != null && json["customer"] is Map) {
      custPhone = (json["customer"]["phone"] ??
              json["customer"]["contactnumber"] ??
              json["customer"]["mobilenumber"] ??
              '')
          .toString()
          .trim();
    }
    if (custPhone.isEmpty) {
      custPhone = (json["customerphone"] ??
              json["customerPhone"] ??
              json["contactnumber"] ??
              json["phone"] ??
              (json["drop"] is Map ? (json["drop"]["phone"] ?? json["drop"]["contactnumber"]) : '') ??
              (json["recipient"] is Map ? (json["recipient"]["phone"] ?? json["recipient"]["contactnumber"]) : '') ??
              '')
          .toString()
          .trim();
    }

    dynamic rawItemList = json["items"] ??
        json["orderitems"] ??
        json["order_items"] ??
        json["orderItems"] ??
        json["products"] ??
        json["product_list"] ??
        json["orderlines"] ??
        json["order_lines"] ??
        json["orderLines"] ??
        json["lines"] ??
        (json["cart"] is Map
            ? (json["cart"]["items"] ?? json["cart"]["lines"])
            : json["cart"]) ??
        (json["details"] is Map ? json["details"]["items"] : json["details"]);

    final List<Map<String, dynamic>> parsedItems = parseOrderItems(rawItemList);

    dynamic rawTaxes = json["taxes"] ?? json["tax"] ?? json["tax_details"] ?? json["taxdetails"];
    final double calculatedTax = calculateTotalTax(rawTaxes);

    return Item(
      orderNumber: resolvedOrderNum,
      orderKey: resolvedOrderKey,
      restaurantName: store.isNotEmpty ? store : 'Store',
      deliveryAddress: address,
      amount: resolvedAmount,
      orderstatus: resolvedOrderStatus,
      status: resolvedStatus,
      deliveryMethod: resolvedMethod,
      customerName: custName,
      customerPhone: custPhone,
      totalTax: calculatedTax,
      taxes: rawTaxes,
      items: parsedItems,
      raw: json,
    );
  }

  static double calculateTotalTax(dynamic source) {
    if (source == null) return 0.0;
    dynamic list = source;
    if (list is String) {
      try {
        list = json.decode(list);
      } catch (_) {
        return 0.0;
      }
    }
    if (list is Map) {
      list = list['taxes'] ?? list['tax'] ?? list['items'] ?? list['data'];
    }
    if (list is! List) return 0.0;

    double total = 0.0;
    for (final t in list) {
      if (t == null) continue;
      if (t is num) {
        total += t.toDouble();
      } else if (t is Map) {
        final val = t['tax_amount'] ??
            t['taxAmount'] ??
            t['amount'] ??
            t['value'] ??
            t['tax_value'] ??
            t['tax'];
        if (val is num) {
          total += val.toDouble();
        } else if (val != null) {
          final parsed = double.tryParse(val.toString().replaceAll('₹', '').replaceAll(',', '').trim());
          if (parsed != null) {
            total += parsed;
          }
        }
      }
    }
    return total;
  }

  static List<Map<String, dynamic>> parseOrderItems(dynamic source) {
    if (source == null) return [];
    dynamic list = source;
    if (list is String) {
      try {
        list = json.decode(list);
      } catch (_) {
        return [];
      }
    }
    if (list is Map) {
      list = list["items"] ??
          list["orderitems"] ??
          list["order_items"] ??
          list["orderItems"] ??
          list["products"] ??
          list["lines"] ??
          list["orderlines"] ??
          list["order_lines"] ??
          list["details"] ??
          list["data"];
    }
    if (list is! List) return [];

    final List<Map<String, dynamic>> result = [];
    for (final raw in list) {
      if (raw == null) continue;
      if (raw is! Map) {
        result.add({
          'name': raw.toString(),
          'quantity': '1 pc',
          'price': '',
          'raw': raw,
        });
        continue;
      }
      final m = Map<String, dynamic>.from(raw);

      // Extract item name
      String name = '';
      if (m['product'] is Map) {
        final p = Map<String, dynamic>.from(m['product']);
        name = (p['name'] ??
                p['title'] ??
                p['productname'] ??
                p['productName'] ??
                p['itemname'] ??
                '')
            .toString()
            .trim();
      } else if (m['item'] is Map) {
        final it = Map<String, dynamic>.from(m['item']);
        name = (it['name'] ?? it['title'] ?? it['itemname'] ?? '')
            .toString()
            .trim();
      }
      if (name.isEmpty) {
        name = (m['name'] ??
                m['itemname'] ??
                m['itemName'] ??
                m['productname'] ??
                m['productName'] ??
                m['title'] ??
                m['item_name'] ??
                m['product_name'] ??
                m['description'] ??
                m['sku_name'] ??
                m['skuname'] ??
                '')
            .toString()
            .trim();
      }
      if (name.isEmpty) {
        name = 'Item';
      }

      // Extract quantity and unit
      dynamic rawQty = m['quantity'] ??
          m['qty'] ??
          m['count'] ??
          m['units'] ??
          m['unit_count'] ??
          m['unitcount'] ??
          m['quantity_unit'] ??
          m['ordered_quantity'] ??
          m['orderedQuantity'] ??
          m['ordered_qty'] ??
          (m['product'] is Map ? m['product']['quantity'] : null);

      dynamic rawUnit = m['unit'] ??
          m['uom'] ??
          m['unit_of_measure'] ??
          m['unit_name'] ??
          m['unitname'] ??
          m['pack'] ??
          m['package_type'] ??
          (m['product'] is Map
              ? (m['product']['unit'] ?? m['product']['uom'])
              : null);

      String formattedQty = '';
      if (rawQty != null && rawQty.toString().trim().isNotEmpty) {
        final qStr = rawQty.toString().trim();
        // If qStr already contains letters (e.g. "1 pc", "2 cans", "500 g")
        if (RegExp(r'[a-zA-Z]').hasMatch(qStr)) {
          formattedQty = qStr;
        } else {
          final num? qNum = num.tryParse(qStr);
          final String displayNum =
              (qNum != null && qNum == qNum.roundToDouble())
                  ? qNum.toInt().toString()
                  : qStr;
          if (rawUnit != null && rawUnit.toString().trim().isNotEmpty) {
            formattedQty = '$displayNum ${rawUnit.toString().trim()}';
          } else {
            formattedQty = '$displayNum pc';
          }
        }
      } else {
        if (rawUnit != null && rawUnit.toString().trim().isNotEmpty) {
          formattedQty = '1 ${rawUnit.toString().trim()}';
        } else {
          formattedQty = '1 pc';
        }
      }

      // Extract price
      dynamic rawPrice = m['price'] ??
          m['itemprice'] ??
          m['itemPrice'] ??
          m['unitprice'] ??
          m['unitPrice'] ??
          m['unit_price'] ??
          m['amount'] ??
          m['rate'] ??
          m['total'] ??
          m['subtotal'] ??
          m['cost'] ??
          (m['product'] is Map
              ? (m['product']['price'] ?? m['product']['unitprice'])
              : null);

      String formattedPrice = '';
      if (rawPrice != null && rawPrice.toString().trim().isNotEmpty) {
        final pStr = rawPrice.toString().trim();
        if (pStr.startsWith('₹')) {
          formattedPrice = pStr;
        } else {
          final num? pNum = num.tryParse(pStr);
          if (pNum != null) {
            formattedPrice = (pNum == pNum.roundToDouble())
                ? '₹ ${pNum.toInt()}'
                : '₹ ${pNum.toStringAsFixed(2)}';
          } else {
            formattedPrice = '₹ $pStr';
          }
        }
      }

      result.add({
        'name': name,
        'quantity': formattedQty,
        'price': formattedPrice,
        'amount': rawPrice,
        'raw': m,
      });
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
    "ordernumber": orderNumber,
    "orderkey": orderKey,
    "restaurantname": restaurantName,
    "deliveryaddress": deliveryAddress,
    "amount": amount,
    "orderstatus": orderstatus,
    "status": status,
    "deliverymethod": deliveryMethod,
    "customername": customerName,
    "customerphone": customerPhone,
    "totaltax": totalTax,
    "taxes": taxes,
    "items": items,
  };
}
