// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  dynamic success;
  dynamic message;
  dynamic code;
  dynamic encrypted;
  dynamic data;

  LoginModel({
    required this.success,
    required this.message,
    required this.code,
    required this.encrypted,
    this.data,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    success: json["success"],
    message: json["message"],
    code: json["code"],
    encrypted: json["encrypted"],
    data: json["data"] != null && json["data"] is Map<String, dynamic>
        ? Data1.fromJson(json["data"])
        : json["data"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "code": code,
    "encrypted": encrypted,
    "data": data is Data1 ? (data as Data1).toJson() : data,
  };
}

class Data1 {
  dynamic channel;

  Data1({required this.channel});

  factory Data1.fromJson(Map<String, dynamic> json) =>
      Data1(channel: json["channel"]);

  Map<String, dynamic> toJson() => {"channel": channel};
}
