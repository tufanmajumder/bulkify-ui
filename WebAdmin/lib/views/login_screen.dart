import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:admin_app/controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = constraints.maxWidth < 420
                  ? constraints.maxWidth
                  : 390.0;

              return Container(
                width: cardWidth,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 36,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Obx(
                  () => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Brand Logo
                      _buildLogo(),
                      const SizedBox(height: 20),

                      if (!controller.isOtpSent.value)
                        _buildMobileOrEmailInputSection(controller)
                      else
                        _buildOtpVerificationSection(context, controller),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- Initial Mobile/Email Input Section ---
  Widget _buildMobileOrEmailInputSection(LoginController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Subtitle
        const Text(
          'Enter your mobile or email to login',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 20),

        // Mobile / Email Input Field
        TextField(
          controller: controller.inputController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (val) {
            if (controller.errorMessage.value.isNotEmpty) {
              controller.errorMessage.value = '';
            }
          },
          inputFormatters: [_SmartInputFormatter()],
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: 'Enter your email or mobile number',
            hintStyle: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF94A3B8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: Color(0xFFCF4340),
                width: 1.5,
              ),
            ),
          ),
        ),

        // Error Message Display
        Obx(() {
          if (controller.errorMessage.value.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 6, left: 2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                controller.errorMessage.value,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Send OTP Button
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.sendOtp(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD33E3B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                disabledBackgroundColor: const Color(0xFFE2E8F0),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Send OTP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // --- OTP Verification Section (Matching Attached Design) ---
  Widget _buildOtpVerificationSection(
    BuildContext context,
    LoginController controller,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Subtitle
        Text(
          controller.isMobileInput
              ? 'Type your 6 digit security code sent to your mobile'
              : 'Type your 6 digit security code sent to your email',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 24),

        // 6-Box OTP Input Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            return Container(
              width: 40,
              height: 46,
              margin: EdgeInsets.only(right: index < 5 ? 8 : 0),
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.backspace): () {
                    if (controller.otpControllers[index].text.isEmpty &&
                        index > 0) {
                      controller.otpFocusNodes[index - 1].requestFocus();
                      controller.otpControllers[index - 1].clear();
                    }
                  },
                },
                child: TextField(
                  controller: controller.otpControllers[index],
                  focusNode: controller.otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  maxLength: 1,
                  onTap: () {
                    controller.otpControllers[index].selection = TextSelection(
                      baseOffset: 0,
                      extentOffset:
                          controller.otpControllers[index].text.length,
                    );
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (val) {
                    if (val.length > 1) {
                      final digits = val.replaceAll(RegExp(r'\D'), '');
                      for (int i = 0; i < 6 && i < digits.length; i++) {
                        controller.otpControllers[i].text = digits[i];
                      }
                      if (digits.length >= 6) {
                        controller.otpFocusNodes[5].requestFocus();
                      } else {
                        controller.otpFocusNodes[digits.length].requestFocus();
                      }
                      return;
                    }
                    if (val.isNotEmpty && index < 5) {
                      controller.otpFocusNodes[index + 1].requestFocus();
                    } else if (val.isEmpty && index > 0) {
                      controller.otpFocusNodes[index - 1].requestFocus();
                    }
                  },
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFCF4340),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 24),

        // Verify Button
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.verifyOtpAndLogin(Get.context!),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD33E3B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                disabledBackgroundColor: const Color(0xFFE2E8F0),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Verify',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Resend Section
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Didn't get the code? ",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w400,
              ),
            ),
            Obx(
              () => InkWell(
                onTap: controller.isLoading.value
                    ? null
                    : () => controller.sendOtp(),
                child: Text(
                  'Resend',
                  style: TextStyle(
                    fontSize: 13,
                    color: controller.isLoading.value
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFFD33E3B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'bulkifyLogo.png',
      height: 40,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.storefront_rounded,
              color: Color(0xFFCF4340),
              size: 28,
            ),
            const SizedBox(width: 6),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                children: [
                  TextSpan(
                    text: 'B',
                    style: TextStyle(color: Color(0xFFCF4340)),
                  ),
                  TextSpan(
                    text: 'ulkify',
                    style: TextStyle(color: Color(0xFFCF4340)),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SmartInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final trimmed = newValue.text.trimLeft();
    if (trimmed.isEmpty) return newValue;

    // Check if input starts with a digit
    final firstChar = trimmed[0];
    if (RegExp(r'^[0-9]').hasMatch(firstChar)) {
      final cleaned = newValue.text.replaceAll(RegExp(r'\D'), '');
      if (cleaned.isEmpty) {
        return TextEditingValue.empty;
      }

      final firstDigit = cleaned[0];
      final isValidFirstDigit = ['6', '7', '8', '9'].contains(firstDigit);

      if (!isValidFirstDigit) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isSnackbarOpen != true) {
            Get.snackbar(
              'Invalid Mobile Number',
              'Mobile number must start with 6, 7, 8, or 9',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFDC2626),
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            );
          }
        });
        return oldValue.text.isEmpty ? TextEditingValue.empty : oldValue;
      }

      final truncated = cleaned.length > 10
          ? cleaned.substring(0, 10)
          : cleaned;
      return TextEditingValue(
        text: truncated,
        selection: TextSelection.collapsed(offset: truncated.length),
      );
    }

    // Email mode
    return newValue;
  }
}
