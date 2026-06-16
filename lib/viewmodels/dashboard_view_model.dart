import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../services/notification_helper.dart';

class DashboardViewModel extends ChangeNotifier {
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> activeBooks = [];
  List<Map<String, dynamic>> backlogBooks = [];
  Map<int, int> pagesReadTodayMap = {};
  
  bool isLoading = true;
  String streakStatus = '';

  // --- GETTER LOGIKA PROFIL ---
  String get username => userData?['username'] ?? 'King';
  int get currentLevel => userData?['current_level'] ?? 1;
  int get currentExp => userData?['current_exp'] ?? 0;
  int get targetExp => DatabaseHelper.instance.getTargetExp(currentLevel);
  int get currentStreak => userData?['current_streak'] ?? 0;
  int get previousStreak => userData?['previous_streak'] ?? 0;
  
  String? get vacationUntil => userData?['vacation_until'] as String?;
  bool get isVacation => DatabaseHelper.instance.isVacationActive(vacationUntil);

  // --- LOGIKA STATUS KRUSIAL (Dipindah dari UI) ---
  bool get isCriticalMode {
    if (userData == null) return false;
    final now = DateTime.now();
    if (now.hour < 21) return false; // Berlaku di atas jam 21:00

    final String todayStr = now.toIso8601String().substring(0, 10);
    final String? lastRead = userData!['last_read_date'] as String?;
    if (lastRead != null && lastRead.startsWith(todayStr)) return false;

    if (isVacation) return false;

    return true;
  }

  bool get isEmergencyState {
    if (userData == null) return false;
    final String? lastReviveDate = userData!['last_revive_date'] as String?;
    
    if (previousStreak <= 0 || lastReviveDate == null) return false;
    
    try {
      final DateTime reviveDate = DateTime.parse(lastReviveDate);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(reviveDate);
      return difference.inHours < 24;
    } catch (e) {
      return false;
    }
  }

  // --- AKSI PENGAMBILAN DATA (Dipindah dari _loadData) ---
  Future<void> loadDashboardData() async {
    isLoading = true;
    notifyListeners();

    // 1. Evaluasi Takdir (Mesin Penentu Waktu)
    streakStatus = await DatabaseHelper.instance.evaluateDailyStreak();

    // 2. Tarik Data Utama
    userData = await DatabaseHelper.instance.getUserProfile();
    activeBooks = await DatabaseHelper.instance.getActiveBooks();
    backlogBooks = await DatabaseHelper.instance.getBacklogBooks();
    
    // 3. Looping Target Harian
    Map<int, int> todayReads = {};
    for (var b in activeBooks) {
      final bookId = b['id'] as int;
      todayReads[bookId] = await DatabaseHelper.instance.getPagesReadToday(bookId);
    }
    pagesReadTodayMap = todayReads;

    // 4. Injeksi Push Notification v22
    int shieldQty = await DatabaseHelper.instance.getInventoryQty('STREAK_SHIELD');
    final String todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final String? lastRead = userData!['last_read_date'] as String?;
    final bool hasReadToday = lastRead != null && lastRead.startsWith(todayStr);

    await NotificationHelper.instance.scheduleNightMissions(hasReadToday, shieldQty > 0, isVacation);

    isLoading = false;
    notifyListeners(); // Render Ulang Dashboard!
  }

  // --- AKSI PENGGUNA ---
  Future<bool> useRevivePotion() async {
    final inventory = await DatabaseHelper.instance.getInventory();
    final potionQty = inventory['REVIVE_POTION'] ?? 0;

    if (potionQty > 0) {
      final result = await DatabaseHelper.instance.useRevivePotion();
      await loadDashboardData();
      return result['status'] == 'SUCCESS';
    }
    return false; // Potion habis, arahkan ke Shop
  }

  Future<void> activateGrimoire(int bookId) async {
    await DatabaseHelper.instance.toggleBookStatus(bookId, 'ACTIVE');
    await loadDashboardData();
  }

  Future<void> insertNewBook(String title, int totalPages, int dailyTarget) async {
    await DatabaseHelper.instance.insertBook({
      'title': title,
      'total_pages': totalPages,
      'current_page': 0,
      'target_days': 1, // Stabilisator kolom lama
      'daily_target_pages': dailyTarget,
      'status': 'ACTIVE',
    });
    await loadDashboardData();
  }
}
