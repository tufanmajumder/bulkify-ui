import 'package:admin_app/utils/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/controllers/payment_controller.dart';
import 'package:admin_app/models/payment_model.dart';
import 'package:admin_app/utils/responsive.dart';
import 'package:admin_app/views/payment_details_screen.dart';
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
          const Sidebar(activeRoute: '/payments'),

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
                controller.setRowsPerPage(val);
              }
            },
            items: [2, 10, 25, 50].map((int val) {
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
        children: [
          Text(
            'Export',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: Responsive.sp(Get.context!, 15),
              fontWeight: FontWeight.w400,
              color: ColorManager.lazy,
              letterSpacing: 0,
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
                      Expanded(
                        flex: 5,
                        child: _buildHeaderCell(context, 'ORDER ID'),
                      ),
                      Expanded(
                        flex: 5,
                        child: _buildHeaderCell(context, 'PAYMENT ID'),
                      ),
                      Expanded(
                        flex: 5,
                        child: _buildHeaderCell(context, 'UTR/RRN'),
                      ),
                      Expanded(
                        flex: 5,
                        child: _buildHeaderCell(context, 'CUSTOMER'),
                      ),
                      Expanded(
                        flex: 4,
                        child: _buildHeaderCell(context, 'CREATED ON'),
                      ),
                      Expanded(
                        flex: 2,
                        child: _buildHeaderCell(context, 'STATUS'),
                      ),
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _buildHeaderCell(context, 'AMOUNT'),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _buildHeaderCell(context, 'ACTION'),
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
                    return Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              controller.errorMessage.value.isNotEmpty
                                  ? controller.errorMessage.value
                                  : 'No payment records found',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            if (controller.errorMessage.value.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => controller.fetchPayments(
                                  page: controller.currentPage.value,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFCF4340),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ],
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

  Widget _buildHeaderCell(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Responsive.sp(context, 13),
        fontWeight: FontWeight.w700,
        color: const Color(0xFF475569),
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildPaymentRow(
    BuildContext context,
    PaymentController controller,
    PaymentModel item,
  ) {
    final double fontSize = Responsive.sp(context, 14);
    final double subFontSize = Responsive.sp(context, 12.5);

    return InkWell(
      onTap: () {
        Get.to(
          () => PaymentDetailsScreen(payment: item),
          routeName: '/payment-details',
          arguments: item,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ORDER ID
            Expanded(
              flex: 5,
              child: Text(
                item.orderId,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                  color: Color(0xB32F2B3D),
                  letterSpacing: 0,
                ),
              ),
            ),

            // 2. PAYMENT ID
            Expanded(
              flex: 5,
              child: Text(
                item.paymentId,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                  color: Color(0xB32F2B3D),
                  letterSpacing: 0,
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
                      fontFamily: 'Public Sans',
                      fontSize: fontSize,
                      fontWeight: FontWeight.w400,
                      color: Color(0xB32F2B3D),
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.paymentMethod,
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: subFontSize,
                      fontWeight: FontWeight.w400,
                      color: Color(0xB32F2B3D),
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),

            // 4. CUSTOMER DETAILS (Name on top, subtext below)
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.customerName,
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: fontSize,
                      fontWeight: FontWeight.w400,
                      color: Color(0xB32F2B3D),
                      letterSpacing: 0,
                    ),
                  ),
                  // const SizedBox(height: 2),
                  // Text(
                  //   item.customerSubtext,
                  //   style: TextStyle(
                  //     fontSize: subFontSize,
                  //     fontWeight: FontWeight.w400,
                  //     color: const Color(0xFF94A3B8),
                  //   ),
                  // ),
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
                      fontFamily: 'Public Sans',
                      fontSize: fontSize,
                      fontWeight: FontWeight.w400,
                      color: Color(0xB32F2B3D),
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.time,
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: subFontSize,
                      fontWeight: FontWeight.w400,
                      color: Color(0xB32F2B3D),
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),

            // 6. STATUS
            Expanded(flex: 2, child: _buildStatusCell(context, item.status)),

            // 7. AMOUNT (Right Aligned)
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "₹ ",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      TextSpan(
                        text: item.amount.replaceAll('₹', '').trim(),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
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
                    if (val == 'View Details') {
                      Get.to(
                        () => PaymentDetailsScreen(payment: item),
                        routeName: '/payment-details',
                        arguments: item,
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'View Details',
                      child: Text('View Details'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCell(BuildContext context, String status) {
    Color color;

    switch (status.toLowerCase()) {
      case 'success':
        color = const Color(0xFF22C55E);
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
      style: TextStyle(
        fontFamily: 'Public Sans',
        fontSize: Responsive.sp(context, 14),
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0,
      ),
    );
  }

  // Pagination Footer
  Widget _buildPaginationFooter(
    BuildContext context,
    PaymentController controller,
  ) {
    return Obx(() {
      final start = controller.startEntryIndex;
      final end = controller.endEntryIndex;
      final total = controller.displayTotalCount;
      final currentPage = controller.currentPage.value;
      final totalPages = controller.computedTotalPages;
      final isLoading = controller.isLoading.value;
      final hasMorePage = controller.hasMorePage.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Entry counter display
            Text(
              'Showing $start to $end of $total entries (Page $currentPage)',
              style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),

            // Page Navigation Buttons
            Row(
              children: [
                _buildNavBtn(
                  context,
                  Icons.keyboard_double_arrow_left_rounded,
                  onTap: currentPage > 1 && !isLoading
                      ? () => controller.setPage(1)
                      : null,
                ),
                const SizedBox(width: 6),
                _buildNavBtn(
                  context,
                  Icons.keyboard_arrow_left_rounded,
                  onTap: currentPage > 1 && !isLoading
                      ? () => controller.previousPage()
                      : null,
                ),
                const SizedBox(width: 6),
                ...List.generate(totalPages > 0 ? totalPages : 1, (index) {
                  final pageNum = index + 1;
                  final isSelected = pageNum == currentPage;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: _buildNumBtn(
                      context,
                      '$pageNum',
                      isSelected,
                      onTap: isLoading || isSelected
                          ? () {}
                          : () => controller.setPage(pageNum),
                    ),
                  );
                }),
                _buildNavBtn(
                  context,
                  Icons.keyboard_arrow_right_rounded,
                  onTap: (hasMorePage || currentPage < totalPages) && !isLoading
                      ? () => controller.nextPage()
                      : null,
                ),
                const SizedBox(width: 6),
                _buildNavBtn(
                  context,
                  Icons.keyboard_double_arrow_right_rounded,
                  onTap: totalPages > currentPage && !isLoading
                      ? () => controller.setPage(totalPages)
                      : null,
                ),
              ],
            ),
          ],
        ),
      );
    });
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
