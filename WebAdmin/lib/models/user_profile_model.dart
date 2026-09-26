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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>?;
    final vehicle = details?['vehicle'] as Map<String, dynamic>?;
    final emergency = details?['emergencycontact'] as Map<String, dynamic>?;

    return UserProfileModel(
      userKey: json['contactkey']?.toString() ?? '-',
      name: json['name']?.toString() ?? '-',
      email: json['registeredemail']?.toString() ?? '-',
      mobile: json['registeredmobile']?.toString() ?? '-',
      role: json['rolename']?.toString() ?? '-',
      status: json['status']?.toString() ?? '-',
      createdOn: json['createdon']?.toString() ?? '-',
      gender: json['gender']?.toString() ?? '-',
      dob: json['dob']?.toString() ?? '-',
      type: json['contacttype']?.toString() ?? '-',
      country: json['isocountry']?.toString() ?? '-',
      language: json['languagecode']?.toString() ?? '-',
      vehicleNo:
          vehicle?['registrationnumber']?.toString() ??
          vehicle?['name']?.toString() ??
          '',
      portal: (json['portalstatus'] == 1 || json['portalstatus'] == '1')
          ? 'Active'
          : 'Inactive',
      emergencyContact: emergency?['phone']?.toString().split("+91")[1] ?? '-',
      emergencyContactName: emergency?['name']?.toString() ?? '-',
      whatsapp: json['whatsappnumber']?.toString() ?? '',
      docType: json['documenttype']?.toString() ?? '-',
      docNumber: json['documentnumber']?.toString() ?? '-',
      docExpiry: json['documentexpiry']?.toString() ?? '-',
      avatarUrl:
          (json['media'] != null &&
              json['media'].toString().trim().isNotEmpty &&
              json['media'].toString().trim() != 'null')
          ? json['media'].toString()
          : '',
    );
  }
}
