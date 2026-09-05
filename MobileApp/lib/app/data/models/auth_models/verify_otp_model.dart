// To parse this JSON data, do
//
//     final verifyOtpModel = verifyOtpModelFromJson(jsonString);

import 'dart:convert';

VerifyOtpModel verifyOtpModelFromJson(String str) =>
    VerifyOtpModel.fromJson(json.decode(str));

String verifyOtpModelToJson(VerifyOtpModel data) => json.encode(data.toJson());

class VerifyOtpModel {
  dynamic success;
  dynamic message;
  dynamic code;
  dynamic encrypted;
  Data1? data;

  VerifyOtpModel({
    this.success,
    this.message,
    this.code,
    this.encrypted,
    this.data,
  });

  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) => VerifyOtpModel(
    success: json["success"],
    message: json["message"],
    code: json["code"],
    encrypted: json["encrypted"],
    data: json["data"] is Map<String, dynamic>
        ? Data1.fromJson(json["data"])
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

class Data1 {
  dynamic sessionId;
  dynamic expiresin;

  Data1({required this.sessionId, required this.expiresin});

  factory Data1.fromJson(Map<String, dynamic> json) =>
      Data1(sessionId: json["sessionId"], expiresin: json["expiresin"]);

  Map<String, dynamic> toJson() => {
    "sessionId": sessionId,
    "expiresin": expiresin,
  };
}
