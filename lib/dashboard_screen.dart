import 'package:flutter/material.dart';
import 'database_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.getUserProfile();
    setState(() {
      userData = data;
      isLoading = false;
    });
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
                          onPressed: () {},
                          child: const Text('Lihat Semua', style: TextStyle(color: Colors.pink)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Placeholder untuk buku
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5), // Diperbarui
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sakuraPink.withValues(alpha: 0.5), width: 2), // Diperbarui
                      ),
                      child: const Center(
                        child: Text(
                          'Belum ada buku sihir yang aktif...\nKetuk tombol + untuk menambah buku',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.brown, fontStyle: FontStyle.italic),
                        ),
                      ),
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
          // Navigasi tambah buku nanti di sini
        },
      ),
    );
  }

  // WIDGET: Kartu Profil Character
  Widget _buildProfileCard(Color accent, Color textCol) {
    double expProgress = (userData!['current_exp'] % 100) / 100; 
    if (expProgress == 0) expProgress = 0.02;

    return Container(
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
                Text('Level ${userData!['current_level']} Slayer',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Representasi Pohon Sakura (Streak)
  Widget _buildStreakTree(Color accent, Color textCol) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [accent.withValues(alpha: 0.4), Colors.white]), // Diperbarui
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Text('🌸 Pertumbuhan Sakura 🌸',
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
}