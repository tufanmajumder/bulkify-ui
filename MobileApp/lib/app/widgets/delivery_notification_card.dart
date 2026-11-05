import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryNotificationCard extends StatelessWidget {
  final String orderId;
  final String distance;
  final String description;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const DeliveryNotificationCard({
    super.key,
    this.orderId = '#001',
    this.distance = '2.5 km away',
    this.description =
        'Collect the order from the merchant and deliver it to the customer.',
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262D), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: App icon, Title, "now"
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    'assets/bulkifyShortLogo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Delivery Driver',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Text(
                  'now',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF8B949E),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // "New Delivery Available"
            const Text(
              'New Delivery Available',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // "Order #001 · 2.5 km away"
            Text(
              'Order $orderId · $distance',
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              description,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF9CA3AF),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),

            // Action Buttons: Accept (Green) & Reject (Red)
            Row(
              children: [
                // Accept Button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (onAccept != null) {
                        onAccept!();
                      } else {
                        Get.back();
                        Get.snackbar(
                          'Order Accepted',
                          'You have accepted Order $orderId',
                          backgroundColor: const Color(0xFF16A34A),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 19,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Accept',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Reject Button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (onReject != null) {
                        onReject!();
                      } else {
                        Get.back();
                        Get.snackbar(
                          'Order Rejected',
                          'You rejected Order $orderId',
                          backgroundColor: const Color(0xFFDC2626),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: Colors.white,
                            size: 19,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Reject',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

