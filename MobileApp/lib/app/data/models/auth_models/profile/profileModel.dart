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
    this.success,
    this.message,
    this.code,
    this.encrypted,
    this.data,
  });

  factory ProfileViewModel.fromJson(Map<String, dynamic> json) =>
      ProfileViewModel(
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
  dynamic profile;
  dynamic vehicle;
  dynamic emergencyContact;
  dynamic upi;

  Data({this.profile, this.vehicle, this.emergencyContact, this.upi});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    profile: json["profile"] != null && json["profile"] is Map<String, dynamic>
        ? Profile.fromJson(json["profile"])
        : null,
    vehicle: json["vehicle"] != null && json["vehicle"] is Map<String, dynamic>
        ? Vehicle.fromJson(json["vehicle"])
        : null,
    emergencyContact:
        json["emergencycontact"] != null &&
            json["emergencycontact"] is Map<String, dynamic>
        ? EmergencyContact.fromJson(json["emergencycontact"])
        : null,
    upi: json["upi"] != null && json["upi"] is Map<String, dynamic>
        ? Upi.fromJson(json["upi"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "profile": profile?.toJson(),
    "vehicle": vehicle?.toJson(),
    "emergencycontact": emergencyContact?.toJson(),
    "upi": upi?.toJson(),
  };
}

class EmergencyContact {
  dynamic name;
  dynamic relation;
  dynamic phoneNumber;

  EmergencyContact({this.name, this.relation, this.phoneNumber});

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        name: json["name"],
        relation: json["relation"],
        phoneNumber: json["phonenumber"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "relation": relation,
    "phonenumber": phoneNumber,
  };
}

class Profile {
  dynamic name;
  dynamic deliveryPartnerId;

  Profile({this.name, this.deliveryPartnerId});

  factory Profile.fromJson(Map<String, dynamic> json) =>
      Profile(name: json["name"], deliveryPartnerId: json["deliverypartnerid"]);

  Map<String, dynamic> toJson() => {
    "name": name,
    "deliverypartnerid": deliveryPartnerId,
  };
}

class Upi {
  dynamic upiId;

  Upi({this.upiId});

  factory Upi.fromJson(Map<String, dynamic> json) => Upi(upiId: json["upiid"]);

  Map<String, dynamic> toJson() => {"upiid": upiId};
}

class Vehicle {
  dynamic vehicleType;
  dynamic vehicleName;
  dynamic registrationNumber;

  Vehicle({this.vehicleType, this.vehicleName, this.registrationNumber});

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    vehicleType: json["vehicletype"],
    vehicleName: json["vehiclename"],
    registrationNumber: json["registrationnumber"],
  );

  Map<String, dynamic> toJson() => {
    "vehicletype": vehicleType,
    "vehiclename": vehicleName,
    "registrationnumber": registrationNumber,
  };
}
