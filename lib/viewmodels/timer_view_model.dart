import 'dart:async';
import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class TimerViewModel extends ChangeNotifier {
  Timer? _timer;
  int secondsRemaining = 25 * 60; // Default 25 menit
  bool isRunning = false;

  // Memulai atau melanjutkan timer
  void startTimer(VoidCallback onTimerFinished) {
    isRunning = true;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        secondsRemaining--;
        notifyListeners(); // Render detik baru
      } else {
        _timer?.cancel();
        isRunning = false;
        notifyListeners();
        
        // Panggil pemicu Flow Extension Sheet di layer UI
        onTimerFinished();
      }
    });
  }

  // Menjeda timer
  void pauseTimer() {
    _timer?.cancel();
    isRunning = false;
    notifyListeners();
  }

  // Tambah waktu dari Flow State
  void addTime(int additionalSeconds, VoidCallback onTimerFinished) {
    secondsRemaining += additionalSeconds;
    startTimer(onTimerFinished);
  }

  // Getter format jam digital
  String get formattedTime {
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Penyelesaian Sesi ke SQLite
  Future<Map<String, dynamic>> completeSession(int bookId, int pagesRead) async {
    return await DatabaseHelper.instance.completeReadingSession(
      bookId: bookId,
      pagesRead: pagesRead,
    );
  }

  // WAJIB: Bunuh timer saat layar dihancurkan untuk mencegah Memory Leak
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
