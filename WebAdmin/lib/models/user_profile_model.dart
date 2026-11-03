class UserProfileModel {
  final String userKey;
  final String name;
  final String email;
  final String mobile;
  final String role;
  final String status;
  final String createdOn;
  final String gender;
  final String dob;
  final String type;
  final String country;
  final String language;
  final String vehicleNo;
  final String portal;
  final String emergencyContact;
  final String emergencyContactName;
  final String whatsapp;
  final String docType;
  final String docNumber;
  final String docExpiry;
  final String avatarUrl;

  UserProfileModel({
    required this.userKey,
    required this.name,
    required this.email,
    required this.mobile,
    required this.role,
    required this.status,
    required this.createdOn,
    required this.gender,
    required this.dob,
    required this.type,
    required this.country,
    required this.language,
    required this.vehicleNo,
    required this.portal,
    required this.emergencyContact,
    required this.emergencyContactName,
    required this.whatsapp,
    required this.docType,
    required this.docNumber,
    required this.docExpiry,
    required this.avatarUrl,
  });

  static String _cleanVal(dynamic val) {
    if (val == null) return '-';
    final s = val.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return '-';
    return s;
  }

  static String _parseEmergencyPhone(dynamic val) {
    final cleaned = _cleanVal(val);
    if (cleaned == '-') return '-';
    if (cleaned.contains('+91')) {
      final parts = cleaned.split('+91');
      final after = parts.length > 1 ? parts[1].trim() : cleaned;
      return after.isNotEmpty ? after : '-';
    }
    return cleaned;
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final details = json['details'] is Map
        ? Map<String, dynamic>.from(json['details'])
        : null;
    final vehicle = details?['vehicle'] is Map
        ? Map<String, dynamic>.from(details!['vehicle'])
        : null;
    final emergency = details?['emergencycontact'] is Map
        ? Map<String, dynamic>.from(details!['emergencycontact'])
        : null;

    final rawVehicleNo =
        vehicle?['registrationnumber'] ?? vehicle?['name'];

    return UserProfileModel(
      userKey: _cleanVal(json['contactkey']),
      name: _cleanVal(json['name']),
      email: _cleanVal(json['registeredemail']),
      mobile: _cleanVal(json['registeredmobile']),
      role: _cleanVal(json['rolename']),
      status: _cleanVal(json['status']),
      createdOn: _cleanVal(json['createdon']),
      gender: _cleanVal(json['gender']),
      dob: _cleanVal(json['dob']),
      type: _cleanVal(json['contacttype']),
      country: _cleanVal(json['isocountry']),
      language: _cleanVal(json['languagecode']),
      vehicleNo: _cleanVal(rawVehicleNo),
      portal: json['portalstatus'] == null
          ? '-'
          : ((json['portalstatus'] == 1 || json['portalstatus'] == '1')
                ? 'Active'
                : 'Inactive'),
      emergencyContact: _parseEmergencyPhone(emergency?['phone']),
      emergencyContactName: _cleanVal(emergency?['name']),
      whatsapp: _cleanVal(json['whatsappnumber']),
      docType: _cleanVal(json['documenttype']),
      docNumber: _cleanVal(json['documentnumber']),
      docExpiry: _cleanVal(json['documentexpiry']),
      avatarUrl:
          (json['media'] != null &&
              json['media'].toString().trim().isNotEmpty &&
              json['media'].toString().trim() != 'null')
          ? json['media'].toString()
          : '',
    );
  }
}
