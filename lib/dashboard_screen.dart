import 'package:flutter/material.dart';
import 'database_helper.dart';
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
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> activeBooks = [];
  List<Map<String, dynamic>> backlogBooks = [];
  Map<int, int> pagesReadTodayMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final String streakStatus = await DatabaseHelper.instance.evaluateDailyStreak();

    final data = await DatabaseHelper.instance.getUserProfile();
    final books = await DatabaseHelper.instance.getActiveBooks();
    final bBooks = await DatabaseHelper.instance.getBacklogBooks();
    
    Map<int, int> todayReads = {};
    for (var b in books) {
      final bookId = b['id'] as int;
      todayReads[bookId] = await DatabaseHelper.instance.getPagesReadToday(bookId);
    }
    
    setState(() {
      userData = data;
      activeBooks = books;
      backlogBooks = bBooks;
      pagesReadTodayMap = todayReads;
      isLoading = false;
    });

    if (context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        if (streakStatus == 'SHIELD_USED') {
          _showShieldUsedDialog();
        } else if (streakStatus == 'STREAK_BROKEN') {
          _showStreakBrokenDialog();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Palet Warna Sakura Cozy
    const Color bgBeige = Color(0xFFF5F5DC);
    const Color sakuraPink = Color(0xFFFFB7C5);
    const Color warmBrown = Color(0xFF5D4037);

    return Scaffold(
      backgroundColor: bgBeige,
      body: isLoading
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
                    if (_isEmergencyState())
                      _buildEmergencyBanner(sakuraPink, warmBrown),

                    // --- SECTION: POHON SAKURA (STREAK) ---
                    _buildStreakTree(sakuraPink, warmBrown),

                    const SizedBox(height: 30),

                    // --- SECTION: RAK BUKU (GRIMOIRE) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '📖 Grimoire Aktif',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: warmBrown,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const GrimoireLibraryScreen()),
                            ).then((_) => _loadData());
                          },
                          child: const Text('Lihat Semua', style: TextStyle(color: Colors.pink)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Rak buku aktif dinamis
                    if (activeBooks.isEmpty)
                      Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5), // Diperbarui
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: sakuraPink.withValues(alpha: 0.5), width: 2), // Diperbarui
                        ),
                        child: backlogBooks.isNotEmpty
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
                                      ).then((_) => _loadData());
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
                        itemCount: activeBooks.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 15),
                        itemBuilder: (context, index) {
                          final book = activeBooks[index];
                          final int totalPages = book['total_pages'] ?? 1;
                          final int currentPage = book['current_page'] ?? 0;
                          final double progress = (currentPage / totalPages).clamp(0.0, 1.0);
                          
                          final int dailyTarget = book['daily_target_pages'] ?? 15;
                          final int readToday = pagesReadTodayMap[book['id']] ?? 0;
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
                                        child: const Text(
                                          '📖',
                                          style: TextStyle(fontSize: 28),
                                        ),
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
                                                '🎉 Buku ini telah ditamatkan!',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            else if (isDailyTargetMet)
                                              const Text(
                                                '✨ Target Harian Terpenuhi!',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.amber,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            else
                                              Text(
                                                'Target Hari Ini: $readToday / $dailyTarget hal',
                                                style: TextStyle(
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

                                            // Memicu penarikan data baru dari SQLite
                                            await _loadData();

                                            if (context.mounted) {
                                              if (result['suggestedBook'] != null) {
                                                _showSuggestedBookDialog(result['suggestedBook']);
                                              }
                                              
                                              if (levelsGained > 0) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      '🎉 LEVEL UP! Kamu naik $levelsGained level! Level saat ini: ${userData!['current_level']} 🌸 (+ $expGained EXP)',
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

  // WIDGET: Kartu Profil Character
  Widget _buildProfileCard(Color accent, Color textCol) {
    final int currentLevel = userData!['current_level'] ?? 1;
    final int currentExp = userData!['current_exp'] ?? 0;
    final int targetExp = DatabaseHelper.instance.getTargetExp(currentLevel);
    double expProgress = (currentExp / targetExp).clamp(0.0, 1.0); 
    if (expProgress == 0) expProgress = 0.02;

    return InkWell(
      onTap: () async {
        // 1. Tunggu (await) sampai pengguna kembali dari layar Profil
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        // 2. Setelah kembali (pop), paksa Dashboard untuk memuat ulang data dari SQLite
        if (mounted) {
          _loadData();
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
              color: accent.withValues(alpha: 0.3), // Diperbarui
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: accent.withValues(alpha: 0.2), // Diperbarui
              child: const Text('👑', style: TextStyle(fontSize: 35)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData!['username'],
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textCol),
                  ),
                  Text('Level $currentLevel Slayer',
                      style: TextStyle(color: textCol.withValues(alpha: 0.7))), // Diperbarui
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
                    'EXP: $currentExp / $targetExp',
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

  // WIDGET: Representasi Pohon Sakura (Streak)
  Widget _buildStreakTree(Color accent, Color textCol) {
    final bool isVacation = DatabaseHelper.instance.isVacationActive(userData!['vacation_until'] as String?);

    if (isVacation) {
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
              'Pohon sakuramu sedang tidur lelap hingga ${userData!['vacation_until']}',
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
        gradient: LinearGradient(colors: [accent.withValues(alpha: 0.4), Colors.white]), // Diperbarui
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Text('Pertumbuhan Sakura',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
          const SizedBox(height: 10),
          Icon(Icons.park, size: 80, color: userData!['current_streak'] > 0 ? Colors.green[300] : Colors.brown[200]),
          const SizedBox(height: 10),
          Text(
            '${userData!['current_streak']} Hari Tanpa Henti',
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
                  // Notch / Bar cozy indicator
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
                  
                  // Judul Bottom Sheet
                  const Text(
                    '🌸 Bangkitkan Grimoire Baru 🌸',
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
                  
                  // Kolom 1: Judul Buku / Grimoire
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

                  // Kolom 2: Total Halaman
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

                  // Kolom 3: Target Halaman Harian
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

                  // Tombol Bangkitkan Grimoire
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final title = titleController.text.trim();
                        final totalPages = int.parse(pagesController.text.trim());
                        final dailyTarget = int.parse(dailyTargetController.text.trim());

                        // Menyimpan data ke tabel books di SQLite dengan status ACTIVE
                        await DatabaseHelper.instance.insertBook({
                          'title': title,
                          'total_pages': totalPages,
                          'current_page': 0,
                          'target_days': 1, // Dummy stabilisator untuk skema lama
                          'daily_target_pages': dailyTarget,
                          'status': 'ACTIVE',
                        });

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
                        
                        // Memperbarui UI Dashboard dengan memicu penarikan data ulang
                        _loadData();
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
                      '✨ Bangkitkan Grimoire',
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
              Text('🛡️ ', style: TextStyle(fontSize: 22)),
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
              Text('🌸 ', style: TextStyle(fontSize: 22)),
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
              Text('✨ ', style: TextStyle(fontSize: 22)),
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
                await DatabaseHelper.instance.toggleBookStatus(book['id'], 'ACTIVE');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Buku "${book['title']}" telah diaktifkan!'),
                      backgroundColor: sakuraPink,
                    ),
                  );
                }
                _loadData();
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

  // LOGIKA: Cek Kondisi Darurat Revive Potion
  bool _isEmergencyState() {
    if (userData == null) return false;
    final int previousStreak = userData!['previous_streak'] ?? 0;
    final String? lastReviveDate = userData!['last_revive_date'];
    
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
              const Text('⚠️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Streak Terputus! (${userData!['previous_streak']} Hari)',
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
                // Check inventory
                final inventory = await DatabaseHelper.instance.getInventory();
                final potionQty = inventory['REVIVE_POTION'] ?? 0;

                if (potionQty > 0) {
                  final result = await DatabaseHelper.instance.useRevivePotion();
                  await _loadData();
                  if (mounted && result['status'] == 'SUCCESS') {
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
                  }
                } else {
                  // Navigate to Shop
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ShopScreen()),
                    ).then((_) => _loadData());
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