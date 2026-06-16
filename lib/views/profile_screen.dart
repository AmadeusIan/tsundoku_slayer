import 'package:flutter/material.dart';
import '../viewmodels/profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel _viewModel;

  static const Color bgBeige = Color(0xFFF5F5DC);
  static const Color sakuraPink = Color(0xFFFFB7C5);
  static const Color warmBrown = Color(0xFF5D4037);

  @override
  void initState() {
    super.initState();
    // Inisialisasi Otak Lokal (ViewModel)
    _viewModel = ProfileViewModel();
    _viewModel.loadData();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Membungkus UI dengan ListenableBuilder agar merender ulang HANYA ketika ViewModel memberi aba-aba
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        // Layar Pemuatan
        if (_viewModel.isLoading || _viewModel.userData == null) {
          return const Scaffold(
            backgroundColor: bgBeige,
            body: Center(child: CircularProgressIndicator(color: sakuraPink)),
          );
        }

        return Scaffold(
          backgroundColor: bgBeige,
          appBar: AppBar(
            backgroundColor: bgBeige,
            elevation: 0,
            iconTheme: const IconThemeData(color: warmBrown),
            title: const Text(
              'Profil Slayer',
              style: TextStyle(
                color: warmBrown,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Avatar
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: sakuraPink.withValues(alpha: 0.5), width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: sakuraPink.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.workspace_premium, size: 60, color: Colors.amber),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _viewModel.username,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: warmBrown,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: sakuraPink.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Level ${_viewModel.currentLevel} Slayer',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bergabung sejak: ${_viewModel.formattedJoinedDate}',
                  style: TextStyle(
                    fontSize: 14,
                    color: warmBrown.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 32),

                // Stats Cards
                Row(
                  children: [
                    _buildStatCard('EXP', '${_viewModel.currentExp} / ${_viewModel.targetExp}', Icons.star, Colors.amber),
                    const SizedBox(width: 16),
                    _buildStatCard('Buku Tamat', '${_viewModel.completedBooksCount}', Icons.menu_book, sakuraPink),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('Streak Saat Ini', '${_viewModel.currentStreak} Hari', Icons.local_fire_department, Colors.deepOrange),
                    const SizedBox(width: 16),
                    _buildStatCard('Aktivitas Terakhir', _viewModel.lastEvaluationDate, Icons.calendar_today, Colors.blueAccent),
                  ],
                ),
                
                const SizedBox(height: 40),

                // --- TOMBOL WIPE AKUN ---
                InkWell(
                  onTap: () => _showWipeAccountDialog(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_forever, color: Colors.redAccent, size: 26),
                        const SizedBox(width: 10),
                        const Text(
                          'Wipe Akun & Mulai Baru',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // --- TOMBOL MODE CUTI ---
                InkWell(
                  onTap: () => _showVacationDialog(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF1A237E).withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.nights_stay, color: Color(0xFF1A237E), size: 26),
                        const SizedBox(width: 10),
                        const Text(
                          'Mode Istirahat (Cuti)',
                          style: TextStyle(
                            color: Color(0xFF1A237E),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sakuraPink.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: warmBrown.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: warmBrown,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: warmBrown.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWipeAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: bgBeige,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 28, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hancurkan Semua Sihir?',
                  style: TextStyle(color: warmBrown, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus seluruh Grimoire, level, dan barang di dalam tasmu? Pohon sakuramu akan ditanam ulang dari benih awal. Tindakan ini tidak bisa dibatalkan, King.',
            style: TextStyle(color: warmBrown.withValues(alpha: 0.8), height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: TextStyle(color: warmBrown.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F).withValues(alpha: 0.9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () async {
                // Menembakkan logika aksi di ViewModel
                await _viewModel.wipeAccountData();
                
                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sihir telah di-wipe. Selamat memulai petualangan baru! 🌸'),
                      backgroundColor: Color(0xFF5D4037),
                    ),
                  );
                }
              },
              child: const Text(
                'Ya, Ulang Awal',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showVacationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgBeige,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const Icon(Icons.nights_stay, size: 50, color: Color(0xFF1A237E)),
              const SizedBox(height: 10),
              const Text(
                'Bekukan Waktu',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tubuh dan pikiranmu butuh istirahat. Berapa lama kamu ingin membekukan waktu agar pohon sakuramu tidak layu?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: warmBrown.withValues(alpha: 0.8), height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _vacationOptionButton(context, 1),
                  _vacationOptionButton(context, 2),
                  _vacationOptionButton(context, 3),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _vacationOptionButton(BuildContext context, int days) {
    return ElevatedButton(
      onPressed: () async {
        // Menembakkan logika aksi di ViewModel
        await _viewModel.activateVacationMode(days);
        
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Waktu berhasil dibekukan selama $days hari. Selamat beristirahat! 🌙'),
              backgroundColor: const Color(0xFF1A237E),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A237E).withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      child: Text('$days Hari', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}