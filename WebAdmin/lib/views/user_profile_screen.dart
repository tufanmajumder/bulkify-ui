import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/controllers/user_profile_controller.dart';
import 'package:admin_app/utils/responsive.dart';
import 'widgets/header.dart';
import 'widgets/sidebar.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate or retrieve UserProfileController via GetX
    final UserProfileController controller = Get.put(UserProfileController());

    final isMobileOrTablet =
        Responsive.isMobile(context) || Responsive.isTablet(context);
    final dynamicPadding = Responsive.dynamicPadding(context);
    final spacingHeight = Responsive.h(context, 2.5).clamp(16.0, 24.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      drawer: isMobileOrTablet
          ? const Drawer(
              backgroundColor: Colors.white,
              child: Sidebar(isDrawer: true, activeRoute: '/user-profile'),
            )
          : null,
      body: Stack(
        children: [
          // Main Content Layout
          Padding(
            padding: EdgeInsets.only(left: isMobileOrTablet ? 0.0 : 72.0),
            child: Column(
              children: [
                // Top Navigation Header
                const Header(),

                // Scrollable Body Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(dynamicPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row: 3 Profile Cards (Summary, Basic Info, Personal Info)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 900) {
                              return Column(
                                children: [
                                  _buildProfileSummaryCard(context, controller),
                                  SizedBox(height: spacingHeight),
                                  _buildBasicInfoCard(context, controller),
                                  SizedBox(height: spacingHeight),
                                  _buildPersonalInfoCard(context, controller),
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: _buildProfileSummaryCard(
                                    context,
                                    controller,
                                  ),
                                ),
                                SizedBox(width: spacingHeight),
                                Expanded(
                                  flex: 3,
                                  child: _buildBasicInfoCard(
                                    context,
                                    controller,
                                  ),
                                ),
                                SizedBox(width: spacingHeight),
                                Expanded(
                                  flex: 3,
                                  child: _buildPersonalInfoCard(
                                    context,
                                    controller,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: spacingHeight * 1.2),

                        // Tab Navigation Header (GetX Reactive)
                        Obx(
                          () => SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(controller.tabs.length, (
                                index,
                              ) {
                                final isSelected =
                                    controller.selectedTabIndex.value == index;
                                final tabData = controller.tabs[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: InkWell(
                                    onTap: () => controller.changeTab(index),
                                    borderRadius: BorderRadius.circular(8),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFCF4340)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFCF4340)
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            tabData['icon'] as IconData,
                                            size: 18,
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            tabData['title'] as String,
                                            style: TextStyle(
                                              fontSize: Responsive.sp(
                                                context,
                                                13,
                                              ),
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF475569),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        SizedBox(height: spacingHeight * 1.2),

                        // Dynamic Tab Content View (GetX Obx)
                        Obx(() {
                          switch (controller.selectedTabIndex.value) {
                            case 0:
                              return _buildInvoiceListCard(context, controller);
                            case 1:
                              return _buildSecurityTabCard(context, controller);
                            case 2:
                              return _buildBillingTabCard(context, controller);
                            case 3:
                              return _buildNotificationsTabCard(
                                context,
                                controller,
                              );
                            case 4:
                              return _buildConnectionsTabCard(
                                context,
                                controller,
                              );
                            default:
                              return _buildInvoiceListCard(context, controller);
                          }
                        }),
                        SizedBox(height: spacingHeight * 1.5),

                        // Footer
                        Container(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: RichText(
                              textAlign: TextAlign.right,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: Responsive.sp(context, 13),
                                  color: const Color(0xFF64748B),
                                ),
                                children: const [
                                  TextSpan(text: '© Developed by '),
                                  TextSpan(
                                    text: 'Digital Trident Solutions',
                                    style: TextStyle(
                                      color: Color(0xFFCF4340),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
          ),

          // Left Navigation Sidebar (Desktop view)
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
  // TOP PROFILE SUMMARY CARDS (GETX REACTIVE)
  // ==========================================

  Widget _buildProfileSummaryCard(
    BuildContext context,
    UserProfileController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar with GetX Obx
              Obx(
                () => Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      controller.avatarUrl.value,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF475569),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Stats Grid
              Expanded(
                child: Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatItem(
                              context,
                              Icons.check_box_outlined,
                              controller.tasksDone.value,
                              'Task Done',
                            ),
                            const SizedBox(height: 12),
                            _buildStatItem(
                              context,
                              Icons.business_center_outlined,
                              controller.projectsDone.value,
                              'Project Done',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatItem(
                              context,
                              Icons.star_outline_rounded,
                              '4.9',
                              'Rating',
                            ),
                            const SizedBox(height: 12),
                            _buildStatItem(
                              context,
                              Icons.timer_outlined,
                              '98%',
                              'On Time Rate',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action Buttons: Edit (Modal Dialog) & Suspend Toggle
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _showEditProfileDialog(context, controller),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: Responsive.sp(context, 13),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCF4340),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(() {
                final isSuspended = controller.status.value == 'Suspended';
                return ElevatedButton.icon(
                  onPressed: () => controller.toggleSuspendStatus(),
                  icon: Icon(
                    isSuspended
                        ? Icons.play_arrow_rounded
                        : Icons.block_rounded,
                    size: 16,
                    color: isSuspended
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                  label: Text(
                    isSuspended ? 'Activate' : 'Suspend',
                    style: TextStyle(
                      color: isSuspended
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                      fontSize: Responsive.sp(context, 13),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuspended
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEE2E2),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFDE8E8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFCF4340), size: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: Responsive.sp(context, 14),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: Responsive.sp(context, 11),
                  color: const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Card 2: Basic Information Card (GetX Reactive)
  Widget _buildBasicInfoCard(
    BuildContext context,
    UserProfileController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECEF)),
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: TextStyle(
                fontSize: Responsive.sp(context, 15),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Role', controller.role.value),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Emergency Contact',
              controller.emergencyContact.value,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 13),
                    color: const Color(0xFF64748B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: controller.status.value == 'Active'
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    controller.status.value,
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 12),
                      fontWeight: FontWeight.w600,
                      color: controller.status.value == 'Active'
                          ? const Color(0xFF059669)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(context, 'Name', controller.name.value),
          ],
        ),
      ),
    );
  }

  /// Card 3: Personal Information Card (GetX Reactive)
  Widget _buildPersonalInfoCard(
    BuildContext context,
    UserProfileController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECEF)),
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: Responsive.sp(context, 15),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Name', controller.name.value),
            const SizedBox(height: 12),
            _buildInfoRow(context, 'Mobile', controller.mobile.value),
            const SizedBox(height: 12),
            _buildInfoRow(context, 'Email', controller.email.value),
            const SizedBox(height: 12),
            _buildInfoRow(context, 'WhatsApp', controller.whatsapp.value),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(context, 13),
            color: const Color(0xFF64748B),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: Responsive.sp(context, 13),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // OVERVIEW TAB: INVOICE TABLE (GETX REACTIVE)
  // ==========================================

  Widget _buildInvoiceListCard(
    BuildContext context,
    UserProfileController controller,
  ) {
    final fontSize = Responsive.sp(context, 13);
    final borderColor = const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar (Invoice Title + Search + Rows Dropdown + Export)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Text(
                  'Invoice List',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 16),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search Field
                    SizedBox(
                      height: 38,
                      width: 180,
                      child: TextField(
                        onChanged: (val) =>
                            controller.invoiceSearchQuery.value = val,
                        decoration: InputDecoration(
                          hintText: 'Search invoice...',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 16,
                            color: Color(0xFF94A3B8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFCF4340),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Rows Per Page Menu
                    Obx(
                      () => PopupMenuButton<int>(
                        onSelected: (rows) => controller.setRowsPerPage(rows),
                        itemBuilder: (context) => [10, 20, 50].map((r) {
                          return PopupMenuItem<int>(
                            value: r,
                            child: Text('$r rows per page'),
                          );
                        }).toList(),
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${controller.rowsPerPage.value}',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  color: const Color(0xFF475569),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: Color(0xFF94A3B8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Export Button
                    ElevatedButton.icon(
                      onPressed: () => controller.exportInvoices(),
                      icon: const Icon(
                        Icons.upload_outlined,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                      label: Text(
                        'Export',
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        elevation: 0,
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Table Content with Obx
          LayoutBuilder(
            builder: (context, constraints) {
              final double minTableWidth = 750.0;
              final double tableWidth = constraints.maxWidth < minTableWidth
                  ? minTableWidth
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
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(color: borderColor),
                            bottom: BorderSide(color: borderColor),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildHeaderCell(
                                context,
                                '#',
                                hasDivider: true,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: _buildHeaderCell(
                                context,
                                'TOTAL',
                                hasDivider: true,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: _buildHeaderCell(
                                context,
                                'ISSUED DATE',
                                hasDivider: true,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _buildHeaderCell(
                                context,
                                'ACTION',
                                hasDivider: false,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Data Rows (Obx)
                      Obx(() {
                        final paginated = controller.paginatedInvoices;
                        if (paginated.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'No invoices found',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: paginated.map((inv) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFF1F5F9)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Invoice ID
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      inv['id']!,
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFCF4340),
                                      ),
                                    ),
                                  ),
                                  // Total Amount
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      inv['total']!,
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        color: const Color(0xFF475569),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  // Date
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      inv['date']!,
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        color: const Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                  // Actions
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.visibility_outlined,
                                            size: 18,
                                            color: Color(0xFF64748B),
                                          ),
                                          tooltip: 'View Invoice',
                                          onPressed: () => controller
                                              .viewInvoice(inv['id']!),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                            color: Color(0xFFEF4444),
                                          ),
                                          tooltip: 'Delete Invoice',
                                          onPressed: () => controller
                                              .deleteInvoice(inv['id']!),
                                        ),
                                      ],
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

          // Pagination Footer with Obx
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 13),
                        color: const Color(0xFF94A3B8),
                      ),
                      children: [
                        const TextSpan(text: 'Showing '),
                        TextSpan(
                          text: '${controller.startEntryIndex}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const TextSpan(text: ' to '),
                        TextSpan(
                          text: '${controller.endEntryIndex}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                          ),
                        ),
                        TextSpan(
                          text:
                              ' of ${controller.filteredInvoices.length} entries',
                        ),
                      ],
                    ),
                  ),

                  // Pagination Buttons
                  Row(
                    children: [
                      _buildPageNavBtn(
                        context,
                        Icons.keyboard_double_arrow_left_rounded,
                        onTap: () => controller.setPage(1),
                      ),
                      const SizedBox(width: 6),
                      _buildPageNavBtn(
                        context,
                        Icons.keyboard_arrow_left_rounded,
                        onTap: () => controller.setPage(
                          controller.currentPage.value - 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      ...List.generate(controller.totalPages.clamp(1, 5), (i) {
                        final pageNum = i + 1;
                        final isSelected =
                            controller.currentPage.value == pageNum;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: _buildPageNumBtn(
                            context,
                            '$pageNum',
                            isSelected,
                            onTap: () => controller.setPage(pageNum),
                          ),
                        );
                      }),
                      _buildPageNavBtn(
                        context,
                        Icons.keyboard_arrow_right_rounded,
                        onTap: () => controller.setPage(
                          controller.currentPage.value + 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _buildPageNavBtn(
                        context,
                        Icons.keyboard_double_arrow_right_rounded,
                        onTap: () => controller.setPage(controller.totalPages),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: SECURITY CARD
  // ==========================================

  Widget _buildSecurityTabCard(
    BuildContext context,
    UserProfileController controller,
  ) {
    final borderColor = const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security Settings',
            style: TextStyle(
              fontSize: Responsive.sp(context, 16),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Manage password updates and multi-factor authentication.',
            style: TextStyle(
              fontSize: Responsive.sp(context, 13),
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Change Password Section
          const Text(
            'Change Password',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 32) / 3
                        : constraints.maxWidth,
                    child: TextField(
                      controller: controller.currentPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Current Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 32) / 3
                        : constraints.maxWidth,
                    child: TextField(
                      controller: controller.newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 32) / 3
                        : constraints.maxWidth,
                    child: TextField(
                      controller: controller.confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.changePassword(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCF4340),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Update Password',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const Divider(height: 40),

          // 2-Factor Auth Section
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Two-Factor Authentication (2FA)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Add an extra layer of security to your admin account',
              ),
              value: controller.twoFactorEnabled.value,
              activeThumbColor: const Color(0xFFCF4340),
              onChanged: (val) => controller.toggleTwoFactor(val),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: BILLING & PLANS CARD
  // ==========================================

  Widget _buildBillingTabCard(
    BuildContext context,
    UserProfileController controller,
  ) {
    final borderColor = const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Billing & Active Plan',
            style: TextStyle(
              fontSize: Responsive.sp(context, 16),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCF4340), Color(0xFFE55350)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.currentPlan.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Billing Cycle: ${controller.planBillingCycle.value} • ${controller.planPrice.value}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.snackbar('Plan', 'Plan upgrade options dialog');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFCF4340),
                    ),
                    child: const Text('Upgrade Plan'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Payment Method',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Obx(
            () => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.credit_card,
                size: 36,
                color: Color(0xFF475569),
              ),
              title: Text('Visa ending in ${controller.cardLastFour.value}'),
              subtitle: Text('Expires ${controller.cardExpiry.value}'),
              trailing: TextButton(
                onPressed: () {},
                child: const Text(
                  'Edit Card',
                  style: TextStyle(color: Color(0xFFCF4340)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: NOTIFICATIONS CARD
  // ==========================================

  Widget _buildNotificationsTabCard(
    BuildContext context,
    UserProfileController controller,
  ) {
    final borderColor = const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Preferences',
            style: TextStyle(
              fontSize: Responsive.sp(context, 16),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: const Color(0xFFCF4340),
                  title: const Text(
                    'Email Notifications',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Receive daily summaries and system status via email.',
                  ),
                  value: controller.emailNotifications.value,
                  onChanged: (val) => controller.emailNotifications.value = val,
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: const Color(0xFFCF4340),
                  title: const Text(
                    'Push Notifications',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Receive instant browser and app push alerts.',
                  ),
                  value: controller.pushNotifications.value,
                  onChanged: (val) => controller.pushNotifications.value = val,
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: const Color(0xFFCF4340),
                  title: const Text(
                    'SMS Alerts',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Send high priority security alerts via SMS.',
                  ),
                  value: controller.smsAlerts.value,
                  onChanged: (val) => controller.smsAlerts.value = val,
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: const Color(0xFFCF4340),
                  title: const Text(
                    'Marketing & Product Updates',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Receive news on feature releases and special offers.',
                  ),
                  value: controller.marketingEmails.value,
                  onChanged: (val) => controller.marketingEmails.value = val,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: CONNECTIONS CARD
  // ==========================================

  Widget _buildConnectionsTabCard(
    BuildContext context,
    UserProfileController controller,
  ) {
    final borderColor = const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connected Services',
            style: TextStyle(
              fontSize: Responsive.sp(context, 16),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.connectedApps.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final app = controller.connectedApps[index];
                final isConnected = app['connected'] as bool;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFF1F5F9),
                    child: Icon(
                      app['icon'] as IconData,
                      color: const Color(0xFFCF4340),
                    ),
                  ),
                  title: Text(
                    app['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(app['description'] as String),
                  trailing: ElevatedButton(
                    onPressed: () => controller.toggleAppConnection(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isConnected
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFFCF4340),
                      foregroundColor: isConnected
                          ? const Color(0xFF64748B)
                          : Colors.white,
                      elevation: 0,
                    ),
                    child: Text(isConnected ? 'Disconnect' : 'Connect'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // EDIT PROFILE DIALOG (GETX)
  // ==========================================

  void _showEditProfileDialog(
    BuildContext context,
    UserProfileController controller,
  ) {
    final nameCtrl = TextEditingController(text: controller.name.value);
    final emailCtrl = TextEditingController(text: controller.email.value);
    final mobileCtrl = TextEditingController(text: controller.mobile.value);
    final roleCtrl = TextEditingController(text: controller.role.value);
    final emergencyCtrl = TextEditingController(
      text: controller.emergencyContact.value,
    );
    final whatsappCtrl = TextEditingController(text: controller.whatsapp.value);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Profile Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: mobileCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: roleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emergencyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Emergency Contact',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: whatsappCtrl,
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      controller.updateProfileInfo(
                        newName: nameCtrl.text.trim(),
                        newEmail: emailCtrl.text.trim(),
                        newMobile: mobileCtrl.text.trim(),
                        newRole: roleCtrl.text.trim(),
                        newEmergency: emergencyCtrl.text.trim(),
                        newWhatsapp: whatsappCtrl.text.trim(),
                      );
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCF4340),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper UI Widgets
  Widget _buildHeaderCell(
    BuildContext context,
    String text, {
    required bool hasDivider,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: Responsive.sp(context, 12),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF475569),
            letterSpacing: 0.6,
          ),
        ),
        if (hasDivider)
          Container(
            height: 14,
            width: 1,
            margin: const EdgeInsets.only(right: 20),
            color: const Color(0xFFE2E8F0),
          ),
      ],
    );
  }

  Widget _buildPageNavBtn(
    BuildContext context,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Icon(icon, size: 18, color: const Color(0xFF475569)),
        ),
      ),
    );
  }

  Widget _buildPageNumBtn(
    BuildContext context,
    String num,
    bool isSelected, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFCF4340) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            num,
            style: TextStyle(
              fontSize: Responsive.sp(context, 13),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}
