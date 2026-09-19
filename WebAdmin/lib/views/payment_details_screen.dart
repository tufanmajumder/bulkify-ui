import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:admin_app/models/payment_model.dart';
import 'package:admin_app/utils/responsive.dart';
import 'widgets/header.dart';
import 'widgets/sidebar.dart';

class PaymentDetailsScreen extends StatelessWidget {
  final PaymentModel? payment;

  const PaymentDetailsScreen({super.key, this.payment});

  @override
  Widget build(BuildContext context) {
    // If payment was passed via arguments or constructor, use it. Otherwise fallback to default mock model matching screenshot.
    final PaymentModel data = payment ??
        (Get.arguments is PaymentModel ? Get.arguments as PaymentModel : null) ??
        PaymentModel(
          orderId: 'ORD1234567890',
          paymentId: 'TENDEG50652536',
          utrRrn: '235241252525255200',
          paymentMethod: 'UPI',
          customerName: 'Christian Teigland',
          date: '05-10-2026',
          time: '9:30 AM',
          status: 'Success',
          amount: '38623.00',
          terminal: 'Bulkify-Ride-USR001',
          channel: 'bulkifyb2b.com',
        );

    final isMobileOrTablet =
        Responsive.isMobile(context) || Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      drawer: isMobileOrTablet
          ? const Drawer(
              backgroundColor: Colors.white,
              child: Sidebar(isDrawer: true, activeRoute: '/payment-details'),
            )
          : null,
      body: Row(
        children: [
          if (!isMobileOrTablet)
            const Sidebar(activeRoute: '/payment-details'),
          Expanded(
            child: Column(
              children: [
                const Header(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Go Back Link
                        _buildGoBackLink(context),
                        const SizedBox(height: 16),

                        // Main Content Grid (Left Details + Right Timeline)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isDesktop = constraints.maxWidth >= 1024;

                            if (isDesktop) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Column (Payment ID/Amount + Details Card)
                                  Expanded(
                                    flex: 7,
                                    child: Column(
                                      children: [
                                        _buildHeaderCard(context, data),
                                        const SizedBox(height: 20),
                                        _buildDetailsCard(context, data),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  // Right Column (Timeline Card)
                                  Expanded(
                                    flex: 3,
                                    child: _buildTimelineCard(context),
                                  ),
                                ],
                              );
                            }

                            // Mobile / Tablet vertical layout
                            return Column(
                              children: [
                                _buildHeaderCard(context, data),
                                const SizedBox(height: 20),
                                _buildDetailsCard(context, data),
                                const SizedBox(height: 20),
                                _buildTimelineCard(context),
                              ],
                            );
                          },
                        ),
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

  // Go Back Button
  Widget _buildGoBackLink(BuildContext context) {
    return InkWell(
      onTap: () {
        if (Navigator.canPop(context)) {
          Get.back();
        } else {
          Get.offAllNamed('/payments');
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFFCF4340),
              size: 20,
            ),
            SizedBox(width: 4),
            Text(
              'Go Back',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFCF4340),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card 1: Payment ID & Amount Header Card
  Widget _buildHeaderCard(BuildContext context, PaymentModel data) {
    String rawAmount = data.amount.replaceAll('₹', '').trim();
    if (!rawAmount.contains('.')) {
      rawAmount = '$rawAmount.00';
    }

    return Container(
      padding: const EdgeInsets.all(24),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Payment ID
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment ID',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    data.paymentId,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: data.paymentId));
                      Get.snackbar(
                        'Copied',
                        'Payment ID copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                        backgroundColor: const Color(0xFF1E293B),
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                        maxWidth: 320,
                      );
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right: Amount & Rupee Box
          Row(
            children: [
              Text(
                rawAmount,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECEB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '₹',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFCF4340),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card 2: Details Card
  Widget _buildDetailsCard(BuildContext context, PaymentModel data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              if (width > 600) {
                // 4-Column Grid
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildDetailField('UTR/RRN', data.utrRrn)),
                        Expanded(child: _buildDetailField('Payment Type', data.paymentMethod)),
                        Expanded(child: _buildDetailField('Terminal', data.terminal)),
                        Expanded(child: _buildDetailField('Channel', data.channel)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildDetailField('Customer Details', data.customerName)),
                        Expanded(child: _buildDetailField('Created On', data.date)),
                        Expanded(child: _buildDetailField('Created Time', data.time)),
                        Expanded(
                          child: _buildDetailField(
                            'Status',
                            data.status,
                            isStatus: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              // 2-Column Grid for smaller views
              return Wrap(
                runSpacing: 20,
                spacing: 20,
                children: [
                  SizedBox(width: (width - 20) / 2, child: _buildDetailField('UTR/RRN', data.utrRrn)),
                  SizedBox(width: (width - 20) / 2, child: _buildDetailField('Payment Type', data.paymentMethod)),
                  SizedBox(width: (width - 20) / 2, child: _buildDetailField('Terminal', data.terminal)),
                  SizedBox(width: (width - 20) / 2, child: _buildDetailField('Channel', data.channel)),
                  SizedBox(width: (width - 20) / 2, child: _buildDetailField('Customer Details', data.customerName)),
                  SizedBox(width: (width - 20) / 2, child: _buildDetailField('Created On', data.date)),
                  SizedBox(width: (width - 20) / 2, child: _buildDetailField('Created Time', data.time)),
                  SizedBox(
                    width: (width - 20) / 2,
                    child: _buildDetailField('Status', data.status, isStatus: true),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, String value, {bool isStatus = false}) {
    Color valueColor = const Color(0xFF1E293B);
    if (isStatus) {
      switch (value.toLowerCase()) {
        case 'success':
          valueColor = const Color(0xFF22C55E);
          break;
        case 'pending':
          valueColor = const Color(0xFFF59E0B);
          break;
        case 'failed':
          valueColor = const Color(0xFFEF4444);
          break;
        default:
          valueColor = const Color(0xFF64748B);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.isEmpty ? '-' : value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // Card 3: Timeline Card
  Widget _buildTimelineCard(BuildContext context) {
    final List<Map<String, String>> steps = [
      {'title': 'Payment Created', 'time': 'Tuesday 11:29 AM'},
      {'title': 'Payment Authorized', 'time': 'Tuesday 11:29 AM'},
      {'title': 'Payment Captured', 'time': 'Tuesday 11:29 AM'},
      {'title': 'Payment Successful', 'time': 'Tuesday 11:29 AM'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 20),
          Column(
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final isLast = index == steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dot and line indicator
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 42,
                          color: const Color(0xFF22C55E),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Event details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step['time']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        if (!isLast) const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
