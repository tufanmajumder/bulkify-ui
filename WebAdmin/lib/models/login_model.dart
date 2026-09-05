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
  String? token;

  LoginModel({
    required this.success,
    required this.message,
    required this.code,
    required this.encrypted,
    this.data,
    this.token,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    String? tokenVal =
        json["sessionid"] ??
        json["session_id"] ??
        json["sessionId"] ??
        json["session"] ??
        json["token"] ??
        json["access_token"] ??
        json["accessToken"] ??
        json["bearer_token"] ??
        json["jwt"] ??
        json["auth_token"] ??
        json["authToken"];

    if (tokenVal == null && json["data"] != null) {
      if (json["data"] is Map<String, dynamic>) {
        tokenVal =
            json["data"]["sessionid"] ??
            json["data"]["session_id"] ??
            json["data"]["sessionId"] ??
            json["data"]["session"] ??
            json["data"]["token"] ??
            json["data"]["access_token"] ??
            json["data"]["accessToken"] ??
            json["data"]["bearer_token"] ??
            json["data"]["jwt"] ??
            json["data"]["auth_token"] ??
            json["data"]["authToken"];
      } else if (json["data"] is String) {
        tokenVal = json["data"];
      }
    }

    final parsedData = json["data"] != null && json["data"] is Map<String, dynamic>
        ? Data1.fromJson(json["data"])
        : json["data"];

    if ((tokenVal == null || tokenVal.isEmpty) && parsedData is Data1) {
      tokenVal = parsedData.sessionId;
    }

    return LoginModel(
      success:
          json["success"] ??
          json["status"] ??
          json["is_success"] ??
          json["isSuccess"],
      message:
          json["message"] ??
          json["msg"] ??
          json["error"] ??
          json["status_message"],
      code:
          json["code"] ??
          json["status_code"] ??
          json["statusCode"] ??
          json["status"],
      encrypted: json["encrypted"],
      data: parsedData,
      token: tokenVal?.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "code": code,
    "encrypted": encrypted,
    "data": data is Data1 ? (data as Data1).toJson() : data,
    "token": token,
  };
}

class Data1 {
  dynamic channel;
  String? sessionId;
  dynamic expiresIn;

  Data1({this.channel, this.sessionId, this.expiresIn});

  factory Data1.fromJson(Map<String, dynamic> json) => Data1(
    channel: json["channel"],
    sessionId:
        json["sessionId"] ??
        json["sessionid"] ??
        json["session_id"] ??
        json["token"] ??
        json["access_token"],
    expiresIn: json["expiresin"] ?? json["expires_in"] ?? json["expiresIn"],
  );

  Map<String, dynamic> toJson() => {
    "channel": channel,
    "sessionId": sessionId,
    "expiresin": expiresIn,
  };
}
