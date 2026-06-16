import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class ProfileViewModel extends ChangeNotifier {
  Map<String, dynamic>? userData;
  int completedBooksCount = 0;
  bool isLoading = true;

  // --- GETTER LOGIKA KOMPUTASI ---
  int get currentLevel => userData?['current_level'] ?? 1;
  int get currentExp => userData?['current_exp'] ?? 0;
  int get targetExp => DatabaseHelper.instance.getTargetExp(currentLevel);
  int get currentStreak => userData?['current_streak'] ?? 0;
  String get username => userData?['username'] ?? 'King';

  String get formattedJoinedDate {
    if (userData == null) return 'Belum ada data';
    final String rawCreatedAt = userData!['created_at'] ?? DateTime.now().toIso8601String();
    final DateTime createdDate = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    return '${createdDate.day.toString().padLeft(2, '0')}-${createdDate.month.toString().padLeft(2, '0')}-${createdDate.year}';
  }

  String get lastEvaluationDate => userData?['last_evaluation_date'] ?? 'Belum ada data';

  // --- ACTIONS (Perintah dari UI) ---

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners(); // Pancing UI menampilkan indikator loading

    final data = await DatabaseHelper.instance.getUserProfile();
    final allBooks = await DatabaseHelper.instance.getAllBooks();
    
    int completedCount = allBooks.where((b) => b['status'] == 'COMPLETED').length;

    userData = data;
    completedBooksCount = completedCount;
    isLoading = false;
    
    notifyListeners(); // Lempar data baru ke UI
  }

  Future<void> wipeAccountData() async {
    isLoading = true;
    notifyListeners();
    
    await DatabaseHelper.instance.wipeAccountData();
    await loadData();
  }

  Future<void> activateVacationMode(int days) async {
    isLoading = true;
    notifyListeners();
    
    await DatabaseHelper.instance.activateVacationMode(days);
    await loadData();
  }
}
