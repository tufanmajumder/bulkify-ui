import 'package:admin_app/utils/asset_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/controllers/user_profile_controller.dart';
import 'package:admin_app/models/user_model.dart';
import 'package:admin_app/utils/responsive.dart';
import 'widgets/header.dart';
import 'widgets/sidebar.dart';

class DottedLine extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  final double dashGap;

  const DottedLine({
    super.key,
    this.height = 1,
    this.color = const Color(0xFFD1D5DB),
    this.dashWidth = 2,
    this.dashGap = 3,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        if (boxWidth <= 0 || boxWidth.isInfinite) {
          return const SizedBox.shrink();
        }
        final dashCount = (boxWidth / (dashWidth + dashGap)).floor();
        if (dashCount <= 0) {
          return const SizedBox.shrink();
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProfileController controller = Get.put(UserProfileController());

    final dynamic args = Get.arguments;
    if (args != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (args is UserModel &&
            args.id.isNotEmpty &&
            controller.userkey.value != args.id) {
          controller.userkey.value = args.id;
          controller.setUserModel(args);
          controller.fetchUserDetails(args.id);
        }
      });
    }

    final isMobileOrTablet =
        Responsive.isMobile(context) || Responsive.isTablet(context);
    final dynamicPadding = Responsive.dynamicPadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F8),
      drawer: isMobileOrTablet
          ? const Drawer(
              backgroundColor: Colors.white,
              child: Sidebar(isDrawer: true, activeRoute: '/user-profile'),
            )
          : null,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(left: isMobileOrTablet ? 0.0 : 72.0),
            child: Column(
              children: [
                const Header(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(dynamicPadding),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 950;
                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 330,
                                child: Column(
                                  children: [
                                    _buildProfileSummaryCard(
                                      context,
                                      controller,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildBasicInfoCard(context, controller),
                                    const SizedBox(height: 16),
                                    _buildContactInfoCard(context, controller),
                                    const SizedBox(height: 16),
                                    _buildDocumentInfoCard(context, controller),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildOrderDetailsCard(
                                  context,
                                  controller,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileSummaryCard(context, controller),
                              const SizedBox(height: 16),
                              _buildBasicInfoCard(context, controller),
                              const SizedBox(height: 16),
                              _buildContactInfoCard(context, controller),
                              const SizedBox(height: 16),
                              _buildDocumentInfoCard(context, controller),
                              const SizedBox(height: 20),
                              _buildOrderDetailsCard(context, controller),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isMobileOrTablet)
            const Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Sidebar(activeRoute: '/user-profile'),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // CARD 1: PROFILE SUMMARY CARD
  // ==========================================
  Widget _buildProfileSummaryCard(
    BuildContext context,
    UserProfileController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: const Color(0xFFFEE2E2),
                        child: controller.avatarUrl.value.trim().isNotEmpty
                            ? (controller.avatarUrl.value.startsWith('http')
                                ? Image.network(
                                    controller.avatarUrl.value,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _buildNameAvatar(controller.name.value),
                                  )
                                : Image.asset(
                                    controller.avatarUrl.value,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _buildNameAvatar(controller.name.value),
                                  ))
                            : _buildNameAvatar(controller.name.value),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.name.value,
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: Responsive.sp(context, 15),
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        controller.role.value,
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w400,
                          fontSize: Responsive.sp(context, 12.5),
                          color: const Color(0xE62F2B3D),
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContactRow(
              context,
              AssetManager.mail,
              controller.email.value,
            ),
            const SizedBox(height: 8),
            _buildContactRow(
              context,
              AssetManager.call,
              controller.mobile.value,
            ),
            const SizedBox(height: 8),
            _buildContactRow(
              context,
              AssetManager.map,
              controller.country.value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, String icon, String text) {
    return Row(
      children: [
        Image.asset(icon, width: 13, height: 13),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: Responsive.sp(context, 11),
              color: Colors.black,
              letterSpacing: 0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNameAvatar(String name) {
    final trimmed = name.trim();
    final firstLetter = (trimmed.isNotEmpty && trimmed != '-')
        ? trimmed[0].toUpperCase()
        : '?';

    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      color: const Color(0xFFFEE2E2),
      child: Text(
        firstLetter,
        style: const TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFFCF4340),
        ),
      ),
    );
  }

  // ==========================================
  // CARD 2: BASIC INFORMATION CARD
  // ==========================================
  Widget _buildBasicInfoCard(
    BuildContext context,
    UserProfileController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: Responsive.sp(context, 15),
                fontWeight: FontWeight.w500,
                color: Colors.black,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 6),
            _buildDottedInfoRow(
              context,
              'Created On',
              controller.createdOn.value,
            ),
            _buildDottedInfoRow(context, 'Gender', controller.gender.value),
            _buildDottedInfoRow(context, 'Date of Birth', controller.dob.value),
            _buildDottedInfoRow(context, 'Type', controller.type.value),
            _buildDottedInfoRow(context, 'Role', controller.role.value),
            _buildDottedInfoRow(context, 'Country', controller.country.value),
            _buildDottedInfoRow(context, 'Language', controller.language.value),
            _buildDottedInfoRow(
              context,
              'Vehicle No.',
              controller.vehicleNo.value,
            ),
            _buildDottedInfoRow(
              context,
              'Portal',
              controller.portal.value,
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDottedInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xB32F2B3D),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const DottedLine(color: Color(0xFFE5E7EB), dashWidth: 3, dashGap: 3),
      ],
    );
  }

  // ==========================================
  // CARD 3: CONTACT INFORMATION CARD
  // ==========================================
  Widget _buildContactInfoCard(
    BuildContext context,
    UserProfileController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: Responsive.sp(context, 15),
                fontWeight: FontWeight.w500,
                color: Colors.black,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 6),
            _buildDottedContactRow(
              context,
              AssetManager.mail,
              'Email',
              controller.email.value,
            ),
            _buildDottedContactRow(
              context,
              AssetManager.mob,
              'Mobile',
              controller.mobile.value,
            ),
            _buildDottedContactRow(
              context,
              AssetManager.call,
              'Emgy. Contact No.',
              controller.emergencyContact.value,
            ),
            _buildDottedContactRow(
              context,
              AssetManager.call,
              'Emgy. Contact Name',
              controller.emergencyContactName.value,
            ),
            _buildDottedContactRow(
              context,
              AssetManager.whatsapp,
              'WhatsApp',
              controller.whatsapp.value,
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDottedContactRow(
    BuildContext context,
    String icon,
    String label,
    String value, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(icon, width: 13, height: 13),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xB32F2B3D),
                    ),
                  ),
                ],
              ),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const DottedLine(color: Color(0xFFE5E7EB), dashWidth: 3, dashGap: 3),
      ],
    );
  }

  // ==========================================
  // CARD 4: DOCUMENT INFORMATION CARD
  // ==========================================
  Widget _buildDocumentInfoCard(
    BuildContext context,
    UserProfileController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Information',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: Responsive.sp(context, 15),
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            _buildDottedInfoRow(context, 'Doc Type', controller.docType.value),
            _buildDottedInfoRow(
              context,
              'Doc Number',
              controller.docNumber.value,
            ),
            _buildDottedInfoRow(
              context,
              'Expiry',
              controller.docExpiry.value,
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // RIGHT SIDE: ORDER DETAILS CARD
  // ==========================================
  Widget _buildOrderDetailsCard(
    BuildContext context,
    UserProfileController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 20,
              right: 20,
              bottom: 16,
            ),
            child: Text(
              'Order Details',
              style: TextStyle(
                fontFamily: 'Public-Sans',
                fontSize: Responsive.sp(context, 15),
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const minWidth = 720.0;
              final tableWidth = constraints.maxWidth < minWidth
                  ? minWidth
                  : constraints.maxWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      // Header Row
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF9FAFB),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE5E7EB)),
                            bottom: BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'ORDER NO.',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xE62F2B3D),
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'DATE & TIME',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xE62F2B3D),
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                'CUSTOMER',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xE62F2B3D),
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'PAYMENT',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xE62F2B3D),
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'AMOUNT',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xE62F2B3D),
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'ACTION',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xE62F2B3D),
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Order Items List
                      Obx(() {
                        final orders = controller.orderDetailsList;
                        return orders.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Center(child: Text("No order found!")),
                              )
                            : Column(
                                children: orders.map((item) {
                                  final isPaid = item['payment'] == 'Paid';
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color(0xFFF3F4F6),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // ORD NO.
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            item['ordNo'] ?? '',
                                            style: TextStyle(
                                              fontFamily: 'Public Sans',
                                              fontSize: Responsive.sp(
                                                context,
                                                12.5,
                                              ),
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFFCF4340),
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ),
                                        // DATE & TIME
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            item['dateTime'] ?? '',
                                            style: TextStyle(
                                              fontFamily: 'Public Sans',
                                              fontSize: Responsive.sp(
                                                context,
                                                12.5,
                                              ),
                                              color: Color(0xFF6B7280),
                                              height: 1.3,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ),
                                        // CUST NAME
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            item['custName'] ?? '',
                                            style: TextStyle(
                                              fontFamily: 'Public Sans',
                                              fontSize: Responsive.sp(
                                                context,
                                                12.5,
                                              ),
                                              color: Color(0xFF6B7280),
                                              height: 1.3,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ),
                                        // PAYMENT
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            item['payment'] ?? '',
                                            style: TextStyle(
                                              fontFamily: 'Public Sans',
                                              fontSize: Responsive.sp(
                                                context,
                                                12.5,
                                              ),
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w400,
                                              color: isPaid
                                                  ? const Color(0xFF10B981)
                                                  : const Color(0xFFF59E0B),
                                            ),
                                          ),
                                        ),
                                        // AMOUNT
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            item['amount'] ?? '',
                                            style: TextStyle(
                                              fontFamily: 'Public Sans',
                                              fontSize: Responsive.sp(
                                                context,
                                                12.5,
                                              ),
                                              color: Color(0xFF6B7280),
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        // ACTION
                                        Expanded(
                                          flex: 1,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.more_vert,
                                              size: 18,
                                              color: Color(0xFFA0AEC0),
                                            ),
                                            onPressed: () {},
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
