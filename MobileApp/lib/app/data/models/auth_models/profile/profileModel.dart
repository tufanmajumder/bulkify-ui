import 'dart:convert';

ProfileViewModel profileViewModelFromJson(String str) =>
    ProfileViewModel.fromJson(json.decode(str));

String profileViewModelToJson(ProfileViewModel data) =>
    json.encode(data.toJson());

class ProfileViewModel {
  dynamic success;
  dynamic message;
  dynamic code;
  dynamic encrypted;
  dynamic data;

  ProfileViewModel({
    required this.success,
    required this.message,
    required this.code,
    required this.encrypted,
    required this.data,
  });

  factory ProfileViewModel.fromJson(Map<String, dynamic> json) =>
      ProfileViewModel(
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
  dynamic profile;
  dynamic details;

  Data({required this.profile, required this.details});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    profile: json["profile"] == null
        ? null
        : (json["profile"] is Map<String, dynamic>
            ? Profile.fromJson(json["profile"])
            : json["profile"]),
    details: json["details"] == null
        ? null
        : (json["details"] is Map<String, dynamic>
            ? Details.fromJson(json["details"])
            : json["details"]),
  );

  Map<String, dynamic> toJson() => {
    "profile": profile is Profile ? (profile as Profile).toJson() : profile,
    "details": details is Details ? (details as Details).toJson() : details,
  };
}

class Details {
  dynamic displayid;
  dynamic vehicle;
  dynamic emergencycontact;
  dynamic upiid;

  Details({
    required this.displayid,
    required this.vehicle,
    required this.emergencycontact,
    required this.upiid,
  });

  factory Details.fromJson(Map<String, dynamic> json) => Details(
    displayid: json["displayid"],
    vehicle: Vehicle.fromJson(json["vehicle"]),
    emergencycontact: Emergencycontact.fromJson(json["emergencycontact"]),
    upiid: json["upiid"],
  );

  Map<String, dynamic> toJson() => {
    "displayid": displayid,
    "vehicle": vehicle.toJson(),
    "emergencycontact": emergencycontact.toJson(),
    "upiid": upiid,
  };
}

class Emergencycontact {
  dynamic name;
  dynamic relation;
  dynamic phone;

  Emergencycontact({
    required this.name,
    required this.relation,
    required this.phone,
  });

  factory Emergencycontact.fromJson(Map<String, dynamic> json) =>
      Emergencycontact(
        name: json["name"],
        relation: json["relation"],
        phone: json["phone"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "relation": relation,
    "phone": phone,
  };
}

class Vehicle {
  dynamic type;
  dynamic name;
  dynamic registrationnumber;

  Vehicle({
    required this.type,
    required this.name,
    required this.registrationnumber,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    type: json["type"],
    name: json["name"],
    registrationnumber: json["registrationnumber"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "name": name,
    "registrationnumber": registrationnumber,
  };
}

class Profile {
  dynamic contactname;
  dynamic surname;
  dynamic registeredmobile;
  dynamic registeredemail;

  Profile({
    required this.contactname,
    required this.surname,
    required this.registeredmobile,
    required this.registeredemail,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    contactname: json["contactname"],
    surname: json["surname"],
    registeredmobile: json["registeredmobile"],
    registeredemail: json["registeredemail"],
  );

  Map<String, dynamic> toJson() => {
    "contactname": contactname,
    "surname": surname,
    "registeredmobile": registeredmobile,
    "registeredemail": registeredemail,
  };
}
