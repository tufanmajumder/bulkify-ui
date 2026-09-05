import 'package:get/get.dart';
import '../database/database_helper.dart';
import '../models/fruit_item.dart';

class FruitController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  final fruitItems = <FruitItem>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    refreshFruitList();
  }

  Future<void> refreshFruitList() async {
    isLoading.value = true;
    final items = await _dbHelper.getFruits();
    fruitItems.assignAll(items);
    isLoading.value = false;
  }

  Future<void> addFruit(FruitItem fruit) async {
    await _dbHelper.insertFruit(fruit);
    await refreshFruitList();
  }

  Future<void> updateFruit(FruitItem fruit) async {
    await _dbHelper.updateFruit(fruit);
    await refreshFruitList();
  }

  Future<void> deleteFruit(FruitItem fruit) async {
    if (fruit.id != null) {
      await _dbHelper.deleteFruit(fruit.id!);
      await refreshFruitList();
    }
  }
}
