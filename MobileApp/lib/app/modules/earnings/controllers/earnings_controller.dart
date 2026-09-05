import 'package:get/get.dart';

class EarningsController extends GetxController {
  // Earnings Summary
  final RxString currencySymbol = '₹'.obs;
  final RxString earningsMain = '1,850'.obs;
  final RxString earningsCents = '.75'.obs;
  final RxInt totalOrders = 4.obs;

  // Breakdown Data
  final RxString baseFare = '₹ 1,240.00'.obs;
  final RxString distanceBonus = '₹ 380.75'.obs;
  final RxString peakHourBonus = '₹ 230.00'.obs;
  final RxString tips = '₹ 0.00'.obs;

  // Weekly Stats
  final RxString weeklyTotal = '₹ 9,420'.obs;
  final RxString weeklyDeliveries = '27'.obs;
}
