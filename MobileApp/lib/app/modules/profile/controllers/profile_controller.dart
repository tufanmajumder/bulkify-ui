import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bulkify/app/data/models/auth_models/profile/profileModel.dart';
import 'package:bulkify/app/data/service/auth_service.dart';
import 'package:bulkify/app/data/utils/color_manager.dart';
import 'package:bulkify/app/data/utils/string_manager.dart';
import 'package:bulkify/app/data/utils/widget_manager.dart';
import 'package:bulkify/app/routes/app_pages.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();

  // API State & Profile ViewModel
  final RxBool isLoading = false.obs;
  final Rxn<ProfileViewModel> profileViewModel = Rxn<ProfileViewModel>();

  // Driver Information
  final RxString driverName = "...".obs;
  final RxString partnerId = "".obs;

  // Vehicle Details
  final RxString vehicleType = '...'.obs;
  final RxString vehicleName = '...'.obs;
  final RxString registrationNumber = '...'.obs;

  // Emergency Contact Details
  final RxString emergencyName = '...'.obs;
  final RxString emergencyRelation = '...'.obs;
  final RxString emergencyPhone = '...'.obs;

  // Payment Details
  final RxString upiId = '...'.obs;

  // Profile Picture State
  final RxInt selectedColorIndex = 0.obs;
  final Rx<Color> selectedColor = ColorManager.avatarCoralRed.obs;
  final RxnString profileImagePath = RxnString();

  final ImagePicker _picker = ImagePicker();

  final List<Color> avatarColors = ColorManager.avatarColors;

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  /// Fetch profile data from getConnect API using user sessionId bearer token
  Future<void> fetchProfileData({bool forceRefresh = false}) async {
    // Only call profile API once if data is already loaded
    if (!forceRefresh && profileViewModel.value != null) {
      return;
    }

    isLoading.value = true;
    try {
      print("Fetching profile data from API...");
      final ProfileViewModel? model = await _authService.getConnect();
      if (model != null) {
        profileViewModel.value = model;
        _updateProfileFields(model);
        print("Profile data successfully loaded.");
      } else {
        print("ProfileViewModel returned null from _authService.getConnect()");
      }
    } catch (e, stackTrace) {
      print("Error fetching profile data: $e");
      print("StackTrace: $stackTrace");
    } finally {
      isLoading.value = false;
    }
  }

  void _updateProfileFields(ProfileViewModel model) {
    final dynamic rootData = model.data;
    if (rootData == null) return;

    final Data? dataObj = rootData is Data
        ? rootData
        : (rootData is Map<String, dynamic>
            ? Data.fromJson(rootData)
            : null);

    if (dataObj == null) return;

    // 1. Profile (Name)
    final Profile? p = dataObj.profile;
    if (p != null) {
      final String first = p.contactname?.toString().trim() ?? '';
      final String last = p.surname?.toString().trim() ?? '';
      if (first.isNotEmpty && last.isNotEmpty) {
        driverName.value = "$first $last";
      } else if (first.isNotEmpty) {
        driverName.value = first;
      } else if (last.isNotEmpty) {
        driverName.value = last;
      }
    }

    // 2. Details (Partner ID, Vehicle, Emergency Contact, UPI ID)
    final Details? d = dataObj.details;
    if (d != null) {
      // Partner ID
      if (d.displayid != null && d.displayid.toString().trim().isNotEmpty) {
        partnerId.value = d.displayid.toString().trim();
      }

      // Vehicle
      final Vehicle? v = d.vehicle;
      if (v != null) {
        if (v.type != null && v.type.toString().trim().isNotEmpty) {
          vehicleType.value = v.type.toString().trim();
        }
        if (v.name != null && v.name.toString().trim().isNotEmpty) {
          vehicleName.value = v.name.toString().trim();
        }
        if (v.registrationnumber != null &&
            v.registrationnumber.toString().trim().isNotEmpty) {
          registrationNumber.value = v.registrationnumber.toString().trim();
        }
      }

      // Emergency Contact
      final Emergencycontact? e = d.emergencycontact;
      if (e != null) {
        if (e.name != null && e.name.toString().trim().isNotEmpty) {
          emergencyName.value = e.name.toString().trim();
        }
        if (e.relation != null && e.relation.toString().trim().isNotEmpty) {
          emergencyRelation.value = e.relation.toString().trim();
        }
        if (e.phone != null && e.phone.toString().trim().isNotEmpty) {
          emergencyPhone.value = e.phone.toString().trim();
        }
      }

      // UPI ID
      if (d.upiid != null) {
        final upiVal = d.upiid;
        if (upiVal is Map && upiVal['upiid'] != null) {
          upiId.value = upiVal['upiid'].toString().trim();
        } else if (upiVal.toString().trim().isNotEmpty) {
          upiId.value = upiVal.toString().trim();
        }
      }
    }
  }

  void selectColor(int index) {
    selectedColorIndex.value = index;
    selectedColor.value = avatarColors[index];
    profileImagePath.value = null; // Clear image if color preset is selected
  }

  /// Pick an image from Gallery for iOS and Android
  // Future<void> pickImage([ImageSource source = ImageSource.gallery]) async {
  //   try {
  //     final XFile? pickedFile = await _picker.pickImage(
  //       source: source,
  //       maxWidth: 600,
  //       maxHeight: 600,
  //       imageQuality: 85,
  //     );
  //     if (pickedFile != null) {
  //       profileImagePath.value = pickedFile.path;
  //       selectedColorIndex.value =
  //           -1; // Clear color index highlight when custom photo is active
  //     }
  //   } catch (e) {
  //     WidgetManager.showSnackBar(
  //       message: '${StringManager.failedToPickImage} $e',
  //     );
  //   }
  // }

  /// Logout Action
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessionId');
    Get.offAllNamed(Routes.LOGIN);
  }
}
