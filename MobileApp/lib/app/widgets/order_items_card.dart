import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bulkify/app/data/utils/widget_manager.dart';

class OrderItemsCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const OrderItemsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    const Color textPrimary = Color(0xFF18181B);
    const Color textSecondary = Color(0xFF71717A);
    const Color circleBg = Color(0xFFF4F4F6);
    const Color dividerColor = Color(0xFFF0F0F3);

    final int totalCount = items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Header Row (OUTSIDE of the white card)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            WidgetManager.customText(
              text: "Items",
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
            WidgetManager.customText(
              text: "$totalCount Items",
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: textSecondary,
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // 2. White Card Container (Contains ONLY the list of items)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                Divider(color: dividerColor, height: 24.h, thickness: 1.h),
            itemBuilder: (context, index) {
              final item = items[index];
              final String name = item['name'] ?? '';
              final String qty = item['quantity'] ?? item['qty'] ?? '1 pc';
              final String price = item['price'] ?? '';

              return Row(
                children: [
                  // Number Circle Badge (1, 2, 3...)
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: const BoxDecoration(
                      color: circleBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: WidgetManager.customText(
                        text: "${index + 1}",
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),

                  // Item Name & Quantity
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetManager.customText(
                          text: name,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                        SizedBox(height: 2.h),
                        WidgetManager.customText(
                          text: qty,
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w400,
                          color: textSecondary,
                        ),
                      ],
                    ),
                  ),

                  // Item Price
                  if (price.isNotEmpty)
                    WidgetManager.customText(
                      text: price.startsWith('₹') ? price : '₹ $price',
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
