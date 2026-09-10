import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/controllers/order_details_controller.dart';
import 'package:admin_app/utils/responsive.dart';
import 'widgets/header.dart';
import 'widgets/sidebar.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderDetailsController controller = Get.put(OrderDetailsController());

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
          // Main Scrollable Area
          Padding(
            padding: EdgeInsets.only(left: isMobileOrTablet ? 0.0 : 72.0),
            child: Column(
              children: [
                // Navigation Header Bar
                const Header(),

                // Main Content
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.orderNo.value.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFCF4340),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(dynamicPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Responsive 2-Column Grid (Left: Sidebar details, Right: Main tables)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final bool isDesktopView =
                                  constraints.maxWidth >= 1024;
                              if (!isDesktopView) {
                                return Column(
                                  children: [
                                    _buildLeftSection(
                                      context,
                                      controller,
                                      spacingHeight,
                                    ),
                                    SizedBox(height: spacingHeight),
                                    _buildRightSection(
                                      context,
                                      controller,
                                      spacingHeight,
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Column (Order Details, Shipping/Billing, Price, Docs)
                                  SizedBox(
                                    width: 360,
                                    child: _buildLeftSection(
                                      context,
                                      controller,
                                      spacingHeight,
                                    ),
                                  ),
                                  SizedBox(width: spacingHeight),
                                  // Right Column (Payments, Order Items, Shipping Activity)
                                  Expanded(
                                    child: _buildRightSection(
                                      context,
                                      controller,
                                      spacingHeight,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Permanent Desktop Sidebar Overlay
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

  // ===========================================================================
  // LEFT COLUMN SECTION
  // ===========================================================================
  Widget _buildLeftSection(
    BuildContext context,
    OrderDetailsController controller,
    double spacingHeight,
  ) {
    return Column(
      children: [
        _buildOrderDetailsCard(context, controller),
        SizedBox(height: spacingHeight),
        _buildShippingAndBillingAddressCard(context, controller),
        SizedBox(height: spacingHeight),
        _buildPriceDetailsCard(context, controller),
        SizedBox(height: spacingHeight),
        _buildDocumentsCard(context, controller),
      ],
    );
  }

  // 1. Order Details Card
  Widget _buildOrderDetailsCard(
    BuildContext context,
    OrderDetailsController controller,
  ) {
    final borderColor = const Color(0xFFE2E8F0);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE5E5E6),
            blurRadius: 6.0,
            spreadRadius: 2.2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Details',
            style: TextStyle(
              fontFamily: 'Public-Sans',
              fontSize: Responsive.sp(context, 15),
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          // Obx(
          //   () =>
          Column(
            children: [
              _buildKeyValueRow(
                'Order No',
                controller.orderNo.value,
                isBoldValue: true,
              ),
              const SizedBox(height: 10),
              DottedLine(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                lineLength: double.infinity,
                lineThickness: 1.0,
                dashLength: 4.0,
                dashColor: Colors.grey.shade300,
                dashGapLength: 2.0,
                dashGapColor: Colors.transparent,
              ),
              const SizedBox(height: 10),
              _buildKeyValueRow(
                'Date',
                controller.date.value,
                isBoldValue: true,
              ),
              const SizedBox(height: 10),
              DottedLine(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                lineLength: double.infinity,
                lineThickness: 1.0,
                dashLength: 4.0,
                dashColor: Colors.grey.shade300,
                dashGapLength: 2.0,
                dashGapColor: Colors.transparent,
              ),
              const SizedBox(height: 10),
              _buildKeyValueRow(
                'Time',
                controller.time.value,
                isBoldValue: true,
              ),
              const SizedBox(height: 10),
              DottedLine(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                lineLength: double.infinity,
                lineThickness: 1.0,
                dashLength: 4.0,
                dashColor: Colors.grey.shade300,
                dashGapLength: 2.0,
                dashGapColor: Colors.transparent,
              ),
              const SizedBox(height: 10),
              _buildKeyValueRow(
                'Customer',
                controller.customer.value,
                isBoldValue: false,
              ),
              const SizedBox(height: 10),
              DottedLine(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                lineLength: double.infinity,
                lineThickness: 1.0,
                dashLength: 4.0,
                dashColor: Colors.grey.shade300,
                dashGapLength: 2.0,
                dashGapColor: Colors.transparent,
              ),
              const SizedBox(height: 10),
              _buildKeyValueRow(
                'Company',
                controller.company.value,
                isBoldValue: true,
              ),
              const SizedBox(height: 10),
              DottedLine(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                lineLength: double.infinity,
                lineThickness: 1.0,
                dashLength: 4.0,
                dashColor: Colors.grey.shade300,
                dashGapLength: 2.0,
                dashGapColor: Colors.transparent,
              ),
              const SizedBox(height: 10),
              _buildKeyValueRow(
                'Payment',
                controller.paymentMethod.value,
                customValueWidget: Text(
                  (controller.paymentMethod.value.trim().isEmpty ||
                          controller.paymentMethod.value.trim() == 'null' ||
                          controller.paymentMethod.value.trim() == '-')
                      ? '-'
                      : controller.paymentMethod.value[0].toUpperCase() +
                            controller.paymentMethod.value.substring(1),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              DottedLine(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                lineLength: double.infinity,
                lineThickness: 1.0,
                dashLength: 4.0,
                dashColor: Colors.grey.shade300,
                dashGapLength: 2.0,
                dashGapColor: Colors.transparent,
              ),
              const SizedBox(height: 10),
              _buildKeyValueRow(
                'Shipment',
                controller.shipmentStatus.value,
                customValueWidget: Text(
                  (controller.shipmentStatus.value.trim().isEmpty ||
                          controller.shipmentStatus.value.trim() == 'null' ||
                          controller.shipmentStatus.value.trim() == '-')
                      ? '-'
                      : controller.shipmentStatus.value[0].toUpperCase() +
                            controller.shipmentStatus.value.substring(1),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF97316),
                  ),
                ),
              ),
            ],
          ),
          //),
        ],
      ),
    );
  }

  // 2. Shipping & Billing Address Card
  Widget _buildShippingAndBillingAddressCard(
    BuildContext context,
    OrderDetailsController controller,
  ) {
    final borderColor = const Color(0xFFE2E8F0);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE5E5E6),
            blurRadius: 6.0,
            spreadRadius: 2.2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Shipping Address ---
            Text(
              'Shipping Address',
              style: TextStyle(
                fontFamily: 'Public-Sans',
                fontSize: Responsive.sp(context, 15),
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              (controller.shippingName.value.trim().isEmpty ||
                      controller.shippingName.value.trim() == 'null')
                  ? '-'
                  : controller.shippingName.value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (controller.shippingPhone.value.trim().isEmpty ||
                      controller.shippingPhone.value.trim() == 'null')
                  ? '-'
                  : controller.shippingPhone.value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (controller.shippingAddress.value.trim().isEmpty ||
                      controller.shippingAddress.value.trim() == 'null')
                  ? '-'
                  : controller.shippingAddress.value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1E293B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1E293B),
                ),
                children: [
                  const TextSpan(text: 'Pincode: '),
                  TextSpan(
                    text:
                        (controller.shippingPincode.value.trim().isEmpty ||
                            controller.shippingPincode.value.trim() == 'null')
                        ? '-'
                        : controller.shippingPincode.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            DottedLine(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              lineLength: double.infinity,
              lineThickness: 1.0,
              dashLength: 4.0,
              dashColor: Colors.grey.shade300,
              dashGapLength: 2.0,
              dashGapColor: Colors.transparent,
            ),
            const SizedBox(height: 16),

            // --- Billing Address ---
            Text(
              'Billing Address',
              style: TextStyle(
                fontFamily: 'Public-Sans',
                fontSize: Responsive.sp(context, 15),
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              (controller.billingName.value.trim().isEmpty ||
                      controller.billingName.value.trim() == 'null')
                  ? '-'
                  : controller.billingName.value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (controller.billingPhone.value.trim().isEmpty ||
                      controller.billingPhone.value.trim() == 'null')
                  ? '-'
                  : controller.billingPhone.value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (controller.billingAddress.value.trim().isEmpty ||
                      controller.billingAddress.value.trim() == 'null')
                  ? '-'
                  : controller.billingAddress.value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                ),
                children: [
                  const TextSpan(text: 'Pincode: '),
                  TextSpan(
                    text:
                        (controller.billingPincode.value.trim().isEmpty ||
                            controller.billingPincode.value.trim() == 'null')
                        ? '-'
                        : controller.billingPincode.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Price Details Card
  Widget _buildPriceDetailsCard(
    BuildContext context,
    OrderDetailsController controller,
  ) {
    final borderColor = const Color(0xFFE2E8F0);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE5E5E6),
            blurRadius: 6.0,
            spreadRadius: 2.2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Details',
            style: TextStyle(
              fontFamily: 'Public-Sans',
              fontSize: Responsive.sp(context, 15),
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              children: [
                _buildKeyValueRow(
                  'Subtotal',
                  controller.subtotal.value,
                  isBoldValue: false,
                ),
                const SizedBox(height: 10),
                DottedLine(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  lineLength: double.infinity,
                  lineThickness: 1.0,
                  dashLength: 4.0,
                  dashColor: Colors.grey.shade300,
                  dashGapLength: 2.0,
                  dashGapColor: Colors.transparent,
                ),
                const SizedBox(height: 10),
                _buildKeyValueRow(
                  'Shipping Fee',
                  controller.shippingFee.value,
                  isBoldValue: false,
                ),
                const SizedBox(height: 10),
                DottedLine(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  lineLength: double.infinity,
                  lineThickness: 1.0,
                  dashLength: 4.0,
                  dashColor: Colors.grey.shade300,
                  dashGapLength: 2.0,
                  dashGapColor: Colors.transparent,
                ),
                const SizedBox(height: 10),
                _buildKeyValueRow(
                  'Platform Fee',
                  controller.platformFee.value,
                  isBoldValue: false,
                ),
                const SizedBox(height: 10),
                DottedLine(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  lineLength: double.infinity,
                  lineThickness: 1.0,
                  dashLength: 4.0,
                  dashColor: Colors.grey.shade300,
                  dashGapLength: 2.0,
                  dashGapColor: Colors.transparent,
                ),
                const SizedBox(height: 10),
                _buildKeyValueRow(
                  'Bank Fee',
                  controller.bankFee.value,
                  isBoldValue: false,
                ),
                const SizedBox(height: 10),
                DottedLine(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  lineLength: double.infinity,
                  lineThickness: 1.0,
                  dashLength: 4.0,
                  dashColor: Colors.grey.shade300,
                  dashGapLength: 2.0,
                  dashGapColor: Colors.transparent,
                ),
                const SizedBox(height: 10),
                _buildKeyValueRow(
                  'Discount 10%',
                  controller.discountPercent.value,
                  isBoldValue: false,
                ),
                const SizedBox(height: 10),
                DottedLine(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  lineLength: double.infinity,
                  lineThickness: 1.0,
                  dashLength: 4.0,
                  dashColor: Colors.grey.shade300,
                  dashGapLength: 2.0,
                  dashGapColor: Colors.transparent,
                ),
                const SizedBox(height: 10),
                _buildKeyValueRow(
                  'Coupon #WELCOME10',
                  controller.couponDiscount.value,
                  isBoldValue: true,
                ),
                const SizedBox(height: 10),
                DottedLine(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  lineLength: double.infinity,
                  lineThickness: 1.0,
                  dashLength: 4.0,
                  dashColor: Colors.grey.shade300,
                  dashGapLength: 2.0,
                  dashGapColor: Colors.transparent,
                ),
                const SizedBox(height: 10),
                _buildKeyValueRow(
                  'Tax',
                  controller.tax.value,
                  isBoldValue: false,
                ),
                const SizedBox(height: 10),
                DottedLine(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  lineLength: double.infinity,
                  lineThickness: 1.0,
                  dashLength: 4.0,
                  dashColor: Colors.grey.shade300,
                  dashGapLength: 2.0,
                  dashGapColor: Colors.transparent,
                ),
                const SizedBox(height: 10),
                _buildKeyValueRow(
                  'CGST',
                  controller.cgst.value,
                  isBoldValue: false,
                ),
                const SizedBox(height: 10),
                DottedLine(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  lineLength: double.infinity,
                  lineThickness: 1.0,
                  dashLength: 4.0,
                  dashColor: Colors.grey.shade300,
                  dashGapLength: 2.0,
                  dashGapColor: Colors.transparent,
                ),
                const SizedBox(height: 10),
                _buildKeyValueRow(
                  'SGST',
                  controller.sgst.value,
                  isBoldValue: false,
                ),
                const SizedBox(height: 10),
                DottedLine(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  lineLength: double.infinity,
                  lineThickness: 1.0,
                  dashLength: 4.0,
                  dashColor: Colors.grey.shade300,
                  dashGapLength: 2.0,
                  dashGapColor: Colors.transparent,
                ),
                const SizedBox(height: 10),
                _buildKeyValueRow(
                  'Total:',
                  controller.grandTotal.value,
                  isBoldLabel: false,
                  isBoldValue: true,
                  valueFontSize: 15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. Documents Card
  Widget _buildDocumentsCard(
    BuildContext context,
    OrderDetailsController controller,
  ) {
    final borderColor = const Color(0xFFE2E8F0);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE5E5E6),
            blurRadius: 6.0,
            spreadRadius: 2.2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documents',
            style: TextStyle(
              fontFamily: 'Public-Sans',
              fontSize: Responsive.sp(context, 15),
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final List<Widget> docRows = [];
            final standardTypes = [
              'Invoice',
              'Way Bill',
              'Credit Note',
              'Debit Note',
              'Delivery Challan',
              'Quotation',
            ];

            final processedTitles = <String>{};

            for (int i = 0; i < standardTypes.length; i++) {
              final typeTitle = standardTypes[i];
              processedTitles.add(typeTitle.toLowerCase().replaceAll(' ', ''));

              DocumentModel? matchedDoc;
              for (final doc in controller.documents) {
                final normTitle = doc.title.toLowerCase().replaceAll(' ', '');
                if (normTitle == typeTitle.toLowerCase().replaceAll(' ', '')) {
                  matchedDoc = doc;
                  break;
                }
              }

              final docToUse = matchedDoc;
              final hasFile =
                  docToUse != null &&
                  docToUse.code.trim().isNotEmpty &&
                  docToUse.code.trim() != 'null' &&
                  docToUse.code.trim() != '-';

              if (i > 0) {
                docRows.add(const SizedBox(height: 10));
                docRows.add(
                  DottedLine(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.center,
                    lineLength: double.infinity,
                    lineThickness: 1.0,
                    dashLength: 4.0,
                    dashColor: Colors.grey.shade300,
                    dashGapLength: 2.0,
                    dashGapColor: Colors.transparent,
                  ),
                );
                docRows.add(const SizedBox(height: 10));
              }

              docRows.add(
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      typeTitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    hasFile
                        ? InkWell(
                            onTap: () => controller.downloadDocument(docToUse),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.download_outlined,
                                    size: 14,
                                    color: Color(0xFF1E293B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    docToUse.code,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const Text(
                            '-',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                  ],
                ),
              );
            }

            // Append any additional documents from controller.documents not in standard types
            for (final doc in controller.documents) {
              final normTitle = doc.title.toLowerCase().replaceAll(' ', '');
              if (!processedTitles.contains(normTitle)) {
                final hasFile =
                    doc.code.trim().isNotEmpty &&
                    doc.code.trim() != 'null' &&
                    doc.code.trim() != '-';

                docRows.add(const SizedBox(height: 10));
                docRows.add(
                  DottedLine(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.center,
                    lineLength: double.infinity,
                    lineThickness: 1.0,
                    dashLength: 4.0,
                    dashColor: Colors.grey.shade300,
                    dashGapLength: 2.0,
                    dashGapColor: Colors.transparent,
                  ),
                );
                docRows.add(const SizedBox(height: 10));

                docRows.add(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        doc.title,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      hasFile
                          ? InkWell(
                              onTap: () => controller.downloadDocument(doc),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.download_outlined,
                                      size: 14,
                                      color: Color(0xFF1E293B),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      doc.code,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const Text(
                              '-',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                    ],
                  ),
                );
              }
            }

            return Column(children: docRows);
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // RIGHT COLUMN SECTION
  // ===========================================================================
  Widget _buildRightSection(
    BuildContext context,
    OrderDetailsController controller,
    double spacingHeight,
  ) {
    return Column(
      children: [
        _buildPaymentsTransactionsCard(context, controller),
        SizedBox(height: spacingHeight),
        _buildOrderItemsCard(context, controller),
        SizedBox(height: spacingHeight),
        _buildShippingActivityCard(context, controller),
      ],
    );
  }

  // 1. Payments Transactions Card
  Widget _buildPaymentsTransactionsCard(
    BuildContext context,
    OrderDetailsController controller,
  ) {
    final borderColor = const Color(0xFFE2E8F0);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE5E5E6),
            blurRadius: 6.0,
            spreadRadius: 2.2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Payments Transactions',
              style: TextStyle(
                fontFamily: 'Public-Sans',
                fontSize: Responsive.sp(context, 15),
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade300),
          LayoutBuilder(
            builder: (context, constraints) {
              final double tableWidth = constraints.maxWidth < 800
                  ? 800.0
                  : constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        color: Colors.white,
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'ISSUED BY',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475569),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'CREATED ON',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475569),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'PAYMENT ID',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475569),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'RRN/UTR',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475569),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'STATUS',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475569),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'AMOUNT',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475569),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'RECEIPT',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475569),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey.shade300),
                      // Table Rows
                      Obx(
                        () => controller.transactions.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("No Transaction found!"),
                                ),
                              )
                            : Column(
                                children: controller.transactions.map((tx) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            tx.issuedBy,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            (tx.createdOn.trim().isEmpty ||
                                                    tx.createdOn.trim() ==
                                                        'null')
                                                ? '-'
                                                : controller.formatDateOnly(
                                                    tx.createdOn,
                                                  ),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF64748B),
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tx.paymentId,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                tx.paymentMethod,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            tx.rrnUtr,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFECFDF5),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                tx.status,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF10B981),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: _buildRupeeText(
                                            tx.amount,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Center(
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.download_outlined,
                                                size: 18,
                                                color: Color(0xFF64748B),
                                              ),
                                              onPressed: () => controller
                                                  .downloadReceipt(tx),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 2. Order Items Card
  Widget _buildOrderItemsCard(
    BuildContext context,
    OrderDetailsController controller,
  ) {
    final borderColor = const Color(0xFFE2E8F0);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE5E5E6),
            blurRadius: 6.0,
            spreadRadius: 2.2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Order Items',
              style: TextStyle(
                fontFamily: 'Public-Sans',
                fontSize: Responsive.sp(context, 15),
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade300),

          LayoutBuilder(
            builder: (context, constraints) {
              final double tableWidth = constraints.maxWidth < 700
                  ? 700.0
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
                        color: Colors.white,
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Text(
                                'PRODUCT',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'PRICE',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'QTY',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'TOTAL',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey.shade300),
                      // Product Rows
                      Obx(
                        () => controller.orderItems.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("No orders found!"),
                                ),
                              )
                            : Column(
                                children: controller.orderItems.map((item) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (item.name.trim().isEmpty ||
                                                        item.name.trim() ==
                                                            'null')
                                                    ? '-'
                                                    : item.name,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                              if (item.description
                                                      .trim()
                                                      .isNotEmpty &&
                                                  item.description.trim() !=
                                                      'null' &&
                                                  item.description.trim() !=
                                                      '-') ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  item.description,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF94A3B8),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: _buildRupeeText(
                                            item.price,
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '${item.qty}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: _buildRupeeText(
                                              item.total.contains('₹')
                                                  ? item.total
                                                  : '₹ ${item.total}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 3. Shipping Activity Card
  Widget _buildShippingActivityCard(
    BuildContext context,
    OrderDetailsController controller,
  ) {
    final borderColor = const Color(0xFFE2E8F0);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE5E5E6),
            blurRadius: 6.0,
            spreadRadius: 2.2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Activity',
            style: TextStyle(
              fontFamily: 'Public-Sans',
              fontSize: Responsive.sp(context, 15),
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Obx(
            () => controller.shippingActivities.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("No shipping activity found!"),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.shippingActivities.length,
                    itemBuilder: (context, index) {
                      final activity = controller.shippingActivities[index];
                      final isLast =
                          index == controller.shippingActivities.length - 1;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timeline dot and connecting vertical line
                          Column(
                            children: [
                              const SizedBox(height: 3),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: activity.isCompleted
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 48,
                                  color: const Color(0xFFE2E8F0),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          // Activity Title, Timestamp, Description
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                            children: [
                                              TextSpan(text: activity.title),
                                              if (activity.highlightText !=
                                                  null) ...[
                                                const TextSpan(text: ' '),
                                                TextSpan(
                                                  text: activity.highlightText!,
                                                  style: const TextStyle(
                                                    color: Color(0xFFCF4340),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        activity.timestamp,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    activity.description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRupeeText(
    String text, {
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
  }) {
    if (!text.contains('₹')) {
      return Text(text, style: style, textAlign: textAlign);
    }

    final baseStyle = style ?? const TextStyle();
    final List<InlineSpan> spans = [];
    final parts = text.split('₹');

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i]));
      }
      if (i < parts.length - 1) {
        spans.add(
          TextSpan(
            text: '₹',
            style: baseStyle.copyWith(fontFamily: 'Inter'),
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(style: baseStyle, children: spans),
      textAlign: textAlign,
    );
  }

  Widget _buildKeyValueRow(
    String label,
    String value, {
    bool isBoldLabel = false,
    bool isBoldValue = false,
    double valueFontSize = 13,
    Widget? customValueWidget,
  }) {
    final cleanValue = value.trim();
    final displayValue = (cleanValue.isEmpty || cleanValue == 'null')
        ? '-'
        : value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Public-Sans',
            fontSize: isBoldLabel ? 14 : 13,
            fontWeight: isBoldLabel ? FontWeight.bold : FontWeight.w400,
            color: isBoldLabel
                ? const Color(0xFF1E293B)
                : const Color(0xFF64748B),
          ),
        ),
        customValueWidget ??
            _buildRupeeText(
              displayValue,
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: (isBoldValue && label == "Total:")
                    ? FontWeight.w800
                    : (isBoldValue && label != "Total:")
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: const Color(0xFF1E293B),
              ),
            ),
      ],
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;
  final double dashLength;
  final double dashGap;
  final double strokeWidth;

  DottedLinePainter({
    this.color = Colors.black,
    this.dashLength = 5.0,
    this.dashGap = 3.0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      // Draw a single dash segment
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashLength, size.height / 2),
        paint,
      );
      // Move forward by the length of the dash + the gap space
      startX += dashLength + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
