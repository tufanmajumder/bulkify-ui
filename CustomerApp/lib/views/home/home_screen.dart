import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/asset_manager.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/home_provider.dart';
import '../welcome/welcome_landing_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String location;

  const HomeScreen({super.key, this.location = 'Salt Lake - Tomorrow 6-8 AM'});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final PageController _promoController;

  @override
  void initState() {
    super.initState();
    _promoController = PageController();

    // Sync initial location to riverpod state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          widget.location.isNotEmpty &&
          !widget.location.contains('Tomorrow')) {
        ref.read(deliverySlotProvider.notifier).state =
            '${widget.location} - Tomorrow 6-8 AM';
      }
    });
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _showLocationPicker(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final locations = [
      'Salt Lake - Tomorrow 6-8 AM',
      'Park Street - Tomorrow 6-8 AM',
      'New Town - Tomorrow 7-9 AM',
      'HSR Layout - Tomorrow 6-8 AM',
      'Indiranagar - Tomorrow 7-9 AM',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
                          'Choose Delivery Slot',
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: ref.watch(deliverySlotProvider) == loc
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () {
                            ref.read(deliverySlotProvider.notifier).state = loc;
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

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final isTablet = context.isTablet;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Active Tab Content
              Positioned.fill(child: _buildActiveTab(currentIndex)),

              // Floating Cart Pill (Shown only on Home Tab)
              if (currentIndex == 0)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 600 : double.infinity,
                      ),
                      child: _buildFloatingCartPill(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildActiveTab(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return _buildHomeFeed(context);
      case 1:
        return _buildPlaceholderTab(
          'Browse Categories',
          Icons.grid_view_rounded,
        );
      case 2:
        return _buildPlaceholderTab('Reorder Items', Icons.sync_rounded);
      case 3:
        return _buildPlaceholderTab('Your Orders', Icons.receipt_long_outlined);
      case 4:
        return _buildAccountTab(context);
      default:
        return _buildHomeFeed(context);
    }
  }

  // ==========================================================================
  // HOME FEED CONTENT
  // ==========================================================================
  Widget _buildHomeFeed(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment(0, -0.45),
          colors: [Color(0xFFFFF1EF), Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 76),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? (isLandscape ? 960 : 720) : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Top App Bar (Red Bulkify Logo + Notification Bell)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: _buildAppBar(context),
                ),

                // 2. Delivery Slot Picker Pill
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: _buildDeliverySlotBar(context),
                ),

                // 3. Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: _buildSearchBar(context),
                ),

                // 4. Fruits & Vegetable Store Banner
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: _buildFruitsVegStoreBanner(context),
                ),

                // 5. Promotional Carousel Card
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: _buildPromoCarousel(context),
                ),

                // 6. Order Tracking Strip
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  child: _buildOrderTrackerStrip(context),
                ),

                // 7. Complete Account Setup Banner
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  child: _buildAccountSetupBanner(context),
                ),

                const SizedBox(height: 12),

                // 8. Categories Grid Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildCategoriesSection(context),
                ),

                const SizedBox(height: 18),

                // 9. Cashback Promo Navy Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildCashbackPromoBanner(context),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // 1. TOP APP BAR (Logo + Notification Bell)
  // ==========================================================================
  Widget _buildAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Bulkify Brand Logo (Tinted with brand red)
        Image.asset(
          AppAssets.appLogo,
          height: 36,
          color: const Color(0xFFCD463E),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.spa_rounded, color: Color(0xFFCD463E), size: 24),
              SizedBox(width: 6),
              Text(
                'Bulkify',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFCD463E),
                ),
              ),
            ],
          ),
        ),

        // Notification Bell Icon with soft rounded border and red dot
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF334155),
                  size: 21,
                ),
                padding: EdgeInsets.zero,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No new notifications'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              Positioned(
                top: 7,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCD463E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // 2. DELIVERY SLOT BAR (Location + Tomorrow 6-8 AM)
  // ==========================================================================
  Widget _buildDeliverySlotBar(BuildContext context) {
    final slot = ref.watch(deliverySlotProvider);
    // Format to "Salt Lake - Tomorrow 6-8 AM" if it starts with pincode
    final displaySlot = slot.replaceAll(RegExp(r'^\d+\s*·\s*'), '');

    return InkWell(
      onTap: () => _showLocationPicker(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Row(
          children: [
            // Location Pin Icon inside soft pink circle badge
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFFFDEEEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFFCD463E),
                size: 15,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displaySlot,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF64748B),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 3. SEARCH BAR (With Mic & Camera Icons)
  // ==========================================================================
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (val) =>
                  ref.read(searchQueryProvider.notifier).state = val,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13.5,
                color: Color(0xFF1E293B),
              ),
              decoration: const InputDecoration(
                hintText: "Search 'Onion 25 kg'",
                hintStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13.5,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const Icon(
            Icons.mic_none_rounded,
            color: Color(0xFF64748B),
            size: 20,
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.camera_alt_outlined,
            color: Color(0xFF64748B),
            size: 20,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 4. FRUITS & VEGETABLE STORE BANNER
  // ==========================================================================
  Widget _buildFruitsVegStoreBanner(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14532D), Color(0xFF15803D), Color(0xFF166534)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF166534).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Left Decorative Harvest Graphics
          Positioned(
            left: 8,
            top: 8,
            bottom: 8,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🍎', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 4),
                const Text('🥦', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),

          // Center Branding
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Fruits & Vegetable',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFACC15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'STORE',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right Decorative Harvest Graphics
          Positioned(
            right: 8,
            top: 8,
            bottom: 8,
            child: Row(
              children: [
                const Text('🥕', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🍇', style: TextStyle(fontSize: 22)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 5. PROMOTIONAL CAROUSEL CARD ("Create without limits")
  // ==========================================================================
  Widget _buildPromoCarousel(BuildContext context) {
    final activeIndex = ref.watch(activePromoIndexProvider);

    return Column(
      children: [
        SizedBox(
          height: 125,
          child: PageView(
            controller: _promoController,
            onPageChanged: (idx) {
              ref.read(activePromoIndexProvider.notifier).state = idx;
            },
            children: [
              _buildSinglePromoCard(
                title: 'Create without limits',
                subtitle: 'Tastecraft fruit filling with over 35% real fruit.',
                buttonText: 'Shop here',
                badgeText: 'Ad',
                bgColor: const Color(0xFFFDE8D0),
                emoji: '🥬',
              ),
              _buildSinglePromoCard(
                title: 'Mandi Fresh Daily',
                subtitle: 'Direct farm wholesale rates refreshed every 6 AM.',
                buttonText: 'Explore',
                badgeText: 'Offer',
                bgColor: const Color(0xFFE0F2FE),
                emoji: '🥔',
              ),
              _buildSinglePromoCard(
                title: 'Bulk Cooking Oils',
                subtitle: 'Save up to 18% on Fortune, Emami 15L tins.',
                buttonText: 'View Deals',
                badgeText: 'Bulk',
                bgColor: const Color(0xFFFEF3C7),
                emoji: '🛢️',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Carousel Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final isActive = i == activeIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 14 : 5,
              height: 5,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFCD463E)
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSinglePromoCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required String badgeText,
    required Color bgColor,
    required String emoji,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Left Content
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    color: Color(0xFF475569),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        buttonText,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right Visual with Ad Badge
          Expanded(
            flex: 4,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.65),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 42)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCD463E),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 6. ORDER TRACKING STRIP
  // ==========================================================================
  Widget _buildOrderTrackerStrip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2EF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFECE8), width: 1),
      ),
      child: Row(
        children: [
          // Red Pulse Circle (Halo + Inner Dot matching Image 1)
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFFCD463E).withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF8F0F0A),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '#HP-48213 - Out for delivery - 6–8',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8F0F0A),
                letterSpacing: -0.2,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              ref.read(bottomNavIndexProvider.notifier).state =
                  3; // Switch to Orders
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Track',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8F0F0A),
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8F0F0A),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 7. COMPLETE ACCOUNT SETUP BANNER
  // ==========================================================================
  Widget _buildAccountSetupBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEEF0F3), width: 1),
      ),
      child: Row(
        children: [
          // Circular Icon Container matching Image 1
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF2EF),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.article_outlined,
              color: Color(0xFFCD463E),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Complete your account setup',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'to continue exploring',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11.5,
                    color: Color(0xFF8E95A0),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8F0F0A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            onPressed: () {
              ref.read(bottomNavIndexProvider.notifier).state =
                  4; // Switch to Account
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Start',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 3),
                Icon(Icons.chevron_right_rounded, size: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 8. CATEGORIES GRID (Adaptive 4 columns on phone, 6-8 on tablets)
  // ==========================================================================
  Widget _buildCategoriesSection(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    // Responsive columns
    final crossAxisCount = isTablet ? (isLandscape ? 8 : 6) : 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            InkWell(
              onTap: () {
                ref.read(bottomNavIndexProvider.notifier).state =
                    1; // Switch to Browse
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'All 22',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8F0F0A),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Categories Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, index) {
            final item = categories[index];
            return _buildCategoryTile(context, item);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryTile(BuildContext context, CategoryItem item) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${item.name.replaceAll('\n', ' ')}'),
            duration: const Duration(milliseconds: 800),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Soft Cyan/Mint Rounded Tile (Fixed 1:1 square)
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.categoryBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD6E8EC), width: 0.8),
              ),
              child: Center(
                child: Text(item.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
          ),
          const SizedBox(height: 5),
          // Category Label
          Text(
            item.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 9. CASHBACK PROMO NAVY BANNER ("Save ₹1,200 on first 4 orders")
  // ==========================================================================
  Widget _buildCashbackPromoBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bannerBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.bannerBlue.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Left Text & Button
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Save ₹1,200\non first 4 orders',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Get cashback up to ₹300 on\nyour first 4 orders.',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    color: Color(0xFFCBD5E1),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Complete sign up',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right Package Illustration Card
          Expanded(
            flex: 4,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🧂 🌾 🛢️', style: TextStyle(fontSize: 22)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Welcome Pack',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 10. FLOATING CART PILL ("3 items - ₹412  View cart")
  // ==========================================================================
  Widget _buildFloatingCartPill(BuildContext context) {
    final itemCount = ref.watch(cartItemCountProvider);
    final total = ref.watch(cartTotalProvider);

    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viewing Cart: $itemCount items (₹$total)'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.darkRed,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$itemCount items · ₹$total',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Text(
              'View cart',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 11. BOTTOM NAVIGATION BAR
  // ==========================================================================
  Widget _buildBottomNav(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final isTablet = context.isTablet;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 720 : double.infinity,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    0,
                    'Home',
                    AppAssets.navHome,
                    Icons.home_rounded,
                    currentIndex,
                  ),
                  _buildNavItem(
                    1,
                    'Browse',
                    AppAssets.navBrowse,
                    Icons.grid_view_rounded,
                    currentIndex,
                  ),
                  _buildNavItem(
                    2,
                    'Reorder',
                    AppAssets.navReorder,
                    Icons.sync_rounded,
                    currentIndex,
                  ),
                  _buildNavItem(
                    3,
                    'Orders',
                    AppAssets.navOrders,
                    Icons.receipt_long_rounded,
                    currentIndex,
                  ),
                  _buildNavItem(
                    4,
                    'Account',
                    AppAssets.navAccount,
                    Icons.person_rounded,
                    currentIndex,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    String assetPath,
    IconData fallbackIcon,
    int currentIndex,
  ) {
    final isSelected = index == currentIndex;
    final color = isSelected
        ? const Color(0xFFCD463E)
        : const Color(0xFF64748B);

    return InkWell(
      onTap: () {
        ref.read(bottomNavIndexProvider.notifier).state = index;
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              assetPath,
              width: 22,
              height: 22,
              color: color,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(fallbackIcon, color: color, size: 22),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // PLACEHOLDER TABS FOR OTHER 4 SECTIONS
  // ==========================================================================
  Widget _buildPlaceholderTab(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 54, color: const Color(0xFF94A3B8)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore wholesale mandi catalog and active items',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref.read(bottomNavIndexProvider.notifier).state =
                  0; // Return to Home
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTab(BuildContext context) {
    final slot = ref.watch(deliverySlotProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bulkify Customer Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Active Location: $slot',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.darkRed,
                ),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkRed,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.darkRed),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WelcomeLandingScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
