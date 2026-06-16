import 'package:flutter/material.dart';
import '../viewmodels/timer_view_model.dart';

class TimerScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const TimerScreen({super.key, required this.book});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late final TimerViewModel _viewModel;

  static const Color bgBeige = Color(0xFFF5F5DC);
  static const Color sakuraPink = Color(0xFFFFB7C5);
  static const Color warmBrown = Color(0xFF5D4037);

  @override
  void initState() {
    super.initState();
    _viewModel = TimerViewModel();
    // Memulai timer secara otomatis saat masuk ke layar
    _viewModel.startTimer(_showFlowExtensionSheet);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _earlySurrender() {
    _viewModel.pauseTimer();
    _showSessionCompletionDialog();
  }

  // MODAL BOTTOM SHEET: Perpanjangan Waktu (Flow State Extension)
  void _showFlowExtensionSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: bgBeige,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: warmBrown.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Bunga Kebijaksanaan Telah Mekar!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: warmBrown,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Apakah kamu masih berada di dalam zona fokus membacamu?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: warmBrown,
                ),
              ),
              const SizedBox(height: 24),
              
              // Tombol Tambah +10 Menit
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _viewModel.addTime(10 * 60, _showFlowExtensionSheet);
                },
                icon: const Icon(Icons.add_alarm, color: Colors.white),
                label: const Text('Tambah +10 Menit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sakuraPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 12),

              // Tombol Tambah +25 Menit
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _viewModel.addTime(25 * 60, _showFlowExtensionSheet);
                },
                icon: const Icon(Icons.hourglass_bottom, color: Colors.white),
                label: const Text('Tambah +25 Menit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sakuraPink.withValues(alpha: 0.8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 12),

              // Tombol Akhiri Sesi & Catat Halaman
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showSessionCompletionDialog();
                },
                icon: const Icon(Icons.check_circle_outline, color: warmBrown),
                label: const Text('Akhiri Sesi & Catat Halaman'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: warmBrown,
                  side: const BorderSide(color: warmBrown, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // DIALOG: Selesaikan Sesi & Ambil EXP
  void _showSessionCompletionDialog() {
    final formKey = GlobalKey<FormState>();
    final pagesController = TextEditingController();
    
    final int bookId = widget.book['id'];
    final String title = widget.book['title'] ?? 'Grimoire';
    final int totalPages = widget.book['total_pages'] ?? 1;
    final int currentPage = widget.book['current_page'] ?? 0;
    final int remainingPages = totalPages - currentPage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: bgBeige,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Row(
            children: [
              const Icon(Icons.local_florist, size: 26, color: sakuraPink),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: warmBrown,
                  ),
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Berapa lembar mantra yang kamu pelajari hari ini?',
                  style: TextStyle(
                    fontSize: 14,
                    color: warmBrown,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sisa halaman: $remainingPages halaman.',
                  style: TextStyle(
                    fontSize: 12,
                    color: warmBrown.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: pagesController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: warmBrown),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.menu_book, color: sakuraPink),
                    labelText: 'Jumlah Halaman yang Dibaca',
                    labelStyle: TextStyle(color: warmBrown.withValues(alpha: 0.7)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.6),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: sakuraPink.withValues(alpha: 0.5), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: sakuraPink, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Jumlah halaman tidak boleh kosong';
                    }
                    final val = int.tryParse(value);
                    if (val == null || val <= 0) {
                      return 'Masukkan jumlah halaman yang valid (> 0)';
                    }
                    if (val > remainingPages) {
                      return 'Halaman dibaca melebihi sisa buku ($remainingPages)';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _viewModel.startTimer(_showFlowExtensionSheet); // Lanjutkan timer
              },
              child: Text(
                'Batal',
                style: TextStyle(color: warmBrown.withValues(alpha: 0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final pagesRead = int.parse(pagesController.text.trim());

                  // Eksekusi transaksi database melalui ViewModel
                  final sessionResult = await _viewModel.completeSession(bookId, pagesRead);

                  if (context.mounted) {
                    Navigator.pop(context); // Tutup dialog
                    // Pop layar TimerScreen dan kirim informasi balik ke DashboardScreen
                    Navigator.pop(context, {
                      'refresh': true,
                      'pagesRead': pagesRead,
                      'levelsGained': sessionResult['levelsGained'],
                      'suggestedBook': sessionResult['suggestedBook'],
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: sakuraPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text('Selesaikan Sesi & Ambil EXP'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.book['title'] ?? 'Grimoire';

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: bgBeige,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: warmBrown),
              onPressed: () {
                // Konfirmasi jika ingin keluar dari sesi yang sedang berjalan
                _earlySurrender();
              },
            ),
            title: Text(
              title,
              style: const TextStyle(color: warmBrown, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // AREA ANIMASI: Kuncup Bunga / Sakurabuds Cozy Placeholder
                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: sakuraPink.withValues(alpha: 0.3),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ring progress luar yang bergaya
                          Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: sakuraPink.withValues(alpha: 0.3),
                                width: 6,
                              ),
                            ),
                          ),
                          // Ikon Bunga Cozy
                          Icon(
                            Icons.local_florist,
                            size: 90,
                            color: _viewModel.isRunning ? sakuraPink : sakuraPink.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // TIMER DISPLAY
                  Text(
                    _viewModel.formattedTime,
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: warmBrown,
                      fontFamily: 'Courier', // Font lebar seragam
                      letterSpacing: 2.0,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Status Sesi
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sakuraPink.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _viewModel.isRunning ? 'Sedang Membaca...' : 'Sesi Jeda',
                      style: const TextStyle(
                        fontSize: 14,
                        color: warmBrown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // TOMBOL KENDALI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Play/Pause button
                      ElevatedButton(
                        onPressed: () {
                          if (_viewModel.isRunning) {
                            _viewModel.pauseTimer();
                          } else {
                            _viewModel.startTimer(_showFlowExtensionSheet);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: warmBrown,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          elevation: 4,
                          side: BorderSide(color: sakuraPink.withValues(alpha: 0.5)),
                        ),
                        child: Icon(
                          _viewModel.isRunning ? Icons.pause : Icons.play_arrow,
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 24),

                      // Early Surrender button
                      ElevatedButton.icon(
                        onPressed: _earlySurrender,
                        icon: const Icon(Icons.stop, color: Colors.white),
                        label: const Text(
                          'Hentikan Sesi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: warmBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
