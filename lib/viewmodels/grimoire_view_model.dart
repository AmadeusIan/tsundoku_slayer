import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class GrimoireViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> allBooks = [];
  bool isLoading = true;

  // Filter Buku Cerdas
  List<Map<String, dynamic>> get activeBooks => 
      allBooks.where((b) => b['status'] == 'ACTIVE').toList();
      
  List<Map<String, dynamic>> get backlogBooks => 
      allBooks.where((b) => b['status'] == 'BACKLOG').toList();
      
  List<Map<String, dynamic>> get completedBooks => 
      allBooks.where((b) => b['status'] == 'COMPLETED').toList();

  Future<void> loadBooks() async {
    isLoading = true;
    notifyListeners();

    allBooks = await DatabaseHelper.instance.getAllBooks();

    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleStatus(int bookId, String currentStatus) async {
    final newStatus = currentStatus == 'ACTIVE' ? 'BACKLOG' : 'ACTIVE';
    await DatabaseHelper.instance.toggleBookStatus(bookId, newStatus);
    await loadBooks();
  }

  Future<void> addBook(String title, int totalPages, int dailyTarget) async {
    await DatabaseHelper.instance.insertBook({
      'title': title,
      'total_pages': totalPages,
      'current_page': 0,
      'target_days': 1, // Parameter lama untuk stabilitas skema
      'daily_target_pages': dailyTarget,
      'status': 'BACKLOG', // Masuk rak antrean dulu agar pengguna fokus pada buku aktif
    });
    await loadBooks();
  }

  Future<Map<String, dynamic>?> updateReadingProgress(int bookId, int pagesRead) async {
    // Mengeksekusi penambahan halaman + sinkronisasi status EXP & Level
    final result = await DatabaseHelper.instance.completeReadingSession(
      bookId: bookId, 
      pagesRead: pagesRead
    );
    await loadBooks();
    return result['suggestedBook'];
  }

  Future<void> deleteBook(int bookId) async {
    // Perintah langsung ke instance database untuk cascading delete
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.delete('reading_sessions', where: 'book_id = ?', whereArgs: [bookId]);
      await txn.delete('books', where: 'id = ?', whereArgs: [bookId]);
    });
    await loadBooks();
  }
}
