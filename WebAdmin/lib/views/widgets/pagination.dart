import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/controllers/user_controller.dart';
import 'package:admin_app/utils/responsive.dart';

class PaginationControls extends StatelessWidget {
  const PaginationControls({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController controller = Get.find<UserController>();

    return Obx(() {
      final totalEntries = controller.filteredUsers.length;
      final start = controller.startEntryIndex;
      final end = controller.endEntryIndex;
      final currentPage = controller.currentPage.value;
      final totalPages = controller.totalPages;
      final double btnSize = 34.0;
      final borderColor = const Color(0xFFE2E8F0);

      return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          border: Border.all(color: borderColor),
        ),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Left Text: "Showing X to Y of Z entries"
            Text(
              'Showing $start to $end of $totalEntries entries',
              style: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w400,
              ),
            ),

            // Right Pagination Buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // First Page «
                  _buildNavBtn(
                    context: context,
                    btnSize: btnSize,
                    icon: Icons.keyboard_double_arrow_left_rounded,
                    isDisabled: currentPage <= 1,
                    onTap: () => controller.setPage(1),
                  ),
                  const SizedBox(width: 6),

                  // Prev Page ‹
                  _buildNavBtn(
                    context: context,
                    btnSize: btnSize,
                    icon: Icons.keyboard_arrow_left_rounded,
                    isDisabled: currentPage <= 1,
                    onTap: () => controller.setPage(currentPage - 1),
                  ),
                  const SizedBox(width: 6),

                  // Numbered Page Buttons (1 to totalPages, max 5 shown)
                  ...List.generate(totalPages.clamp(1, 5), (index) {
                    final pageNum = index + 1;
                    final isSelected = pageNum == currentPage;

                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: InkWell(
                        onTap: () => controller.setPage(pageNum),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: btnSize,
                          height: btnSize,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFCF4340)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '$pageNum',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF475569),
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: Responsive.sp(context, 13),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Next Page ›
                  _buildNavBtn(
                    context: context,
                    btnSize: btnSize,
                    icon: Icons.keyboard_arrow_right_rounded,
                    isDisabled: currentPage >= totalPages,
                    onTap: () => controller.setPage(currentPage + 1),
                  ),
                  const SizedBox(width: 6),

                  // Last Page »
                  _buildNavBtn(
                    context: context,
                    btnSize: btnSize,
                    icon: Icons.keyboard_double_arrow_right_rounded,
                    isDisabled: currentPage >= totalPages,
                    onTap: () => controller.setPage(totalPages),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNavBtn({
    required BuildContext context,
    required double btnSize,
    required IconData icon,
    required bool isDisabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: btnSize,
        height: btnSize,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Icon(
            icon,
            color: isDisabled
                ? const Color(0xFFCBD5E1)
                : const Color(0xFF475569),
            size: 18,
          ),
        ),
      ),
    );
  }
}

