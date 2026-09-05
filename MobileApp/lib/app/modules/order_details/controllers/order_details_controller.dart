import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class OrderDetailsController extends GetxController {
  // Order Details Reactive Data
  final RxString orderId = '01'.obs;
  final RxString orderType = 'Food Delivery'.obs;
  final RxString customerName = 'Aditya Shah'.obs;
  final RxString customerPhone = '+91 98123 45670'.obs;
  final RxString dropOffAddress = 'Oakwood Heights, Flat 402'.obs;
  final RxDouble orderTotal = 165.00.obs;
  final RxString status = 'Accepted'.obs;

  final RxList<Map<String, dynamic>> items = RxList<Map<String, dynamic>>(_generate50Items());

  static List<Map<String, dynamic>> _generate50Items() {
    final sampleNames = [
      'Cheeseburger', 'Fries', 'Coke', 'Cheese Slice', 'Bacon Strips',
      'Veggie Pizza', 'Garlic Bread', 'Chicken Wings', 'Chocolate Milkshake', 'Brownie',
      'Iced Tea', 'Onion Rings', 'Nachos Dip', 'Sub Sandwich', 'Caesar Salad',
      'Crispy Tacos', 'Pasta Alfredo', 'Espresso Coffee', 'Glazed Donut', 'Spring Rolls',
      'Mozzarella Sticks', 'Grilled Cheese', 'Lemonade', 'Waffles', 'Pancakes',
      'Club Sandwich', 'Hot Dog', 'Chicken Nuggets', 'Potato Wedges', 'Fruit Bowl',
      'Churro Bites', 'Popcorn Chicken', 'Fish & Chips', 'Burrito Bowl', 'Quesadilla',
      'Apple Pie', 'Cupcake', 'Smoothie Bowl', 'Ice Cream Scoop', 'Iced Latte',
      'Garlic Dip', 'BBQ Sauce', 'Honey Mustard', 'Chipotle Mayo', 'Ranch Dressing',
      'Garlic Butter Toast', 'Mac & Cheese', 'Loaded Fries', 'Soft Pretzel', 'Chai Latte'
    ];

    final quantities = ['1 pc', '2 pc', '3 pc', '4 pc', '1 can', '2 cans', '1 order', '1 bowl', '1 bottle'];

    return List.generate(50, (index) {
      final name = sampleNames[index % sampleNames.length];
      final qty = quantities[index % quantities.length];
      final price = ((index + 1) * 25 + 15).toString();
      return {
        'name': name,
        'quantity': qty,
        'price': price,
      };
    });
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final data = Get.arguments as Map<String, dynamic>;
      if (data['id'] != null) {
        orderId.value = data['id'].toString().replaceAll('#', '');
      }
      if (data['orderType'] != null) {
        orderType.value = data['orderType'];
      }
      if (data['customerName'] != null) {
        customerName.value = data['customerName'];
      }
      if (data['customerPhone'] != null) {
        customerPhone.value = data['customerPhone'];
      }
      if (data['dropOffAddress'] != null || data['address'] != null) {
        dropOffAddress.value = (data['dropOffAddress'] ?? data['address']).toString();
      }
      if (data['amount'] != null && data['amount'] is num) {
        orderTotal.value = (data['amount'] as num).toDouble();
      }
      if (data['items'] != null && data['items'] is List && (data['items'] as List).length >= 50) {
        items.value = List<Map<String, dynamic>>.from(data['items']);
      }
      if (data['status'] != null) {
        status.value = data['status'].toString();
      }
    }
  }

  void onStartOrder() {
    Get.toNamed(
      Routes.NAVIGATE_TO_DELIVER,
      arguments: {
        'customerName': customerName.value == 'Aditya Shah' ? 'Priya Nair' : customerName.value,
        'dropOffAddress': dropOffAddress.value == 'Oakwood Heights, Flat 402'
            ? 'B-12, Lakeview Residency, 5th Avenue, Bengaluru 560034'
            : dropOffAddress.value,
        'orderTotal': orderTotal.value == 165.00 ? 145.00 : orderTotal.value,
        'customerPhone': customerPhone.value,
      },
    );
  }
}
