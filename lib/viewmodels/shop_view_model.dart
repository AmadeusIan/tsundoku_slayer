import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class ShopViewModel extends ChangeNotifier {
  Map<String, dynamic>? userData;
  Map<String, int> inventory = {'STREAK_SHIELD': 0, 'REVIVE_POTION': 0};
  bool isLoading = true;

  int get currentExp => userData?['current_exp'] ?? 0;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    final profile = await DatabaseHelper.instance.getUserProfile();
    final inv = await DatabaseHelper.instance.getInventory();
    
    userData = profile;
    inventory = {
      'STREAK_SHIELD': inv['STREAK_SHIELD'] ?? 0,
      'REVIVE_POTION': inv['REVIVE_POTION'] ?? 0,
    };
    
    isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> buyItem(String itemCode, int price, int maxLimit) async {
    isLoading = true;
    notifyListeners();

    final result = await DatabaseHelper.instance.buyItem(
      itemCode: itemCode,
      price: price,
      maxLimit: maxLimit,
    );

    // Refresh koin dan inventory pasca-pembelian
    await loadData();
    
    return result;
  }
}
