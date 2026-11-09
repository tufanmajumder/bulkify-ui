import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/responsive.dart';
import '../home/home_screen.dart';

class WelcomeLandingScreen extends ConsumerStatefulWidget {
  const WelcomeLandingScreen({super.key});

  @override
  ConsumerState<WelcomeLandingScreen> createState() =>
      _WelcomeLandingScreenState();
}

class _WelcomeLandingScreenState extends ConsumerState<WelcomeLandingScreen> {
  String _selectedLocation = '700091 · Salt Lake';

  void _showLocationPicker() {
    final isTablet = Responsive.isTablet(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final locations = [
          '700091 · Salt Lake, Kolkata',
          '700020 · Park Street, Kolkata',
          '700156 · New Town, Kolkata',
          '560102 · HSR Layout, Bengaluru',
          '45 Roker Terrace, London',
        ];

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 480 : double.infinity,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle for iOS & Android
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Text(
                          'Select Delivery Location',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Divider(),
                      for (final loc in locations)
                        ListTile(
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            loc,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13.5,
                            ),
                          ),
                          trailing: _selectedLocation == loc
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedLocation = loc.contains('·')
                                  ? loc.split(',')[0]
                                  : loc;
                            });
                            Navigator.pop(ctx);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(location: _selectedLocation),
      ),
    );
  }

  void _showLoginSheet() {
    _navigateToHome();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;
    final isSmallPhone = context.isSmallPhone;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF7A0C08),
        body: Stack(
          children: [
            // Deep Red Gradient Background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF8B120C),
                      Color(0xFF6B0E09),
                      Color(0xFF4A0805),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Decorative Translucent Circles (Fluid positioning)
            Positioned(
              top: -40,
              right: -60,
              child: Container(
                width: isTablet ? 320 : 220,
                height: isTablet ? 320 : 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              top: context.screenHeight * 0.18,
              left: -50,
              child: Container(
                width: isTablet ? 260 : 180,
                height: isTablet ? 260 : 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.035),
                ),
              ),
            ),
            Positioned(
              top: context.screenHeight * 0.36,
              right: 20,
              child: Container(
                width: isTablet ? 200 : 140,
                height: isTablet ? 200 : 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),

            // Main Responsive Content
            SafeArea(
              child: isLandscape && (isTablet || context.screenWidth > 700)
                  ? _buildWideTabletLayout(context)
                  : _buildStandardPortraitLayout(
                      context,
                      isTablet,
                      isSmallPhone,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Responsive layout for standard phones and portrait tablets
  Widget _buildStandardPortraitLayout(
    BuildContext context,
    bool isTablet,
    bool isSmallPhone,
  ) {
    return Column(
      children: [
        // Top Hero Section (scroll-safe on very small screens, flex-spaced on normal screens)
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 560 : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Bulkify Logo
                    Image.asset(
                      'assets/appLogo.png',
                      height: isTablet ? 64 : (isSmallPhone ? 42 : 52),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Text(
                        'Bulkify',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: isTablet ? 42 : 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: isSmallPhone ? 20 : (isTablet ? 48 : 36)),

                    // Main Headline
                    Text(
                      'Kitchen supplies\nat today\'s\nmandi rates',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: isTablet ? 38 : (isSmallPhone ? 24 : 30),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.25,
                        letterSpacing: -0.5,
                      ),
                    ),

                    SizedBox(height: isSmallPhone ? 10 : 16),

                    // Subtitle
                    Text(
                      'Fresh produce, dairy and staples in bulk.\nRates updated every morning.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: isTablet ? 16 : (isSmallPhone ? 12 : 13.5),
                        color: Colors.white.withOpacity(0.85),
                        height: 1.45,
                      ),
                    ),

                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Bottom White Card
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 540 : double.infinity,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                isTablet ? 28 : 20,
                isTablet ? 28 : 24,
                isTablet ? 28 : 20,
                isTablet ? 28 : 24,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: isTablet
                    ? const BorderRadius.vertical(top: Radius.circular(32))
                    : const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: _buildActionControls(context, isTablet),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Two-column split layout for Tablets & iPads in Landscape mode
  Widget _buildWideTabletLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Panel: Hero Branding & Mandi value prop
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(right: 36),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/appLogo.png',
                        height: 60,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Text(
                          'Bulkify',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Kitchen supplies\nat today\'s\nmandi rates',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Fresh produce, dairy and staples in bulk.\nRates updated every morning across wholesale mandis.',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15.5,
                          color: Colors.white.withOpacity(0.88),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Right Panel: Elevated Action Card
              Expanded(
                flex: 5,
                child: Card(
                  elevation: 16,
                  shadowColor: Colors.black45,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: _buildActionControls(context, true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable action controls (Location pill, Browse rates, Login button, footer)
  Widget _buildActionControls(BuildContext context, bool isTablet) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Deliver To Location Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDEEEB),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF8D7DA),
                    width: 0.8,
                  ),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF8F0F0A),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deliver to',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        color: Color(0xFF6C757D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _selectedLocation,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF212529),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _showLocationPicker,
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Change',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8F0F0A),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Primary Button: "Browse rates"
        SizedBox(
          width: double.infinity,
          height: isTablet ? 54 : 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8F0F0A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _navigateToHome,
            child: Text(
              'Browse rates',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: isTablet ? 16 : 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary Button: "Login with mobile number"
        SizedBox(
          width: double.infinity,
          height: isTablet ? 54 : 50,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF8F0F0A),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF8F0F0A), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _showLoginSheet,
            child: Text(
              'Login with mobile number',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: isTablet ? 15.5 : 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Footer note
        const Text(
          'Business details are asked after your first order',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            color: Color(0xFF8E959E),
          ),
        ),
      ],
    );
  }
}
