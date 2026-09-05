import 'dart:convert';

SummaryModel summaryModelFromJson(String str) =>
    SummaryModel.fromJson(json.decode(str));

String summaryModelToJson(SummaryModel data) => json.encode(data.toJson());

class SummaryModel {
  dynamic success;
  dynamic message;
  dynamic code;
  dynamic encrypted;
  dynamic data;

  SummaryModel({
    this.success,
    this.message,
    this.code,
    this.encrypted,
    this.data,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) => SummaryModel(
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
  dynamic earnings;
  dynamic completedorders;
  dynamic onlinetimeminutes;
  dynamic distancecoveredkm;

  Data({
    this.earnings,
    this.completedorders,
    this.onlinetimeminutes,
    this.distancecoveredkm,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    earnings:
        json["earnings"] != null && json["earnings"] is Map<String, dynamic>
        ? Earnings.fromJson(json["earnings"])
        : null,
    completedorders: json["completedorders"],
    onlinetimeminutes: json["onlinetimeminutes"],
    distancecoveredkm: json["distancecoveredkm"],
  );

  Map<String, dynamic> toJson() => {
    "earnings": earnings?.toJson(),
    "completedorders": completedorders,
    "onlinetimeminutes": onlinetimeminutes,
    "distancecoveredkm": distancecoveredkm,
  };
}

class Earnings {
  dynamic amount;
  dynamic currency;
  dynamic symbol;

  Earnings({this.amount, this.currency, this.symbol});

  factory Earnings.fromJson(Map<String, dynamic> json) => Earnings(
    amount: json["amount"],
    currency: json["currency"],
    symbol: json["symbol"],
  );

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "currency": currency,
    "symbol": symbol,
  };
}
