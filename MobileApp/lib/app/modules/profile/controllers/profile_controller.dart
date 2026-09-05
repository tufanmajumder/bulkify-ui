import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/auth_models/profile/profileModel.dart';
import '../../../data/service/auth_service.dart';
import '../../../data/utils/color_manager.dart';
import '../../../data/utils/string_manager.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();

  // API State & Profile ViewModel
  final RxBool isLoading = false.obs;
  final Rxn<ProfileViewModel> profileViewModel = Rxn<ProfileViewModel>();

  // Driver Information
  final RxString driverName = StringManager.defaultDriverName.obs;
  final RxString role = StringManager.defaultRole.obs;
  final RxString partnerId = StringManager.defaultPartnerId.obs;

  // Vehicle Details
  final RxString vehicleType = 'Motorbike'.obs;
  final RxString vehicleName = 'Honda Activa 6G'.obs;
  final RxString registrationNumber = 'KA 05 AB 4821'.obs;

  // Emergency Contact Details
  final RxString emergencyName = 'Priya Doe'.obs;
  final RxString emergencyRelation = 'Spouse'.obs;
  final RxString emergencyPhone = '+91 98765 11223'.obs;

  // Payment Details
  final RxString upiId = 'johndoe@okhdfc'.obs;

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
  Future<void> fetchProfileData() async {
    isLoading.value = true;
    try {
      final ProfileViewModel? model = await _authService.getConnect();
      if (model != null) {
        profileViewModel.value = model;
        _updateProfileFields(model);
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _updateProfileFields(ProfileViewModel model) {
    final data = model.data;
    if (data == null) return;

    if (data.profile != null) {
      final p = data.profile!;
      if (p.name != null && p.name.toString().isNotEmpty) {
        driverName.value = p.name.toString();
      }
      if (p.deliveryPartnerId != null &&
          p.deliveryPartnerId.toString().isNotEmpty) {
        partnerId.value = p.deliveryPartnerId.toString();
      }
    }

    if (data.vehicle != null) {
      final v = data.vehicle!;
      if (v.vehicleType != null && v.vehicleType.toString().isNotEmpty) {
        vehicleType.value = v.vehicleType.toString();
      }
      if (v.vehicleName != null && v.vehicleName.toString().isNotEmpty) {
        vehicleName.value = v.vehicleName.toString();
      }
      if (v.registrationNumber != null &&
          v.registrationNumber.toString().isNotEmpty) {
        registrationNumber.value = v.registrationNumber.toString();
      }
    }

    if (data.emergencyContact != null) {
      final e = data.emergencyContact!;
      if (e.name != null && e.name.toString().isNotEmpty) {
        emergencyName.value = e.name.toString();
      }
      if (e.relation != null && e.relation.toString().isNotEmpty) {
        emergencyRelation.value = e.relation.toString();
      }
      if (e.phoneNumber != null && e.phoneNumber.toString().isNotEmpty) {
        emergencyPhone.value = e.phoneNumber.toString();
      }
    }

    if (data.upi != null) {
      final u = data.upi!;
      if (u.upiId != null && u.upiId.toString().isNotEmpty) {
        upiId.value = u.upiId.toString();
      }
    }
  }

  void selectColor(int index) {
    selectedColorIndex.value = index;
    selectedColor.value = avatarColors[index];
    profileImagePath.value = null; // Clear image if color preset is selected
  }

  /// Pick an image from Gallery for iOS and Android
  Future<void> pickImage([ImageSource source = ImageSource.gallery]) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        profileImagePath.value = pickedFile.path;
        selectedColorIndex.value =
            -1; // Clear color index highlight when custom photo is active
      }
    } catch (e) {
      Get.snackbar(
        StringManager.error,
        '${StringManager.failedToPickImage} $e',
      );
    }
  }

  /// Logout Action
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessionId');
    Get.offAllNamed(Routes.LOGIN);
  }
}
