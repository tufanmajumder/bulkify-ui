import 'dart:convert';
import 'package:bulkify/app/data/models/order/reject_model.dart';

PendingOfferModel pendingOfferModelFromJson(dynamic str) =>
    PendingOfferModel.fromAny(str is String ? json.decode(str) : str);

String pendingOfferModelToJson(PendingOfferModel data) =>
    json.encode(data.toJson());

typedef PendingOfferItem = PendingOrderItem;

class PendingOfferModel {
  dynamic success;
  dynamic message;
  dynamic code;
  dynamic encrypted;
  dynamic data;
  List<PendingOrderItem> items;

  PendingOfferModel({
    this.success,
    this.message,
    this.code,
    this.encrypted,
    this.data,
    this.items = const [],
  });

  factory PendingOfferModel.fromJson(dynamic json) {
    return PendingOfferModel.fromAny(json);
  }

  factory PendingOfferModel.fromAny(dynamic input) {
    if (input == null) {
      return PendingOfferModel(items: []);
    }

    final List<PendingOrderItem> extracted = parseItems(input);
    print("PendingOfferModel.fromAny: extracted ${extracted.length} items");

    bool resolvedSuccess = true;
    String resolvedMessage = '';
    dynamic resolvedCode;
    dynamic resolvedEncrypted;

    if (input is Map) {
      final map = Map<String, dynamic>.from(input);
      resolvedSuccess =
          map["success"] == true ||
          map["code"] == 200 ||
          map["code"] == "200" ||
          extracted.isNotEmpty;
      resolvedMessage = map["message"]?.toString() ?? '';
      resolvedCode = map["code"];
      resolvedEncrypted = map["encrypted"];
    }

    return PendingOfferModel(
      success: resolvedSuccess,
      message: resolvedMessage,
      code: resolvedCode,
      encrypted: resolvedEncrypted,
      data: input,
      items: extracted,
    );
  }

  static List<PendingOrderItem> parseItems(dynamic source) {
    if (source == null) return [];

    dynamic data = source;
    if (data is String) {
      try {
        data = json.decode(data);
      } catch (e) {
        print("parseItems json.decode error: $e");
        return [];
      }
    }

    // Direct List: [ { ... }, { ... } ]
    if (data is List) {
      final List<PendingOrderItem> result = [];
      for (var item in data) {
        if (item is Map) {
          try {
            result.add(
              PendingOrderItem.fromJson(Map<String, dynamic>.from(item)),
            );
          } catch (e) {
            print("Error parsing pending order item from list: $e");
          }
        }
      }
      return result;
    }

    // Map: could be wrapped { "data": [ ... ] } or { "data": { "items": [ ... ] } }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      dynamic nested =
          map["data"] ??
          map["items"] ??
          map["orders"] ??
          map["offers"] ??
          map["orderlist"] ??
          map["pending"] ??
          map["pending_offers"] ??
          map["pendingOffers"] ??
          map["list"];

      if (nested != null) {
        final parsedNested = parseItems(nested);
        if (parsedNested.isNotEmpty) {
          return parsedNested;
        }
      }

      // If the map itself represents an order
      if (map.containsKey("assignmentkey") ||
          map.containsKey("orderkey") ||
          map.containsKey("ordernumber") ||
          map.containsKey("store")) {
        try {
          return [PendingOrderItem.fromJson(map)];
        } catch (e) {
          print("Error parsing single order item map: $e");
        }
      }
    }

    return [];
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "code": code,
    "encrypted": encrypted,
    "data": data,
    "items": items.map((x) => x.toJson()).toList(),
  };
}

class PendingOrderItem {
  final String? assignmentkey;
  final String? orderkey;
  final String? ordernumber;
  final String? state;
  final String? assignedon;
  final String? respondedon;
  final Store? store;
  final Drop? drop;
  final dynamic customer;
  final String? shipmentstatus;
  final String? slotstart;
  final dynamic amount;
  final dynamic payout;
  final Map<String, dynamic> raw;

  PendingOrderItem({
    this.assignmentkey,
    this.orderkey,
    this.ordernumber,
    this.state,
    this.assignedon,
    this.respondedon,
    this.store,
    this.drop,
    this.customer,
    this.shipmentstatus,
    this.slotstart,
    this.amount,
    this.payout,
    this.raw = const {},
  });

  factory PendingOrderItem.fromJson(Map<String, dynamic> json) {
    Store? storeObj;
    if (json["store"] != null && json["store"] is Map) {
      storeObj = Store.fromJson(Map<String, dynamic>.from(json["store"]));
    } else if (json["store"] != null && json["store"] is String) {
      storeObj = Store(name: json["store"].toString());
    }

    Drop? dropObj;
    if (json["drop"] != null && json["drop"] is Map) {
      dropObj = Drop.fromJson(Map<String, dynamic>.from(json["drop"]));
    } else if (json["drop"] != null && json["drop"] is String) {
      dropObj = Drop(city: json["drop"].toString());
    }

    return PendingOrderItem(
      assignmentkey: json["assignmentkey"]?.toString(),
      orderkey: (json["orderkey"] ?? json["orderKey"])?.toString(),
      ordernumber: (json["ordernumber"] ?? json["orderNumber"])?.toString(),
      state: json["state"]?.toString(),
      assignedon: json["assignedon"]?.toString(),
      respondedon: json["respondedon"]?.toString(),
      store: storeObj,
      drop: dropObj,
      customer: json["customer"],
      shipmentstatus: json["shipmentstatus"]?.toString(),
      slotstart: json["slotstart"]?.toString(),
      amount: json["amount"] ?? json["total"] ?? json["price"],
      payout: json["payout"] ?? json["amount"],
      raw: json,
    );
  }

  Map<String, dynamic> toAvailableOrderMap() {
    final String storeName =
        (store?.name != null && store!.name!.trim().isNotEmpty)
        ? store!.name!.trim()
        : (raw["restaurantname"] ??
                  raw["restaurantName"] ??
                  raw["storeName"] ??
                  'Store')
              .toString();

    // Bind address, statecode, pincode, country for location icon
    final List<String> addressParts = [];

    // 1. Address
    final String addr =
        (drop?.address ??
                drop?.addressline ??
                raw["address"] ??
                raw["addressline"] ??
                raw["deliveryaddress"] ??
                raw["deliveryAddress"] ??
                drop?.city ??
                '')
            .toString()
            .trim();
    if (addr.isNotEmpty) {
      addressParts.add(addr);
    }

    // 2. State Code
    final String stateCode =
        (drop?.statecode ??
                drop?.state ??
                raw["statecode"] ??
                raw["state_code"] ??
                raw["state"] ??
                '')
            .toString()
            .trim();
    if (stateCode.isNotEmpty && !addressParts.contains(stateCode)) {
      addressParts.add(stateCode);
    }

    // 3. Pincode
    final String pin =
        (drop?.pincode ??
                drop?.zip ??
                raw["pincode"] ??
                raw["pin_code"] ??
                raw["pin"] ??
                raw["zip"] ??
                raw["zipcode"] ??
                '')
            .toString()
            .trim();
    if (pin.isNotEmpty && !addressParts.contains(pin)) {
      addressParts.add(pin);
    }

    // 4. Country
    final String country =
        (drop?.country ??
                raw["country"] ??
                raw["countrycode"] ??
                raw["country_code"] ??
                '')
            .toString()
            .trim();
    if (country.isNotEmpty && !addressParts.contains(country)) {
      addressParts.add(country);
    }

    final String dropAddress = addressParts.isNotEmpty
        ? addressParts.join(', ')
        : (drop?.city != null && drop!.city!.trim().isNotEmpty
              ? "${drop!.city!.trim()}${drop?.zip != null && drop!.zip!.trim().isNotEmpty ? ', ${drop!.zip!.trim()}' : ''}"
              : 'Delivery Location');

    // Format payout: e.g. "₹ 165.00"
    String formattedPayout = '';
    if (payout != null && payout.toString().trim().isNotEmpty) {
      final pStr = payout.toString().trim();
      if (pStr.startsWith('₹') || pStr.startsWith('\$')) {
        formattedPayout = pStr;
      } else {
        final dVal = double.tryParse(pStr);
        if (dVal != null) {
          formattedPayout = '₹ ${dVal.toStringAsFixed(2)}';
        } else {
          formattedPayout = '₹ $pStr';
        }
      }
    } else if (amount != null && amount.toString().trim().isNotEmpty) {
      final dVal = double.tryParse(amount.toString());
      if (dVal != null) {
        formattedPayout = '₹ ${dVal.toStringAsFixed(2)}';
      } else {
        formattedPayout = '₹ $amount';
      }
    } else {
      formattedPayout = '₹ 0.00';
    }

    final String resolvedId = (ordernumber ?? orderkey ?? assignmentkey ?? '')
        .toString();

    return <String, dynamic>{
      'id': resolvedId.isNotEmpty
          ? (resolvedId.startsWith('#') ? resolvedId : '#$resolvedId')
          : '#001',
      'orderNumber': resolvedId,
      'orderkey': orderkey ?? '',
      'orderKey': orderkey ?? '',
      'assignmentkey': assignmentkey ?? '',
      'assignmentKey': assignmentkey ?? '',
      'restaurantName': storeName,
      'storeName': storeName,
      'distance': '-',
      'eta': '-',
      'payout': formattedPayout,
      'amount':
          double.tryParse(amount?.toString() ?? '') ??
          double.tryParse(payout?.toString() ?? '') ??
          0.0,
      'dropoff': dropAddress,
      'dropOffAddress': dropAddress,
      'address': dropAddress,
      'addressline': addr,
      'statecode': stateCode,
      'pincode': pin,
      'country': country,
      'customerName': customer != null && customer is Map
          ? customer['name']?.toString() ?? ''
          : '',
      'customerPhone': customer != null && customer is Map
          ? customer['phone']?.toString() ?? ''
          : '',
      'orderstatus': shipmentstatus ?? state ?? 'Pending',
      'status': state ?? shipmentstatus ?? 'Pending',
      'totalTax': Item.calculateTotalTax(raw["taxes"] ?? raw["tax"]),
      'taxes': raw["taxes"] ?? raw["tax"],
      'items': Item.parseOrderItems(raw["items"] ??
          raw["orderitems"] ??
          raw["order_items"] ??
          raw["products"] ??
          raw["orderlines"] ??
          raw["lines"]),
      'raw': raw,
    };
  }

  Map<String, dynamic> toJson() => {
    "assignmentkey": assignmentkey,
    "orderkey": orderkey,
    "ordernumber": ordernumber,
    "state": state,
    "assignedon": assignedon,
    "respondedon": respondedon,
    "store": store?.toJson(),
    "drop": drop?.toJson(),
    "customer": customer,
    "shipmentstatus": shipmentstatus,
    "slotstart": slotstart,
  };
}

class Store {
  final String? name;
  final String? addressline;
  final String? city;
  final String? pincode;
  final String? contactnumber;
  final double? latitude;
  final double? longitude;

  Store({
    this.name,
    this.addressline,
    this.city,
    this.pincode,
    this.contactnumber,
    this.latitude,
    this.longitude,
  });

  factory Store.fromJson(Map<String, dynamic> json) => Store(
    name: json["name"]?.toString(),
    addressline: json["addressline"]?.toString(),
    city: json["city"]?.toString(),
    pincode: json["pincode"]?.toString(),
    contactnumber: json["contactnumber"]?.toString(),
    latitude: double.tryParse(json["latitude"]?.toString() ?? ''),
    longitude: double.tryParse(json["longitude"]?.toString() ?? ''),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "addressline": addressline,
    "city": city,
    "pincode": pincode,
    "contactnumber": contactnumber,
    "latitude": latitude,
    "longitude": longitude,
  };
}

class Drop {
  final String? address;
  final String? addressline;
  final String? city;
  final String? state;
  final String? statecode;
  final String? pincode;
  final String? zip;
  final String? country;
  final Map<String, dynamic> raw;

  Drop({
    this.address,
    this.addressline,
    this.city,
    this.state,
    this.statecode,
    this.pincode,
    this.zip,
    this.country,
    this.raw = const {},
  });

  factory Drop.fromJson(Map<String, dynamic> json) => Drop(
    address:
        (json["address"] ??
                json["addressline"] ??
                json["addressline1"] ??
                json["street"])
            ?.toString(),
    addressline:
        (json["addressline"] ?? json["addressline1"] ?? json["address"])
            ?.toString(),
    city: json["city"]?.toString(),
    state: json["state"]?.toString(),
    statecode: (json["statecode"] ?? json["state_code"] ?? json["state"])
        ?.toString(),
    pincode:
        (json["pincode"] ??
                json["pin_code"] ??
                json["pin"] ??
                json["zip"] ??
                json["zipcode"])
            ?.toString(),
    zip: (json["zip"] ?? json["zipcode"] ?? json["pincode"] ?? json["pin"])
        ?.toString(),
    country: (json["country"] ?? json["countrycode"] ?? json["country_code"])
        ?.toString(),
    raw: json,
  );

  Map<String, dynamic> toJson() => {
    "address": address,
    "addressline": addressline,
    "city": city,
    "state": state,
    "statecode": statecode,
    "pincode": pincode,
    "zip": zip,
    "country": country,
  };
}
