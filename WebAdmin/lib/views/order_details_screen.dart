import 'dart:typed_data';
import 'package:admin_app/utils/color_manager.dart';
import 'package:admin_app/utils/receipt_picker.dart';
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
                //const Header(),

                // Top Action Bar with Go Back (Fixed / Non-scrolling)
                Container(
                  width: double.infinity,
                  color: const Color(0xFFF6F7FB),
                  padding: EdgeInsets.fromLTRB(
                    dynamicPadding,
                    14,
                    dynamicPadding,
                    12,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildGoBackButton(context),
                  ),
                ),

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

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: dynamicPadding),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final bool isDesktopView =
                              constraints.maxWidth >= 1024;
                          if (!isDesktopView) {
                            return ScrollConfiguration(
                              behavior: ScrollConfiguration.of(
                                context,
                              ).copyWith(scrollbars: false),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ScrollbarTheme(
                                      data: ScrollbarThemeData(
                                        thickness: WidgetStateProperty.all(3),
                                      ),
                                      child: Scrollbar(
                                        controller:
                                            controller.leftScrollController,
                                        thumbVisibility: true,
                                        thickness: 3,
                                        radius: const Radius.circular(4),
                                        child: SingleChildScrollView(
                                          controller:
                                              controller.leftScrollController,
                                          padding: EdgeInsets.only(
                                            right: 6,
                                            bottom: spacingHeight,
                                          ),
                                          child: _buildLeftSection(
                                            context,
                                            controller,
                                            spacingHeight,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: spacingHeight),
                                  Expanded(
                                    child: ScrollbarTheme(
                                      data: ScrollbarThemeData(
                                        thickness: WidgetStateProperty.all(3),
                                      ),
                                      child: Scrollbar(
                                        controller:
                                            controller.rightScrollController,
                                        thumbVisibility: true,
                                        thickness: 3,
                                        radius: const Radius.circular(4),
                                        child: SingleChildScrollView(
                                          controller:
                                              controller.rightScrollController,
                                          padding: EdgeInsets.only(
                                            right: 6,
                                            bottom: dynamicPadding,
                                          ),
                                          child: _buildRightSection(
                                            context,
                                            controller,
                                            spacingHeight,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ScrollConfiguration(
                            behavior: ScrollConfiguration.of(
                              context,
                            ).copyWith(scrollbars: false),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column (Order Details, Shipping/Billing, Price, Docs)
                                SizedBox(
                                  width: 360,
                                  height: double.infinity,
                                  child: ScrollbarTheme(
                                    data: ScrollbarThemeData(
                                      thickness: WidgetStateProperty.all(3),
                                    ),
                                    child: Scrollbar(
                                      controller:
                                          controller.leftScrollController,
                                      thumbVisibility: true,
                                      thickness: 3,
                                      radius: const Radius.circular(4),
                                      child: SingleChildScrollView(
                                        controller:
                                            controller.leftScrollController,
                                        padding: EdgeInsets.only(
                                          right: 6,
                                          bottom: dynamicPadding,
                                        ),
                                        child: _buildLeftSection(
                                          context,
                                          controller,
                                          spacingHeight,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: spacingHeight),
                                // Right Column (Payments, Order Items, Shipping Activity)
                                Expanded(
                                  child: SizedBox(
                                    height: double.infinity,
                                    child: ScrollbarTheme(
                                      data: ScrollbarThemeData(
                                        thickness: WidgetStateProperty.all(3),
                                      ),
                                      child: Scrollbar(
                                        controller:
                                            controller.rightScrollController,
                                        thumbVisibility: true,
                                        thickness: 3,
                                        radius: const Radius.circular(4),
                                        child: SingleChildScrollView(
                                          controller:
                                              controller.rightScrollController,
                                          padding: EdgeInsets.only(
                                            right: 6,
                                            bottom: dynamicPadding,
                                          ),
                                          child: _buildRightSection(
                                            context,
                                            controller,
                                            spacingHeight,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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

  Widget _buildGoBackButton(BuildContext context) {
    return InkWell(
      onTap: () => Get.back(),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chevron_left_rounded,
              color: ColorManager.cherryApple,
              size: 22,
            ),
            const SizedBox(width: 2),
            Text(
              'Go Back',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: Responsive.sp(context, 12),
                fontWeight: FontWeight.w600,
                color: const Color(0xFFCF4340),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewPaymentButton(
    BuildContext context,
    OrderDetailsController controller,
  ) {
    return InkWell(
      onTap: () => _showAddPaymentDrawer(context, controller),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFCF4340),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              'Add Payment',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: Responsive.sp(context, 11),
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptAllButton(
    BuildContext context,
    OrderDetailsController controller,
  ) {
    return InkWell(
      onTap: () => controller.acceptAllItems(),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFCF4340),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.check_rounded, color: Colors.white, size: 15),
            const SizedBox(width: 6),
            Text(
              'Accept All',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: Responsive.sp(context, 11),
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentDrawer(
    BuildContext context,
    OrderDetailsController controller,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Add Payment Drawer',
      barrierColor: const Color(0x73000000),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
        ).value;
        return Transform.translate(
          offset: Offset((1.0 - curvedValue) * 380, 0),
          child: AddPaymentDrawer(controller: controller),
        );
      },
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
                controller.extractDateOnly(controller.date.value),
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
                controller.extractTimeOnly(controller.time.value),
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
            'Invoice Summary',
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
                //const SizedBox(height: 10),
                // DottedLine(
                //   direction: Axis.horizontal,
                //   alignment: WrapAlignment.center,
                //   lineLength: double.infinity,
                //   lineThickness: 1.0,
                //   dashLength: 4.0,
                //   dashColor: Colors.grey.shade300,
                //   dashGapLength: 2.0,
                //   dashGapColor: Colors.transparent,
                // ),
                // const SizedBox(height: 10),
                // _buildKeyValueRow(
                //   'Shipping Fee',
                //   controller.shippingFee.value,
                //   isBoldValue: false,
                // ),
                //const SizedBox(height: 10),
                // DottedLine(
                //   direction: Axis.horizontal,
                //   alignment: WrapAlignment.center,
                //   lineLength: double.infinity,
                //   lineThickness: 1.0,
                //   dashLength: 4.0,
                //   dashColor: Colors.grey.shade300,
                //   dashGapLength: 2.0,
                //   dashGapColor: Colors.transparent,
                // ),
                // const SizedBox(height: 10),
                // _buildKeyValueRow(
                //   'Platform Fee',
                //   controller.platformFee.value,
                //   isBoldValue: false,
                // ),
                // const SizedBox(height: 10),
                // DottedLine(
                //   direction: Axis.horizontal,
                //   alignment: WrapAlignment.center,
                //   lineLength: double.infinity,
                //   lineThickness: 1.0,
                //   dashLength: 4.0,
                //   dashColor: Colors.grey.shade300,
                //   dashGapLength: 2.0,
                //   dashGapColor: Colors.transparent,
                // ),
                //const SizedBox(height: 10),
                // _buildKeyValueRow(
                //   'Bank Fee',
                //   controller.bankFee.value,
                //   isBoldValue: false,
                // ),
                // const SizedBox(height: 10),
                // DottedLine(
                //   direction: Axis.horizontal,
                //   alignment: WrapAlignment.center,
                //   lineLength: double.infinity,
                //   lineThickness: 1.0,
                //   dashLength: 4.0,
                //   dashColor: Colors.grey.shade300,
                //   dashGapLength: 2.0,
                //   dashGapColor: Colors.transparent,
                // ),
                // const SizedBox(height: 10),
                // _buildKeyValueRow(
                //   'Discount 10%',
                //   controller.discountPercent.value,
                //   isBoldValue: false,
                // ),
                //const SizedBox(height: 10),
                // DottedLine(
                //   direction: Axis.horizontal,
                //   alignment: WrapAlignment.center,
                //   lineLength: double.infinity,
                //   lineThickness: 1.0,
                //   dashLength: 4.0,
                //   dashColor: Colors.grey.shade300,
                //   dashGapLength: 2.0,
                //   dashGapColor: Colors.transparent,
                // ),
                // const SizedBox(height: 10),
                // _buildKeyValueRow(
                //   controller.couponCode.value.isNotEmpty
                //       ? (controller.couponCode.value.startsWith('#')
                //             ? 'Coupon ${controller.couponCode.value}'
                //             : 'Coupon #${controller.couponCode.value}')
                //       : 'Coupon #WELCOME10',
                //   controller.couponDiscount.value,
                //   isBoldValue: false,
                // ),
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
                if (controller.cgst.value.trim().isNotEmpty &&
                    controller.cgst.value.trim() != 'null' &&
                    controller.cgst.value.trim() != '-') ...[
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
                ],
                if (controller.sgst.value.trim().isNotEmpty &&
                    controller.sgst.value.trim() != 'null' &&
                    controller.sgst.value.trim() != '-') ...[
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
                ],
                if (controller.igst.value.trim().isNotEmpty &&
                    controller.igst.value.trim() != 'null' &&
                    controller.igst.value.trim() != '-') ...[
                  _buildKeyValueRow(
                    'IGST',
                    controller.igst.value,
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
                ],

                _buildKeyValueRow(
                  'TotalTax',
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
                  'Total',
                  controller.grandTotal.value,
                  isBoldLabel: true,
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
              // 'Way Bill',
              // 'Credit Note',
              // 'Debit Note',
              // 'Delivery Challan',
              // 'Quotation',
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
              final isInvoiceRow =
                  typeTitle.toLowerCase().replaceAll(' ', '') == 'invoice';
              final hasInvoiceId =
                  controller.invoiceId.value.trim().isNotEmpty &&
                  controller.invoiceId.value.trim() != 'null';

              final hasFile = isInvoiceRow
                  ? hasInvoiceId
                  : (docToUse != null &&
                        docToUse.code.trim().isNotEmpty &&
                        docToUse.code.trim() != 'null' &&
                        docToUse.code.trim() != '-');

              final String displayCode = isInvoiceRow
                  ? (controller.invoiceNumber.value.trim().isNotEmpty &&
                            controller.invoiceNumber.value.trim() != 'null'
                        ? controller.invoiceNumber.value.trim()
                        : (docToUse?.code.trim().isNotEmpty == true &&
                                  docToUse!.code.trim() != 'null' &&
                                  docToUse.code != '-'
                              ? docToUse.code.trim()
                              : (controller.invoiceId.value.trim().isNotEmpty &&
                                        controller.invoiceId.value.trim() !=
                                            'null'
                                    ? controller.invoiceId.value.trim()
                                    : '-')))
                  : (docToUse?.code ?? '');

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

              Widget actionWidget;
              if (isInvoiceRow) {
                final isDownloaded = controller.isInvoiceDownloaded.value;
                final isLoading = controller.isDownloadingInvoice.value;

                if (!isDownloaded) {
                  // Step 1: "Generate Invoice" button (does NOT start download)
                  actionWidget = InkWell(
                    onTap: () {
                      if (isLoading) return;
                      controller.generateInvoice();
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sync_rounded,
                            size: 14,
                            color: Color(0xFF1E293B),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Generate Invoice',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  final hasValidInvoice =
                      hasInvoiceId &&
                      displayCode.isNotEmpty &&
                      displayCode != '-';

                  if (!hasValidInvoice) {
                    actionWidget = const Text(
                      '-',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    );
                  } else {
                    actionWidget = InkWell(
                      onTap: () {
                        if (isLoading) return;
                        controller.downloadInvoiceById(
                          controller.invoiceId.value,
                        );
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            isLoading
                                ? const SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF475569),
                                    ),
                                  )
                                : const Icon(
                                    Icons.file_download_outlined,
                                    size: 16,
                                    color: Color(0xFF475569),
                                  ),
                            const SizedBox(width: 6),
                            Text(
                              displayCode,
                              style: const TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }
              } else if (hasFile) {
                actionWidget = InkWell(
                  onTap: () {
                    if (docToUse != null) {
                      controller.downloadDocument(docToUse);
                    }
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
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
                          displayCode,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                actionWidget = const Text(
                  '-',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                );
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
                    actionWidget,
                  ],
                ),
              );
            }

            // Append any additional documents from controller.documents not in standard types
            for (final doc in controller.documents) {
              final normTitle = doc.title.toLowerCase().replaceAll(' ', '');
              if (!processedTitles.contains(normTitle)) {
                docRows.add(const SizedBox(height: 10));
                // docRows.add(
                //   DottedLine(
                //     direction: Axis.horizontal,
                //     alignment: WrapAlignment.center,
                //     lineLength: double.infinity,
                //     lineThickness: 1.0,
                //     dashLength: 4.0,
                //     dashColor: Colors.grey.shade300,
                //     dashGapLength: 2.0,
                //     dashGapColor: Colors.transparent,
                //   ),
                // );
                // docRows.add(const SizedBox(height: 10));

                // docRows.add(
                //   Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         doc.title,
                //         style: const TextStyle(
                //           fontSize: 13,
                //           color: Color(0xFF64748B),
                //         ),
                //       ),
                //       hasFile
                //           ? InkWell(
                //               onTap: () => controller.downloadDocument(doc),
                //               borderRadius: BorderRadius.circular(6),
                //               child: Container(
                //                 padding: const EdgeInsets.symmetric(
                //                   horizontal: 10,
                //                   vertical: 6,
                //                 ),
                //                 decoration: BoxDecoration(
                //                   color: const Color(0xFFF8FAFC),
                //                   border: Border.all(
                //                     color: const Color(0xFFE2E8F0),
                //                   ),
                //                   borderRadius: BorderRadius.circular(6),
                //                 ),
                //                 child: Row(
                //                   mainAxisSize: MainAxisSize.min,
                //                   children: [
                //                     const Icon(
                //                       Icons.download_outlined,
                //                       size: 14,
                //                       color: Color(0xFF1E293B),
                //                     ),
                //                     const SizedBox(width: 4),
                //                     Text(
                //                       doc.code,
                //                       style: const TextStyle(
                //                         fontSize: 11,
                //                         fontWeight: FontWeight.w700,
                //                         color: Color(0xFF1E293B),
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             )
                //           : const Text(
                //               '-',
                //               style: TextStyle(
                //                 fontSize: 13,
                //                 fontWeight: FontWeight.w500,
                //                 color: Color(0xFF64748B),
                //               ),
                //             ),
                //     ],
                //   ),
                // );
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Payments Transactions',
                    style: TextStyle(
                      fontFamily: 'Public-Sans',
                      fontSize: Responsive.sp(context, 15),
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildAddNewPaymentButton(context, controller),
              ],
            ),
          ),
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
          LayoutBuilder(
            builder: (context, constraints) {
              final double tableWidth = constraints.maxWidth < 450
                  ? 450.0
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
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'ISSUED BY',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2F2B3D),
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'CREATED ON',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2F2B3D),
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'PAYMENT ID',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2F2B3D),
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'RRN/UTR',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2F2B3D),
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'STATUS',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2F2B3D),
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
                                  color: Color(0xFF2F2B3D),
                                  letterSpacing: 0,
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
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2F2B3D),
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                children: controller.transactions.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final tx = entry.value;
                                  final isLast =
                                      index ==
                                      controller.transactions.length - 1;

                                  return Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 14,
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
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    (tx.createdOn
                                                                .trim()
                                                                .isEmpty ||
                                                            tx.createdOn
                                                                    .trim() ==
                                                                'null')
                                                        ? '-'
                                                        : controller.extractDateOnly(
                                                            controller
                                                                .formatDateOnly(
                                                                  tx.createdOn,
                                                                ),
                                                          ),
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    (tx.createdOn
                                                                .trim()
                                                                .isEmpty ||
                                                            tx.createdOn
                                                                    .trim() ==
                                                                'null')
                                                        ? '-'
                                                        : controller.extractTimeOnly(
                                                            controller
                                                                .formatDateOnly(
                                                                  tx.createdOn,
                                                                ),
                                                          ),
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
                                              flex: 2,
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
                                                    color: const Color(
                                                      0xFFECFDF5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    tx.status,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                      ),
                                      if (!isLast)
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
                                    ],
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Order Items',
                    style: TextStyle(
                      fontFamily: 'Public-Sans',
                      fontSize: Responsive.sp(context, 15),
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildAcceptAllButton(context, controller),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          LayoutBuilder(
            builder: (context, constraints) {
              final double tableWidth = constraints.maxWidth < 650
                  ? 650.0
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
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'SL',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Text(
                                'PRODUCT',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'PRICE',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.2,
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
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'TOTAL',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'ACTION',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: Responsive.sp(context, 10.8),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFE2E8F0),
                      ),
                      // Product Rows
                      Obx(
                        () => controller.orderItems.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("No orders found!"),
                                ),
                              )
                            : Column(
                                children: [
                                  ...controller.orderItems.asMap().entries.map((
                                    entry,
                                  ) {
                                    final index = entry.key;
                                    final item = entry.value;

                                    return Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 14,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  '${(index + 1).toString()}.',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontFamily: 'Public Sans',
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 7,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                (item.name
                                                                        .trim()
                                                                        .isEmpty ||
                                                                    item.name
                                                                            .trim() ==
                                                                        'null')
                                                                ? '-'
                                                                : item.name,
                                                            style: const TextStyle(
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  'Public Sans',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Color(
                                                                0xFF475569,
                                                              ),
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                (item.itemType
                                                                        .trim()
                                                                        .isEmpty ||
                                                                    item.itemType
                                                                            .trim() ==
                                                                        'null')
                                                                ? '-'
                                                                : '  ${item.itemType}',
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  'Public Sans',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: ColorManager
                                                                  .secondary,
                                                            ),
                                                          ),
                                                          if (item.description
                                                                  .trim()
                                                                  .isNotEmpty &&
                                                              item.description
                                                                      .trim() !=
                                                                  'null' &&
                                                              item.description
                                                                      .trim() !=
                                                                  '-') ...[
                                                            const TextSpan(
                                                              text: ' ',
                                                            ),
                                                            TextSpan(
                                                              text: item
                                                                  .description,
                                                              style: const TextStyle(
                                                                fontFamily:
                                                                    'Public Sans',
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Color(
                                                                  0xFF94A3B8,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: _buildRupeeText(
                                                  item.price.replaceAll(
                                                    '₹ ',
                                                    '₹',
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
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
                                                    fontFamily: 'Public Sans',
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: _buildRupeeText(
                                                  (item.total.contains('₹')
                                                          ? item.total
                                                          : '₹${item.total}')
                                                      .replaceAll('₹ ', '₹'),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Obx(() {
                                                  final isAccepted =
                                                      item.isAccepted.value;
                                                  final isRejected =
                                                      item.isRejected.value;
                                                  return Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      // Accept Action Button
                                                      Tooltip(
                                                        message: isAccepted
                                                            ? 'Accepted'
                                                            : 'Accept Item',
                                                        child: InkWell(
                                                          onTap: () => controller
                                                              .toggleAcceptItem(
                                                                index,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                          child: Container(
                                                            width: 22,
                                                            height: 22,
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Colors
                                                                  .transparent,
                                                              border: Border.all(
                                                                color:
                                                                    isAccepted
                                                                    ? const Color(
                                                                        0xFF22C55E,
                                                                      )
                                                                    : const Color(
                                                                        0xFF94A3B8,
                                                                      ),
                                                                width: 1.3,
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Icon(
                                                                Icons
                                                                    .check_rounded,
                                                                size: 14,
                                                                color:
                                                                    isAccepted
                                                                    ? const Color(
                                                                        0xFF22C55E,
                                                                      )
                                                                    : const Color(
                                                                        0xFF94A3B8,
                                                                      ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      // Reject Action Button
                                                      Tooltip(
                                                        message: isRejected
                                                            ? 'Rejected'
                                                            : 'Reject Item',
                                                        child: InkWell(
                                                          onTap: () => controller
                                                              .toggleRejectItem(
                                                                index,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                          child: Container(
                                                            width: 22,
                                                            height: 22,
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Colors
                                                                  .transparent,
                                                              border: Border.all(
                                                                color:
                                                                    isRejected
                                                                    ? const Color(
                                                                        0xFFEF4444,
                                                                      )
                                                                    : const Color(
                                                                        0xFF94A3B8,
                                                                      ),
                                                                width: 1.3,
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Icon(
                                                                Icons
                                                                    .close_rounded,
                                                                size: 14,
                                                                color:
                                                                    isRejected
                                                                    ? const Color(
                                                                        0xFFEF4444,
                                                                      )
                                                                    : const Color(
                                                                        0xFF94A3B8,
                                                                      ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ],
                                    );
                                  }),
                                  // Summary Footer Row
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                style: const TextStyle(
                                                  fontFamily: 'Public Sans',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF475569),
                                                ),
                                                children: [
                                                  const TextSpan(
                                                    text:
                                                        'Total Rejected Items: ',
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        '${controller.totalRejectedItems}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF1E293B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'Total Declined Amount: ',
                                                  style: TextStyle(
                                                    fontFamily: 'Public Sans',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF475569),
                                                  ),
                                                ),
                                                _buildRupeeText(
                                                  controller
                                                      .totalDeclinedAmount,
                                                  style: const TextStyle(
                                                    fontFamily: 'Public Sans',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                style: const TextStyle(
                                                  fontFamily: 'Public Sans',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF475569),
                                                ),
                                                children: [
                                                  const TextSpan(
                                                    text:
                                                        'Total Accepted Items: ',
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        '${controller.totalAcceptedItems}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF1E293B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'Accepted Order Amount: ',
                                                  style: TextStyle(
                                                    fontFamily: 'Public Sans',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF475569),
                                                  ),
                                                ),
                                                _buildRupeeText(
                                                  controller
                                                      .acceptedOrderAmount,
                                                  style: const TextStyle(
                                                    fontFamily: 'Public Sans',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                                              fontFamily: 'Public Sans',
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
                                                    fontFamily: 'Public Sans',
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
                                          fontFamily: 'Public Sans',
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
                                      fontFamily: 'Public Sans',
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
    Widget? customLabelWidget,
  }) {
    final cleanValue = value.trim();
    final displayValue = (cleanValue.isEmpty || cleanValue == 'null')
        ? '-'
        : value;

    Widget labelWidget;
    // print("dsdsdsa...$customLabelWidget");
    // print("dsdsdsa...$label");
    if (customLabelWidget != null) {
      labelWidget = customLabelWidget;
    } else if (label.contains('#')) {
      final hashIndex = label.indexOf('#');
      final prefix = label.substring(0, hashIndex);
      final code = label.substring(hashIndex);

      labelWidget = Text.rich(
        TextSpan(
          style: TextStyle(
            fontFamily: 'Public-Sans',
            fontSize: isBoldLabel ? 14 : 13,
            fontWeight: isBoldLabel ? FontWeight.bold : FontWeight.w400,
            color: isBoldLabel
                ? const Color(0xFF1E293B)
                : const Color(0xFF64748B),
          ),
          children: [
            TextSpan(text: prefix),
            TextSpan(
              text: code,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D6B77),
              ),
            ),
          ],
        ),
      );
    } else {
      labelWidget = Text(
        label,
        style: TextStyle(
          fontFamily: 'Public-Sans',
          fontSize: isBoldLabel ? 14 : 13,
          fontWeight: isBoldLabel ? FontWeight.bold : FontWeight.w400,
          color: isBoldLabel
              ? const Color(0xFF1E293B)
              : const Color(0xFF64748B),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: labelWidget,
          ),
        ),
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child:
                customValueWidget ??
                _buildRupeeText(
                  displayValue,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: valueFontSize,
                    fontWeight: (isBoldValue && label.startsWith("Total"))
                        ? FontWeight.w800
                        : (isBoldValue && !label.startsWith("Total"))
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: label == "Customer"
                        ? ColorManager.azure
                        : const Color(0xFF444050),
                  ),
                ),
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

// =============================================================================
// ADD PAYMENT DRAWER (SLIDE-OVER PANEL)
// =============================================================================
class AddPaymentDrawer extends StatefulWidget {
  final OrderDetailsController controller;

  const AddPaymentDrawer({super.key, required this.controller});

  @override
  State<AddPaymentDrawer> createState() => _AddPaymentDrawerState();
}

class _AddPaymentDrawerState extends State<AddPaymentDrawer> {
  final _orderNoController = TextEditingController();
  final _dueAmountController = TextEditingController();
  final _rrnUtrController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  String _selectedIssuedBy = 'GPay';
  final List<String> _issuedByOptions = [
    'GPay',
    'PhonePe',
    'Paytm',
    'DTSPay',
    'Bank Transfer',
    'Cash',
  ];

  String _selectedStatus = 'Success';
  final List<String> _statusOptions = ['Success', 'Pending', 'Failed'];

  String? _receiptFileName;
  Uint8List? _receiptBytes;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _pickReceipt() async {
    final picked = await pickReceiptImage();
    if (picked != null && mounted) {
      setState(() {
        _receiptFileName = picked.name;
        _receiptBytes = picked.bytes;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _orderNoController.text = widget.controller.orderNo.value;
    _initDateTime();
  }

  void _initDateTime() {
    final now = DateTime.now();
    _selectedDate = now;
    _selectedTime = TimeOfDay.fromDateTime(now);
    _dateController.text =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final hour = _selectedTime.hour.toString().padLeft(2, '0');
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    final period = _selectedTime.period == DayPeriod.pm ? 'PM' : 'AM';
    _timeController.text = '$hour:$minute $period';
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFCF4340),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFCF4340),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        final period = picked.period == DayPeriod.pm ? 'PM' : 'AM';
        _timeController.text = '$hour:$minute $period';
      });
    }
  }

  Future<void> _submit() async {
    if (widget.controller.isSubmittingPayment.value) return;

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final success = await widget.controller.submitPayment(
      orderNumber: _orderNoController.text.trim(),
      dueAmount: _dueAmountController.text.trim(),
      issuedBy: _selectedIssuedBy,
      selectedDate: _selectedDate,
      selectedTime: _selectedTime,
      createdDateText: _dateController.text.trim(),
      createdTimeText: _timeController.text.trim(),
      rrnUtr: _rrnUtrController.text.trim(),
      amount: amountText,
      status: _selectedStatus,
      receiptFileName: _receiptFileName,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _orderNoController.dispose();
    _dueAmountController.dispose();
    _rrnUtrController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Public Sans',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF64748B),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontFamily: 'Public Sans',
        fontSize: 13,
        color: Color(0xFFCBD5E1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      suffixIcon: suffixIcon,
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
        borderSide: const BorderSide(color: Color(0xFFCF4340), width: 1.5),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return const Color(0xFF22C55E);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'failed':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF1E293B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawerWidth = Responsive.isMobile(context)
        ? MediaQuery.of(context).size.width * 0.88
        : 380.0;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: drawerWidth,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                spreadRadius: 2,
                offset: Offset(-4, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 18.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Add Payment',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2F2B3D),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 18,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Scrollable Form Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Order No.
                      _buildLabel('Order No.'),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _orderNoController,
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 13,
                            color: Color(0xFF1E293B),
                          ),
                          decoration: _inputDecoration(
                            hintText: 'Enter the amount',
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 2. Due Amount
                      _buildLabel('Due Amount'),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _dueAmountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 13,
                            color: Color(0xFF1E293B),
                          ),
                          decoration: _inputDecoration(
                            hintText: 'Enter the amount',
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 3. Issued By
                      _buildLabel('Issued By'),
                      const SizedBox(height: 6),
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedIssuedBy,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                            items: _issuedByOptions.map((opt) {
                              return DropdownMenuItem(
                                value: opt,
                                child: Text(
                                  opt,
                                  style: const TextStyle(
                                    fontFamily: 'Public Sans',
                                    fontSize: 13,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedIssuedBy = val);
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 4. Created Date
                      _buildLabel('Created Date'),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _dateController,
                          readOnly: true,
                          onTap: () => _pickDate(context),
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 13,
                            color: Color(0xFF1E293B),
                          ),
                          decoration: _inputDecoration(
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: Color(0xFF64748B),
                              ),
                              onPressed: () => _pickDate(context),
                              splashRadius: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 5. Created Time
                      _buildLabel('Created Time'),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _timeController,
                          readOnly: true,
                          onTap: () => _pickTime(context),
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 13,
                            color: Color(0xFF1E293B),
                          ),
                          decoration: _inputDecoration(
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.access_time_rounded,
                                size: 17,
                                color: Color(0xFF64748B),
                              ),
                              onPressed: () => _pickTime(context),
                              splashRadius: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 6. RRN/UTR
                      _buildLabel('RRN/UTR'),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _rrnUtrController,
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 13,
                            color: Color(0xFF1E293B),
                          ),
                          decoration: _inputDecoration(
                            hintText: 'Enter RRN/UTR number',
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 7. Amount
                      _buildLabel('Amount'),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 13,
                            color: Color(0xFF1E293B),
                          ),
                          decoration: _inputDecoration(
                            hintText: 'Enter the amount',
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 8. Receipt
                      _buildLabel('Receipt'),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickReceipt,
                        borderRadius: BorderRadius.circular(6),
                        child: CustomPaint(
                          painter: _DashedRectPainter(
                            color: const Color(0xFFCBD5E1),
                            strokeWidth: 1.0,
                            dashWidth: 4.0,
                            dashSpace: 3.0,
                            radius: 6.0,
                          ),
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(minHeight: 46),
                            padding: _receiptBytes != null
                                ? const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  )
                                : EdgeInsets.zero,
                            alignment: Alignment.center,
                            child: _receiptBytes != null
                                ? Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.memory(
                                          _receiptBytes!,
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _receiptFileName ?? 'Receipt image',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Public Sans',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _receiptBytes = null;
                                            _receiptFileName = null;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 16,
                                          color: Color(0xFF64748B),
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        splashRadius: 14,
                                      ),
                                    ],
                                  )
                                : const Text(
                                    '+ Add receipt here',
                                    style: TextStyle(
                                      fontFamily: 'Public Sans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 9. Status
                      _buildLabel('Status'),
                      const SizedBox(height: 6),
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedStatus,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                            items: _statusOptions.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontFamily: 'Public Sans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _getStatusColor(status),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedStatus = val);
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Buttons: Submit & Cancel
                      Row(
                        children: [
                          Obx(() {
                            final isSubmitting =
                                widget.controller.isSubmittingPayment.value;
                            return ElevatedButton(
                              onPressed: isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFCF4340),
                                disabledBackgroundColor: const Color(
                                  0xFFCF4340,
                                ).withOpacity(0.6),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                isSubmitting ? 'Submitting...' : 'Submit',
                                style: const TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              foregroundColor: const Color(0xFF64748B),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  _DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 4.0,
    this.dashSpace = 3.0,
    this.radius = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashSpace != dashSpace ||
      oldDelegate.radius != radius;
}
