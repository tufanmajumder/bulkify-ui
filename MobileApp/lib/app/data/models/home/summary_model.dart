// To parse this JSON data, do
//
//     final summaryModel = summaryModelFromJson(jsonString);

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
    required this.success,
    required this.message,
    required this.code,
    required this.encrypted,
    required this.data,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) => SummaryModel(
    success: json["success"],
    message: json["message"],
    code: json["code"],
    encrypted: json["encrypted"],
    data: json["data"] == null
        ? null
        : (json["data"] is Map<String, dynamic>
            ? Data.fromJson(json["data"])
            : json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "code": code,
    "encrypted": encrypted,
    "data": data is Data ? (data as Data).toJson() : data,
  };
}

class Data {
  dynamic onlinestatus;
  dynamic summary;

  Data({required this.onlinestatus, required this.summary});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    onlinestatus: json["onlinestatus"],
    summary: json["summary"] == null
        ? null
        : (json["summary"] is Map<String, dynamic>
            ? Summary.fromJson(json["summary"])
            : json["summary"]),
  );

  Map<String, dynamic> toJson() => {
    "onlinestatus": onlinestatus,
    "summary": summary is Summary ? (summary as Summary).toJson() : summary,
  };
}

class Summary {
  dynamic earnings;
  dynamic completedorders;
  dynamic onlinetimeseconds;
  dynamic distance;

  Summary({
    required this.earnings,
    required this.completedorders,
    required this.onlinetimeseconds,
    required this.distance,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    earnings: json["earnings"],
    completedorders: json["completedorders"],
    onlinetimeseconds: json["onlinetimeseconds"],
    distance: json["distance"],
  );

  Map<String, dynamic> toJson() => {
    "earnings": earnings,
    "completedorders": completedorders,
    "onlinetimeseconds": onlinetimeseconds,
    "distance": distance,
  };
}
