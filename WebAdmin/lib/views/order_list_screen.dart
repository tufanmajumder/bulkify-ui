import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/controllers/order_controller.dart';
import 'package:admin_app/utils/responsive.dart';
import 'widgets/header.dart';
import 'widgets/sidebar.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate GetX OrderController
    final OrderController controller = Get.put(OrderController());

    final isMobileOrTablet =
        Responsive.isMobile(context) || Responsive.isTablet(context);
    final dynamicPadding = Responsive.dynamicPadding(context);
    final spacingHeight = Responsive.h(context, 2.5).clamp(16.0, 24.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      drawer: isMobileOrTablet
          ? const Drawer(
              backgroundColor: Colors.white,
              child: Sidebar(isDrawer: true, activeRoute: '/orders'),
            )
          : null,
      body: Stack(
        children: [
          // Main Content Layout
          Padding(
            padding: EdgeInsets.only(left: isMobileOrTablet ? 0.0 : 72.0),
            child: Column(
              children: [
                // Top Navigation Header Bar
                const Header(),

                // Scrollable Body Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(dynamicPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Summary Stat Cards (4 Stats Row)
                        _buildStatSummaryRow(context, controller),
                        SizedBox(height: spacingHeight),

                        // Main Order Table Card (Filter + Table + Pagination)
                        _buildOrderTableCard(context, controller),
                        SizedBox(height: spacingHeight * 1.2),

                        // Page Footer
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
                                  TextSpan(text: '© Devolved by '),
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

          // Left Sidebar Overlay (Desktop View)
          if (!isMobileOrTablet)
            const Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Sidebar(activeRoute: '/orders'),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // TOP STAT SUMMARY CARDS (MATCHING IMAGE)
  // ==========================================

  Widget _buildStatSummaryRow(
    BuildContext context,
    OrderController controller,
  ) {
    final borderColor = const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 750;

          if (isNarrow) {
            return Column(
              children: [
                _buildStatItem(
                  context,
                  icon: Icons.done_all_rounded,
                  iconBg: const Color(0xFFD1FAE5),
                  iconColor: const Color(0xFF10B981),
                  count: controller.completedCount.value,
                  label: 'Completed',
                ),
                const Divider(height: 24),
                _buildStatItem(
                  context,
                  icon: Icons.calendar_month_outlined,
                  iconBg: const Color(0xFFFFF0E6),
                  iconColor: const Color(0xFFF97316),
                  count: controller.pendingPaymentCount.value,
                  label: 'Pending Payment',
                ),
                const Divider(height: 24),
                _buildStatItem(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  iconBg: const Color(0xFFEDE9FE),
                  iconColor: const Color(0xFF8B5CF6),
                  count: controller.refundedCount.value,
                  label: 'Refunded',
                ),
                const Divider(height: 24),
                _buildStatItem(
                  context,
                  icon: Icons.error_outline_rounded,
                  iconBg: const Color(0xFFFEE2E2),
                  iconColor: const Color(0xFFEF4444),
                  count: controller.failedCount.value,
                  label: 'Failed',
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.done_all_rounded,
                  iconBg: const Color(0xFFD1FAE5),
                  iconColor: const Color(0xFF10B981),
                  count: controller.completedCount.value,
                  label: 'Completed',
                ),
              ),
              _buildVerticalDivider(),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.calendar_month_outlined,
                  iconBg: const Color(0xFFFFF0E6),
                  iconColor: const Color(0xFFF97316),
                  count: controller.pendingPaymentCount.value,
                  label: 'Pending Payment',
                ),
              ),
              _buildVerticalDivider(),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  iconBg: const Color(0xFFEDE9FE),
                  iconColor: const Color(0xFF8B5CF6),
                  count: controller.refundedCount.value,
                  label: 'Refunded',
                ),
              ),
              _buildVerticalDivider(),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.error_outline_rounded,
                  iconBg: const Color(0xFFFEE2E2),
                  iconColor: const Color(0xFFEF4444),
                  count: controller.failedCount.value,
                  label: 'Failed',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String count,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Icon(icon, color: iconColor, size: 22)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: Responsive.sp(context, 18),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: Responsive.sp(context, 12),
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

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFFE2E8F0),
    );
  }

  // ==========================================
  // ORDER TABLE CARD (MATCHING IMAGE)
  // ==========================================

  Widget _buildOrderTableCard(
    BuildContext context,
    OrderController controller,
  ) {
    final fontSize = Responsive.sp(context, 13);
    final borderColor = const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Row: Rows per Page + Search Order Input
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Rows Per Page Dropdown Button
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
                          const SizedBox(width: 8),
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

                // Search Order Input Field + Export Button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 38,
                      width: 220,
                      child: TextField(
                        onChanged: (val) => controller.setSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: 'Search Order',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF94A3B8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 14,
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
                    ElevatedButton.icon(
                      onPressed: () => controller.exportOrders(),
                      icon: const Icon(
                        Icons.download_outlined,
                        size: 18,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
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

          // Scrollable Table Data Area
          LayoutBuilder(
            builder: (context, constraints) {
              final double minTableWidth = 900.0;
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
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          border: Border(
                            top: BorderSide(color: borderColor),
                            bottom: BorderSide(color: borderColor),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildHeaderCell(
                                context,
                                'ORDER NO.',
                                true,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: _buildHeaderCell(
                                context,
                                'DATE & TIME',
                                true,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: _buildHeaderCell(
                                context,
                                'CUSTOMER',
                                true,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _buildHeaderCell(
                                context,
                                'AMOUNT (₹)',
                                true,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _buildHeaderCell(context, 'PAYMENT', true),
                            ),
                            Expanded(
                              flex: 2,
                              child: _buildHeaderCell(
                                context,
                                'SHIPMENT',
                                true,
                              ),
                            ),

                            Expanded(
                              flex: 1,
                              child: _buildHeaderCell(
                                context,
                                'ACTION',
                                false,
                                alignment: Alignment.centerRight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Table Data Rows (Obx)
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

                        final paginated = controller.paginatedOrders;

                        if (paginated.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(
                              child: Text(
                                'No orders found',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: paginated.map((order) {
                            final displayDate =
                                (order.date.isEmpty || order.date == 'null')
                                ? '-'
                                : order.date;
                            final displayCustomer =
                                (order.customerName.isEmpty ||
                                    order.customerName == 'null')
                                ? '-'
                                : order.customerName;
                            final displayCompany =
                                (order.companyName.isEmpty ||
                                    order.companyName == 'null' ||
                                    order.companyName == '-' ||
                                    order.companyName.trim().toLowerCase() ==
                                        displayCustomer.trim().toLowerCase())
                                ? ''
                                : order.companyName;

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
                                  // ORDER ID (Red bold)
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      order.id,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFCF4340),
                                      ),
                                    ),
                                  ),

                                  // DATE & TIME
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      displayDate,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        color: const Color(0xFF475569),
                                      ),
                                    ),
                                  ),

                                  // CUSTOMER (Customer Name & Company Name underneath)
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          displayCustomer,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: fontSize,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                        if (displayCompany.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            displayCompany,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: fontSize - 2,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // AMOUNT
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      order.amount,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF475569),
                                      ),
                                    ),
                                  ),

                                  // PAYMENT STATUS (text)
                                  Expanded(
                                    flex: 2,
                                    child: _buildPaymentStatusCell(
                                      context,
                                      order.paymentStatus,
                                    ),
                                  ),

                                  // ORDER STATUS
                                  Expanded(
                                    flex: 2,
                                    child: _buildOrderStatusBadge(
                                      context,
                                      order.orderStatus,
                                    ),
                                  ),

                                  // ACTION Menu
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: PopupMenuButton<String>(
                                        icon: const Icon(
                                          Icons.more_vert_rounded,
                                          size: 18,
                                          color: Color(0xFF64748B),
                                        ),
                                        onSelected: (val) {
                                          controller.viewOrderDetails(order);
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'view',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.visibility_outlined,
                                                  size: 16,
                                                  color: Color(0xFF475569),
                                                ),
                                                SizedBox(width: 8),
                                                Text('View Details'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
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

          // Pagination Footer (Matching Image)
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Entry Counter
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
                              ' of ${controller.filteredOrders.length} entries',
                        ),
                      ],
                    ),
                  ),

                  // Page Buttons (<<, <, 1, 2, ..., >, >>)
                  Row(
                    children: [
                      _buildPageNavBtn(
                        context,
                        Icons.keyboard_double_arrow_left_rounded,
                        onTap: controller.currentPage.value > 1
                            ? () => controller.goToFirstPage()
                            : null,
                      ),
                      const SizedBox(width: 6),
                      _buildPageNavBtn(
                        context,
                        Icons.keyboard_arrow_left_rounded,
                        onTap: controller.currentPage.value > 1
                            ? () => controller.previousPage()
                            : null,
                      ),
                      const SizedBox(width: 6),
                      ...controller.visiblePageNumbers.map((pageNum) {
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
                        onTap: controller.hasMorePage.value
                            ? () => controller.nextPage()
                            : null,
                      ),
                      const SizedBox(width: 6),
                      _buildPageNavBtn(
                        context,
                        Icons.keyboard_double_arrow_right_rounded,
                        onTap: controller.hasMorePage.value
                            ? () => controller.nextPage()
                            : null,
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

  // Payment Status Bullet Cell
  Widget _buildPaymentStatusCell(BuildContext context, String status) {
    final isPending = status.toLowerCase() == 'pending';
    final color = isPending ? const Color(0xFFF97316) : const Color(0xFF10B981);

    return Text(
      status,
      textAlign: TextAlign.start,
      style: TextStyle(
        fontSize: Responsive.sp(context, 13),
        fontWeight: FontWeight.w400,
        color: color,
      ),
    );
  }

  // Order Status Badge Cell
  Widget _buildOrderStatusBadge(BuildContext context, String status) {
    Color text;

    switch (status.toLowerCase()) {
      case 'delivered':
        text = const Color(0xFF059669);
        break;
      case 'dispatched':
        text = const Color(0xFFD97706);
        break;
      case 'out for delivery':
        text = const Color(0xFF7C3AED);
        break;
      case 'ready to pickup':
        text = const Color(0xFF0891B2);
        break;
      case 'cancelled':
      case 'failed':
        text = const Color(0xFFDC2626);
        break;
      default:
        text = const Color(0xFF475569);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        status,
        style: TextStyle(
          fontSize: Responsive.sp(context, 13),
          fontWeight: FontWeight.w500,
          color: text,
        ),
      ),
    );
  }

  Widget _buildHeaderCell(
    BuildContext context,
    String text,
    bool hasDivider, {
    Alignment alignment = Alignment.centerLeft,
  }) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: alignment,
            child: Text(
              text,
              textAlign: alignment == Alignment.centerRight
                  ? TextAlign.end
                  : TextAlign.start,
              style: TextStyle(
                fontSize: Responsive.sp(context, 12),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
        // if (hasDivider)
        //   Container(
        //     height: 14,
        //     width: 1,
        //     margin: const EdgeInsets.symmetric(horizontal: 10),
        //     color: const Color(0xFFCBD5E1),
        //   ),
      ],
    );
  }

  Widget _buildPageNavBtn(
    BuildContext context,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    final bool isEnabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: isEnabled
                ? const Color(0xFF475569)
                : const Color(0xFFCBD5E1),
          ),
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
