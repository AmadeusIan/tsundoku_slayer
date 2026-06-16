import 'package:flutter/material.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../services/notification_helper.dart';
import 'timer_screen.dart';
import 'shop_screen.dart';
import 'grimoire_library_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // 1. Inisialisasi Otak
    _viewModel = DashboardViewModel();
    // 2. Tarik Data + Pengecekan Dialog Awal
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    await _viewModel.loadDashboardData();
    if (!mounted) return;

    // Memunculkan Peringatan Penting (Notifikasi OS & Takdir Streak)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      NotificationHelper.instance.requestPermissions();
      
      if (_viewModel.streakStatus == 'SHIELD_USED') {
        _showShieldUsedDialog();
      } else if (_viewModel.streakStatus == 'STREAK_BROKEN') {
        _showStreakBrokenDialog();
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Palet Warna Sakura Cozy
    const Color bgBeige = Color(0xFFF5F5DC);
    const Color sakuraPink = Color(0xFFFFB7C5);
    const Color warmBrown = Color(0xFF5D4037);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: bgBeige,
          body: _viewModel.isLoading || _viewModel.userData == null
              ? const Center(child: CircularProgressIndicator(color: sakuraPink))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- HEADER: PROFIL KARAKTER ---
                        _buildProfileCard(sakuraPink, warmBrown),

                        const SizedBox(height: 30),

                        // --- EMERGENCY BANNER ---
                        if (_viewModel.isEmergencyState)
                          _buildEmergencyBanner(sakuraPink, warmBrown),

                        // --- CRITICAL NIGHT MODE BANNER ---
                        if (_viewModel.isCriticalMode)
                          _buildCriticalBanner(warmBrown),

                        // --- SECTION: POHON SAKURA (STREAK) ---
                        _buildStreakTree(sakuraPink, warmBrown),

                        const SizedBox(height: 30),

                        // --- SECTION: RAK BUKU (GRIMOIRE) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.menu_book, color: warmBrown, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  'Grimoire Aktif',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: warmBrown,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const GrimoireLibraryScreen()),
                                ).then((_) => _viewModel.loadDashboardData());
                              },
                              child: const Text('Lihat Semua', style: TextStyle(color: Colors.pink)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        // Rak buku aktif dinamis
                        if (_viewModel.activeBooks.isEmpty)
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: sakuraPink.withValues(alpha: 0.5), width: 2),
                            ),
                            child: _viewModel.backlogBooks.isNotEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'Rak sihirmu kosong, tapi ada naskah yang tertidur di gudang...',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.brown, fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const GrimoireLibraryScreen()),
                                          ).then((_) => _viewModel.loadDashboardData());
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: sakuraPink,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        child: const Text('Bangkitkan Grimoire Backlog'),
                                      ),
                                    ],
                                  )
                                : const Center(
                                    child: Text(
                                      'Belum ada buku sihir yang aktif...\nKetuk tombol + untuk menambah buku',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.brown, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _viewModel.activeBooks.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 15),
                            itemBuilder: (context, index) {
                              final book = _viewModel.activeBooks[index];
                              final int totalPages = book['total_pages'] ?? 1;
                              final int currentPage = book['current_page'] ?? 0;
                              final double progress = (currentPage / totalPages).clamp(0.0, 1.0);
                              
                              final int dailyTarget = book['daily_target_pages'] ?? 15;
                              final int readToday = _viewModel.pagesReadTodayMap[book['id']] ?? 0;
                              final double progressHarian = (readToday / dailyTarget).clamp(0.0, 1.0);
                              
                              final bool isDailyTargetMet = progressHarian >= 1.0;
                              final int remainingPages = totalPages - currentPage;
                              final bool isBookCompleted = remainingPages <= 0;

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: sakuraPink.withValues(alpha: 0.3), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: sakuraPink.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          // Ikon Grimoire Ajaib
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: sakuraPink.withValues(alpha: 0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.menu_book, size: 28, color: sakuraPink),
                                          ),
                                          const SizedBox(width: 16),
                                          // Detail Buku
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  book['title'] ?? 'Grimoire Tanpa Nama',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: warmBrown,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                if (isBookCompleted)
                                                  const Text(
                                                    'Buku ini telah ditamatkan!',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.green,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                else if (isDailyTargetMet)
                                                  const Text(
                                                    'Target Harian Terpenuhi!',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.amber,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                else
                                                  Text(
                                                    'Target Hari Ini: $readToday / $dailyTarget hal',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: warmBrown,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                const SizedBox(height: 6),
                                                if (!isBookCompleted)
                                                  Opacity(
                                                    opacity: isDailyTargetMet ? 0.5 : 1.0,
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          height: 8,
                                                          decoration: BoxDecoration(
                                                            color: sakuraPink.withValues(alpha: 0.2),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                        ),
                                                        FractionallySizedBox(
                                                          widthFactor: progressHarian == 0 ? 0.02 : progressHarian,
                                                          child: Container(
                                                            height: 8,
                                                            decoration: BoxDecoration(
                                                              color: sakuraPink,
                                                              borderRadius: BorderRadius.circular(4),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                if (!isBookCompleted) const SizedBox(height: 12),
                                                // Progress Bar Keseluruhan
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Stack(
                                                        children: [
                                                          Container(
                                                            height: 8,
                                                            decoration: BoxDecoration(
                                                              color: Colors.grey[200],
                                                              borderRadius: BorderRadius.circular(4),
                                                            ),
                                                          ),
                                                          FractionallySizedBox(
                                                            widthFactor: progress == 0 ? 0.02 : progress,
                                                            child: Container(
                                                              height: 8,
                                                              decoration: BoxDecoration(
                                                                gradient: const LinearGradient(
                                                                  colors: [sakuraPink, Colors.pinkAccent],
                                                                ),
                                                                borderRadius: BorderRadius.circular(4),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      '$currentPage/$totalPages hal',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                        color: warmBrown,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.play_circle_fill,
                                              color: sakuraPink,
                                              size: 40,
                                            ),
                                            onPressed: () async {
                                              final result = await Navigator.push<Map<String, dynamic>?>(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => TimerScreen(book: book),
                                                ),
                                              );

                                              if (result != null && result['refresh'] == true) {
                                                final int pagesRead = result['pagesRead'] ?? 0;
                                                final int levelsGained = result['levelsGained'] ?? 0;
                                                final int expGained = pagesRead * 10;

                                                // Memicu penarikan data baru dari ViewModel
                                                await _viewModel.loadDashboardData();

                                                if (context.mounted) {
                                                  if (result['suggestedBook'] != null) {
                                                    _showSuggestedBookDialog(result['suggestedBook']);
                                                  }
                                                  
                                                  if (levelsGained > 0) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          '🎉 LEVEL UP! Kamu naik $levelsGained level! Level saat ini: ${_viewModel.currentLevel} 🌸 (+ $expGained EXP)',
                                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                        ),
                                                        backgroundColor: Colors.pinkAccent,
                                                        duration: const Duration(seconds: 4),
                                                        behavior: SnackBarBehavior.floating,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          '✨ Sesi membaca selesai! Berhasil mempelajari $pagesRead halaman (+ $expGained EXP) 🌸',
                                                          style: const TextStyle(color: Colors.white),
                                                        ),
                                                        backgroundColor: warmBrown,
                                                        behavior: SnackBarBehavior.floating,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
          // Tombol Tambah Buku (Gaya RPG)
          floatingActionButton: FloatingActionButton(
            backgroundColor: sakuraPink,
            child: const Icon(Icons.add, color: Colors.white, size: 30),
            onPressed: () {
              _showAddBookSheet(context);
            },
          ),
        );
      }
    );
  }

  // WIDGET: Kartu Profil Character
  Widget _buildProfileCard(Color accent, Color textCol) {
    double expProgress = (_viewModel.currentExp / _viewModel.targetExp).clamp(0.0, 1.0); 
    if (expProgress == 0) expProgress = 0.02;

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        if (mounted) {
          _viewModel.loadDashboardData();
        }
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: accent.withValues(alpha: 0.2),
              child: const Icon(Icons.workspace_premium, size: 35, color: Colors.amber),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _viewModel.username,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textCol),
                  ),
                  Text('Level ${_viewModel.currentLevel} Slayer',
                      style: TextStyle(color: textCol.withValues(alpha: 0.7))),
                  const SizedBox(height: 10),
                  // Custom EXP Bar
                  Stack(
                    children: [
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: expProgress,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [accent, Colors.pinkAccent]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'EXP: ${_viewModel.currentExp} / ${_viewModel.targetExp}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textCol.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET: Banner Mode Kritis (Emergency Night Mission)
  Widget _buildCriticalBanner(Color textCol) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2C3E50).withValues(alpha: 0.9),
            const Color(0xFF4CA1AF).withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.nights_stay, size: 50, color: Colors.amber),
          const SizedBox(height: 12),
          const Text(
            'Malam Semakin Larut...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Angin malam berhembus dingin. Baca setidaknya 1 halaman sebelum tengah malam untuk menyelamatkan kehangatan pohon sakuramu!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GrimoireLibraryScreen()),
              ).then((_) => _viewModel.loadDashboardData());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB7C5),
              foregroundColor: const Color(0xFF5D4037),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Selamatkan Sekarang',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Representasi Pohon Sakura (Streak)
  Widget _buildStreakTree(Color accent, Color textCol) {
    if (_viewModel.isVacation) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [const Color(0xFF1A237E).withValues(alpha: 0.4), Colors.white]),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            const Text('Mode Istirahat',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
            const SizedBox(height: 10),
            const Icon(Icons.nights_stay, size: 80, color: Colors.amberAccent),
            const SizedBox(height: 10),
            Text(
              'Pohon sakuramu sedang tidur lelap hingga ${_viewModel.vacationUntil}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A237E)),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [accent.withValues(alpha: 0.4), Colors.white]),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Text('Pertumbuhan Sakura',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
          const SizedBox(height: 10),
          Icon(Icons.park, size: 80, color: _viewModel.currentStreak > 0 ? Colors.green[300] : Colors.brown[200]),
          const SizedBox(height: 10),
          Text(
            '${_viewModel.currentStreak} Hari Tanpa Henti',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textCol),
          ),
        ],
      ),
    );
  }

  // WIDGET: Formulir Tambah Grimoire (ModalBottomSheet Cozy)
  void _showAddBookSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final pagesController = TextEditingController();
    final dailyTargetController = TextEditingController();

    const Color bgBeige = Color(0xFFF5F5DC);
    const Color sakuraPink = Color(0xFFFFB7C5);
    const Color warmBrown = Color(0xFF5D4037);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgBeige,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
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
                    'Bangkitkan Grimoire Baru',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: warmBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tuliskan buku barumu dan tentukan target petualangan membaca kamu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: warmBrown.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  TextFormField(
                    controller: titleController,
                    style: const TextStyle(color: warmBrown),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.auto_stories, color: sakuraPink),
                      labelText: 'Judul Buku / Grimoire',
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
                        return 'Nama grimoire tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: pagesController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: warmBrown),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.layers, color: sakuraPink),
                      labelText: 'Total Halaman',
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
                        return 'Total halaman tidak boleh kosong';
                      }
                      final val = int.tryParse(value);
                      if (val == null || val <= 0) {
                        return 'Masukkan jumlah halaman yang valid (> 0)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: dailyTargetController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: warmBrown),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.menu_book, color: sakuraPink),
                      labelText: 'Target Halaman Harian',
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
                        return 'Target harian tidak boleh kosong';
                      }
                      final val = int.tryParse(value);
                      if (val == null || val <= 0) {
                        return 'Masukkan jumlah halaman yang valid (> 0)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final title = titleController.text.trim();
                        final totalPages = int.parse(pagesController.text.trim());
                        final dailyTarget = int.parse(dailyTargetController.text.trim());

                        // Panggil ViewModel untuk menulis ke SQLite
                        await _viewModel.insertNewBook(title, totalPages, dailyTarget);

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '🌸 Grimoire "$title" berhasil dibangkitkan!',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: warmBrown,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sakuraPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                      shadowColor: sakuraPink.withValues(alpha: 0.5),
                    ),
                    child: const Text(
                      'Bangkitkan Grimoire',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // WIDGET: Dialog Cozy Streak Shield Terpakai
  void _showShieldUsedDialog() {
    const Color bgBeige = Color(0xFFF5F5DC);
    const Color sakuraPink = Color(0xFFFFB7C5);
    const Color warmBrown = Color(0xFF5D4037);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: bgBeige,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Row(
            children: [
              Icon(Icons.security, size: 26, color: Colors.blueGrey),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Streak Shield Aktif',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: warmBrown,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Syukurlah! Sihir dari Streak Shield-mu telah melindungi pohon sakuramu dari layu semalam.',
            style: TextStyle(
              fontSize: 14,
              color: warmBrown.withValues(alpha: 0.9),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: sakuraPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text('Terima Kasih'),
            ),
          ],
        );
      },
    );
  }

  // WIDGET: Dialog Cozy Streak Putus (Desain Empati Memaafkan)
  void _showStreakBrokenDialog() {
    const Color bgBeige = Color(0xFFF5F5DC);
    const Color sakuraPink = Color(0xFFFFB7C5);
    const Color warmBrown = Color(0xFF5D4037);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: bgBeige,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Row(
            children: [
              Icon(Icons.energy_savings_leaf, size: 26, color: Colors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Musim Berganti...',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: warmBrown,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Musim telah berganti dan pohon sakuramu sedang tertidur. Tidak apa-apa, mari tanam benih yang baru hari ini!',
            style: TextStyle(
              fontSize: 14,
              color: warmBrown.withValues(alpha: 0.9),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: sakuraPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text('Tanam Benih Baru'),
            ),
          ],
        );
      },
    );
  }

  // WIDGET: Dialog Cozy Pancingan Buku Baru
  void _showSuggestedBookDialog(Map<String, dynamic> book) {
    const Color bgBeige = Color(0xFFF5F5DC);
    const Color sakuraPink = Color(0xFFFFB7C5);
    const Color warmBrown = Color(0xFF5D4037);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: bgBeige,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Row(
            children: [
              Icon(Icons.auto_awesome, size: 26, color: Colors.amber),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Perjalanan Baru?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: warmBrown,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Satu perjalanan telah usai! Maukah kamu mulai membaca "${book['title']}" sekarang?',
            style: TextStyle(
              fontSize: 14,
              color: warmBrown.withValues(alpha: 0.9),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Nanti Saja', style: TextStyle(color: warmBrown.withValues(alpha: 0.7))),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _viewModel.activateGrimoire(book['id']);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Buku "${book['title']}" telah diaktifkan!'),
                      backgroundColor: sakuraPink,
                    ),
                  );
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
              child: const Text('Aktifkan Grimoire'),
            ),
          ],
        );
      },
    );
  }

  // WIDGET: Banner Darurat Revive Potion
  Widget _buildEmergencyBanner(Color accent, Color textCol) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.15),
            Colors.pink.withValues(alpha: 0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 28, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Streak Terputus! (${_viewModel.previousStreak} Hari)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Jangan menyerah! Kamu masih punya waktu sebelum sihir pohon sakuramu benar-benar memudar.',
            style: TextStyle(
              fontSize: 14,
              color: textCol.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final success = await _viewModel.useRevivePotion();
                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          '✨ Keajaiban terjadi! Pohon sakuramu kembali mekar.',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.purple,
                        duration: const Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ShopScreen()),
                    ).then((_) => _viewModel.loadDashboardData());
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.withValues(alpha: 0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Gunakan Revive Potion',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}