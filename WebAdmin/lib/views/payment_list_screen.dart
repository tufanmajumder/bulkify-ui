import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/controllers/payment_controller.dart';
import 'package:admin_app/models/payment_model.dart';
import 'package:admin_app/utils/responsive.dart';
import 'package:admin_app/views/widgets/header.dart';
import 'package:admin_app/views/widgets/sidebar.dart';

class PaymentListScreen extends StatelessWidget {
  const PaymentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PaymentController controller = Get.put(PaymentController());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Row(
        children: [
          // Sidebar
          const Sidebar(activeRoute: '/payment-details'),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Navigation / Header
                const Header(),

                // Body Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(Responsive.w(context, 2)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top 4 Analytics Stat Cards
                        // _buildStatCardsRow(context, controller),
                        // const SizedBox(height: 20),

                        // Main Card Container with Action Bar + Table + Footer
                        _buildMainContentCard(context, controller),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Top Stat Cards (4 Cards)
  Widget _buildStatCardsRow(
    BuildContext context,
    PaymentController controller,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        int crossAxisCount = 4;
        if (width < 600) {
          crossAxisCount = 1;
        } else if (width < 1100) {
          crossAxisCount = 2;
        }

        if (crossAxisCount == 4) {
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Completed',
                  value: controller.completedCount.value,
                  badge: controller.completedChange.value,
                  badgeIsNegative: true,
                  subtitle: 'Last week analytics',
                  icon: Icons.done_all_rounded,
                  iconBg: const Color(0xFFDCFCE7),
                  iconColor: const Color(0xFF22C55E),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Pending Payment',
                  value: controller.pendingPaymentCount.value,
                  badge: controller.pendingChange.value,
                  badgeIsNegative: false,
                  subtitle: 'Last week analytics',
                  icon: Icons.edit_calendar_outlined,
                  iconBg: const Color(0xFFFEF3C7),
                  iconColor: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Refund',
                  value: controller.refundCount.value,
                  badge: controller.refundChange.value,
                  badgeIsNegative: false,
                  subtitle: 'Last week analytics',
                  icon: Icons.account_balance_wallet_outlined,
                  iconBg: const Color(0xFFF3E8FF),
                  iconColor: const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Failed',
                  value: controller.failedCount.value,
                  badge: controller.failedChange.value,
                  badgeIsNegative: false,
                  subtitle: 'Total Users',
                  icon: Icons.error_outline_rounded,
                  iconBg: const Color(0xFFFEE2E2),
                  iconColor: const Color(0xFFEF4444),
                ),
              ),
            ],
          );
        }

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: (width - (crossAxisCount - 1) * 16) / crossAxisCount,
              child: _buildStatCard(
                context,
                title: 'Completed',
                value: controller.completedCount.value,
                badge: controller.completedChange.value,
                badgeIsNegative: true,
                subtitle: 'Last week analytics',
                icon: Icons.done_all_rounded,
                iconBg: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF22C55E),
              ),
            ),
            SizedBox(
              width: (width - (crossAxisCount - 1) * 16) / crossAxisCount,
              child: _buildStatCard(
                context,
                title: 'Pending Payment',
                value: controller.pendingPaymentCount.value,
                badge: controller.pendingChange.value,
                badgeIsNegative: false,
                subtitle: 'Last week analytics',
                icon: Icons.edit_calendar_outlined,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFF59E0B),
              ),
            ),
            SizedBox(
              width: (width - (crossAxisCount - 1) * 16) / crossAxisCount,
              child: _buildStatCard(
                context,
                title: 'Refund',
                value: controller.refundCount.value,
                badge: controller.refundChange.value,
                badgeIsNegative: false,
                subtitle: 'Last week analytics',
                icon: Icons.account_balance_wallet_outlined,
                iconBg: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF8B5CF6),
              ),
            ),
            SizedBox(
              width: (width - (crossAxisCount - 1) * 16) / crossAxisCount,
              child: _buildStatCard(
                context,
                title: 'Failed',
                value: controller.failedCount.value,
                badge: controller.failedChange.value,
                badgeIsNegative: false,
                subtitle: 'Total Users',
                icon: Icons.error_outline_rounded,
                iconBg: const Color(0xFFFEE2E2),
                iconColor: const Color(0xFFEF4444),
              ),
            ),
          ],
        );
      },
    );
  }

  // Individual Stat Card Widget
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String badge,
    required bool badgeIsNegative,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      badge,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: badgeIsNegative
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ],
      ),
    );
  }

  // 2. Main Content Card (Control Bar + Table + Footer)
  Widget _buildMainContentCard(
    BuildContext context,
    PaymentController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Control / Action Bar
          _buildActionBar(context, controller),

          // Payments Table
          _buildPaymentTable(context, controller),

          // Pagination Footer
          _buildPaginationFooter(context, controller),
        ],
      ),
    );
  }

  // Action Bar (Rows per page, Export, Search, Status filter, Initiate Button)
  Widget _buildActionBar(BuildContext context, PaymentController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 900;

          if (isCompact) {
            return Column(
              children: [
                Row(
                  children: [
                    _buildRowsPerPageDropdown(controller),
                    const SizedBox(width: 12),
                    _buildExportBtn(),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildSearchInput(controller)),
                    const SizedBox(width: 12),
                    _buildStatusDropdown(controller),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _buildInitiatePaymentBtn(context, controller),
                ),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side: Rows per page & Export
              Row(
                children: [
                  _buildRowsPerPageDropdown(controller),
                  const SizedBox(width: 12),
                  _buildExportBtn(),
                ],
              ),

              // Right side: Search, Status filter & Initiate Button
              Row(
                children: [
                  SizedBox(width: 220, child: _buildSearchInput(controller)),
                  const SizedBox(width: 12),
                  _buildStatusDropdown(controller),
                  const SizedBox(width: 12),
                  _buildInitiatePaymentBtn(context, controller),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRowsPerPageDropdown(PaymentController controller) {
    return Obx(
      () => Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: controller.rowsPerPage.value,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFF64748B),
            ),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
            onChanged: (val) {
              if (val != null) {
                controller.rowsPerPage.value = val;
                controller.currentPage.value = 1;
              }
            },
            items: [10, 25, 50].map((int val) {
              return DropdownMenuItem<int>(value: val, child: Text('$val'));
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildExportBtn() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: const [
          Text(
            'Export',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
          ),
          SizedBox(width: 6),
          Icon(Icons.download_outlined, size: 16, color: Color(0xFF475569)),
        ],
      ),
    );
  }

  Widget _buildSearchInput(PaymentController controller) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        onChanged: controller.setSearchQuery,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
        decoration: const InputDecoration(
          hintText: 'Search UTR/RRN',
          hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(PaymentController controller) {
    return Obx(
      () => Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedStatus.value,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFF64748B),
            ),
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            onChanged: controller.setStatusFilter,
            items: controller.statusOptions.map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val == 'All' ? 'Select Status' : val),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildInitiatePaymentBtn(
    BuildContext context,
    PaymentController controller,
  ) {
    return ElevatedButton.icon(
      onPressed: () => controller.initiateNewPayment(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFCF4340),
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      icon: const Icon(Icons.add, size: 18),
      label: const Text(
        'Initiate New Payment',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Payments Data Table
  Widget _buildPaymentTable(
    BuildContext context,
    PaymentController controller,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double minTableWidth = 1100.0;
        final double tableWidth = constraints.maxWidth < minTableWidth
            ? minTableWidth
            : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Column(
              children: [
                // Table Header Row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    border: Border(
                      top: BorderSide(color: Color(0xFFE2E8F0)),
                      bottom: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 5, child: _buildHeaderCell('ORDER ID')),
                      Expanded(flex: 5, child: _buildHeaderCell('PAYMENT ID')),
                      Expanded(flex: 5, child: _buildHeaderCell('UTR/RRN')),
                      Expanded(
                        flex: 5,
                        child: _buildHeaderCell('CUSTOMER DETAILS'),
                      ),
                      Expanded(flex: 4, child: _buildHeaderCell('CREATED ON')),
                      Expanded(flex: 4, child: _buildHeaderCell('STATUS')),
                      Expanded(
                        flex: 4,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _buildHeaderCell('AMOUNT'),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _buildHeaderCell('ACTION'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Table Data Rows
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFCF4340),
                        ),
                      ),
                    );
                  }

                  final list = controller.paginatedPayments;

                  if (list.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(
                        child: Text(
                          'No payment records found',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: list.map((item) {
                      return _buildPaymentRow(context, controller, item);
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF475569),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildPaymentRow(
    BuildContext context,
    PaymentController controller,
    PaymentModel item,
  ) {
    final double fontSize = Responsive.sp(context, 13);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. ORDER ID
          Expanded(
            flex: 5,
            child: Text(
              item.orderId,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ),

          // 2. PAYMENT ID
          Expanded(
            flex: 5,
            child: Text(
              item.paymentId,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
              ),
            ),
          ),

          // 3. UTR/RRN (UTR on top, Payment Method subtext)
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.utrRrn,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.paymentMethod,
                  style: TextStyle(
                    fontSize: fontSize - 2,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // 4. CUSTOMER DETAILS (Name on top, NA subtext)
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.customerName,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "-",
                  //item.customerSubtext,
                  style: TextStyle(
                    fontSize: fontSize - 2,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // 5. CREATED ON (Date line 1, Time line 2)
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.date,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.time,
                  style: TextStyle(
                    fontSize: fontSize - 2,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // 6. STATUS
          Expanded(flex: 4, child: _buildStatusCell(item.status)),

          // 7. AMOUNT (Right Aligned)
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                item.amount,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ),

          // 8. ACTION Menu
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                onSelected: (val) {
                  // Get.snackbar(
                  //   'Payment Action',
                  //   '$val for ${item.orderId}',
                  //   snackPosition: SnackPosition.BOTTOM,
                  //   margin: const EdgeInsets.all(16),
                  // );
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'View Details',
                    child: Text('View Details'),
                  ),
                  // const PopupMenuItem(
                  //   value: 'Copy UTR',
                  //   child: Text('Copy UTR'),
                  // ),
                  // const PopupMenuItem(
                  //   value: 'Download Receipt',
                  //   child: Text('Download Receipt'),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCell(String status) {
    Color color;

    switch (status.toLowerCase()) {
      case 'success':
        color = const Color(0xFF10B981);
        break;
      case 'pending':
        color = const Color(0xFFF97316);
        break;
      case 'failed':
        color = const Color(0xFFEF4444);
        break;
      case 'refund':
        color = const Color(0xFF8B5CF6);
        break;
      default:
        color = const Color(0xFF64748B);
    }

    return Text(
      status,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color),
    );
  }

  // Pagination Footer
  Widget _buildPaginationFooter(
    BuildContext context,
    PaymentController controller,
  ) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Showing 1 to 10 of 50 entries
            Text(
              'Showing ${controller.startEntryIndex} to ${controller.endEntryIndex} of ${controller.filteredPayments.length} entries',
              style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),

            // Page Nav Buttons (<<, <, 1, 2, 3, 4, 5, >, >>)
            Row(
              children: [
                _buildNavBtn(
                  context,
                  Icons.keyboard_double_arrow_left_rounded,
                  onTap: controller.currentPage.value > 1
                      ? () => controller.setPage(1)
                      : null,
                ),
                const SizedBox(width: 6),
                _buildNavBtn(
                  context,
                  Icons.keyboard_arrow_left_rounded,
                  onTap: controller.currentPage.value > 1
                      ? () => controller.previousPage()
                      : null,
                ),
                const SizedBox(width: 6),
                ...List.generate(controller.totalPages, (index) {
                  final pageNum = index + 1;
                  final isSelected = controller.currentPage.value == pageNum;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: _buildNumBtn(
                      context,
                      '$pageNum',
                      isSelected,
                      onTap: () => controller.setPage(pageNum),
                    ),
                  );
                }),
                _buildNavBtn(
                  context,
                  Icons.keyboard_arrow_right_rounded,
                  onTap: controller.currentPage.value < controller.totalPages
                      ? () => controller.nextPage()
                      : null,
                ),
                const SizedBox(width: 6),
                _buildNavBtn(
                  context,
                  Icons.keyboard_double_arrow_right_rounded,
                  onTap: controller.currentPage.value < controller.totalPages
                      ? () => controller.setPage(controller.totalPages)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBtn(
    BuildContext context,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    final bool isEnabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 16,
            color: isEnabled
                ? const Color(0xFF475569)
                : const Color(0xFFCBD5E1),
          ),
        ),
      ),
    );
  }

  Widget _buildNumBtn(
    BuildContext context,
    String num,
    bool isSelected, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFCF4340) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            num,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}
