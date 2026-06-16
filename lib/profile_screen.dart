import 'package:flutter/material.dart';
import 'database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  int completedBooksCount = 0;
  bool isLoading = true;

  static const Color bgBeige = Color(0xFFF5F5DC);
  static const Color sakuraPink = Color(0xFFFFB7C5);
  static const Color warmBrown = Color(0xFF5D4037);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.getUserProfile();
    final allBooks = await DatabaseHelper.instance.getAllBooks();
    
    int completedCount = allBooks.where((b) => b['status'] == 'COMPLETED').length;

    setState(() {
      userData = data;
      completedBooksCount = completedCount;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || userData == null) {
      return const Scaffold(
        backgroundColor: bgBeige,
        body: Center(child: CircularProgressIndicator(color: sakuraPink)),
      );
    }

    final int currentLevel = userData!['current_level'] ?? 1;
    final int currentExp = userData!['current_exp'] ?? 0;
    final int targetExp = DatabaseHelper.instance.getTargetExp(currentLevel);
    final int currentStreak = userData!['current_streak'] ?? 0;
    
    final String joinDate = userData!['last_evaluation_date'] ?? 'Belum ada data';

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
                  child: Text('👑', style: TextStyle(fontSize: 60)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userData!['username'] ?? 'King',
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
                'Level $currentLevel Slayer',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Stats Cards
            Row(
              children: [
                _buildStatCard('EXP', '$currentExp / $targetExp', Icons.star, Colors.amber),
                const SizedBox(width: 16),
                _buildStatCard('Buku Tamat', '$completedBooksCount', Icons.menu_book, sakuraPink),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard('Streak Saat Ini', '$currentStreak Hari', Icons.local_fire_department, Colors.deepOrange),
                const SizedBox(width: 16),
                _buildStatCard('Aktivitas Terakhir', joinDate, Icons.calendar_today, Colors.blueAccent),
              ],
            ),
          ],
        ),
      ),
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
}
