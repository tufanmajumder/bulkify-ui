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

  factory RejectedModel.fromJson(Map<String, dynamic> json) => RejectedModel(
    success: json["success"],
    message: json["message"],
    code: json["code"],
    encrypted: json["encrypted"],
    data: json["data"] != null && json["data"] is Map<String, dynamic>
        ? Data.fromJson(json["data"])
        : null,
  );

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

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    items: json["items"] != null && json["items"] is List
        ? List<Item>.from((json["items"] as List).map((x) => Item.fromJson(x)))
        : [],
    page: json["page"],
    pageSize: json["pagesize"],
    totalCount: json["totalcount"],
    totalPages: json["totalpages"],
  );

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
  dynamic restaurantName;
  dynamic deliveryAddress;
  dynamic amount;
  dynamic orderstatus;
  dynamic status;
  dynamic deliveryMethod;

  Item({
    this.orderNumber,
    this.restaurantName,
    this.deliveryAddress,
    this.amount,
    this.orderstatus,
    this.status,
    this.deliveryMethod,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    orderNumber: json["ordernumber"],
    restaurantName: json["restaurantname"],
    deliveryAddress: json["deliveryaddress"],
    amount: json["amount"],
    orderstatus: json["orderstatus"],
    status: json["status"],
    deliveryMethod: json["deliverymethod"] ?? json["delivermethod"],
  );

  Map<String, dynamic> toJson() => {
    "ordernumber": orderNumber,
    "restaurantname": restaurantName,
    "deliveryaddress": deliveryAddress,
    "amount": amount,
    "orderstatus": orderstatus,
    "status": status,
    "deliverymethod": deliveryMethod,
  };
}
