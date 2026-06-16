import 'package:flutter/material.dart';
import 'database_helper.dart';

class GrimoireLibraryScreen extends StatefulWidget {
  const GrimoireLibraryScreen({super.key});

  @override
  State<GrimoireLibraryScreen> createState() => _GrimoireLibraryScreenState();
}

class _GrimoireLibraryScreenState extends State<GrimoireLibraryScreen> {
  List<Map<String, dynamic>> allBooks = [];
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
    final books = await DatabaseHelper.instance.getAllBooks();
    setState(() {
      allBooks = books;
      isLoading = false;
    });
  }

  Future<void> _toggleStatus(int bookId, String currentStatus) async {
    final newStatus = currentStatus == 'ACTIVE' ? 'BACKLOG' : 'ACTIVE';
    await DatabaseHelper.instance.toggleBookStatus(bookId, newStatus);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBeige,
      appBar: AppBar(
        backgroundColor: bgBeige,
        elevation: 0,
        iconTheme: const IconThemeData(color: warmBrown),
        title: const Text(
          'Pustaka Grimoire',
          style: TextStyle(
            color: warmBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: sakuraPink))
          : allBooks.isEmpty
              ? Center(
                  child: Text(
                    'Belum ada buku di pustakamu.',
                    style: TextStyle(color: warmBrown.withValues(alpha: 0.6)),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: allBooks.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final book = allBooks[index];
                    final int bookId = book['id'];
                    final String title = book['title'] ?? 'Tanpa Nama';
                    final int totalPages = book['total_pages'] ?? 1;
                    final int currentPage = book['current_page'] ?? 0;
                    final String status = book['status'] ?? 'ACTIVE';

                    final bool isCompleted = status == 'COMPLETED';
                    final bool isActive = status == 'ACTIVE';

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isCompleted 
                              ? Colors.green.withValues(alpha: 0.3)
                              : sakuraPink.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: sakuraPink.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCompleted 
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : sakuraPink.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              isCompleted ? '🏆' : '📖',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: warmBrown,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$currentPage/$totalPages halaman',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: warmBrown.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Action / Status
                          if (isCompleted)
                            const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 4),
                                Text(
                                  'Tamat',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  isActive ? 'Aktif' : 'Disimpan',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isActive ? Colors.pink : Colors.grey,
                                  ),
                                ),
                                Switch(
                                  value: isActive,
                                  activeThumbColor: sakuraPink,
                                  onChanged: (value) {
                                    _toggleStatus(bookId, status);
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
