import 'package:flutter/material.dart';
import '../viewmodels/grimoire_view_model.dart';

class GrimoireLibraryScreen extends StatefulWidget {
  const GrimoireLibraryScreen({super.key});

  @override
  State<GrimoireLibraryScreen> createState() => _GrimoireLibraryScreenState();
}

class _GrimoireLibraryScreenState extends State<GrimoireLibraryScreen> {
  late final GrimoireViewModel _viewModel;

  static const Color bgBeige = Color(0xFFF5F5DC);
  static const Color sakuraPink = Color(0xFFFFB7C5);
  static const Color warmBrown = Color(0xFF5D4037);

  @override
  void initState() {
    super.initState();
    _viewModel = GrimoireViewModel();
    _viewModel.loadBooks();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // WIDGET: Form Tambah Buku (Bottom Sheet)
  void _showAddBookSheet() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final pagesController = TextEditingController();
    final dailyTargetController = TextEditingController();

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
                    '🌸 Simpan Grimoire ke Pustaka 🌸',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: warmBrown,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  TextFormField(
                    controller: titleController,
                    style: const TextStyle(color: warmBrown),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.auto_stories, color: sakuraPink),
                      labelText: 'Judul Buku',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    validator: (v) => v!.isEmpty ? 'Judul tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: pagesController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: warmBrown),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.layers, color: sakuraPink),
                      labelText: 'Total Halaman',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    validator: (v) => v!.isEmpty ? 'Total halaman wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: dailyTargetController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: warmBrown),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.menu_book, color: sakuraPink),
                      labelText: 'Target Halaman Harian',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    validator: (v) => v!.isEmpty ? 'Target harian wajib diisi' : null,
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await _viewModel.addBook(
                          titleController.text.trim(),
                          int.parse(pagesController.text.trim()),
                          int.parse(dailyTargetController.text.trim()),
                        );
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sakuraPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Simpan ke Rak Antrean', style: TextStyle(fontWeight: FontWeight.bold)),
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

  // WIDGET: Dialog Update Halaman Cepat
  void _showUpdateProgressDialog(Map<String, dynamic> book) {
    final formKey = GlobalKey<FormState>();
    final pagesController = TextEditingController();
    final int remainingPages = (book['total_pages'] ?? 1) - (book['current_page'] ?? 0);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: bgBeige,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(book['title'] ?? 'Grimoire', style: const TextStyle(color: warmBrown, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Berapa halaman yang kamu baca hari ini di luar sesi Timer?', 
                  style: TextStyle(color: warmBrown, fontSize: 13)),
                const SizedBox(height: 8),
                Text('Sisa: $remainingPages halaman', style: TextStyle(color: warmBrown.withValues(alpha: 0.7), fontSize: 12)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: pagesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.bookmark_add, color: sakuraPink),
                    labelText: 'Jumlah Halaman',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Wajib diisi';
                    final val = int.tryParse(v);
                    if (val == null || val <= 0) return 'Tidak valid';
                    if (val > remainingPages) return 'Melebihi sisa buku';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: warmBrown.withValues(alpha: 0.6))),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final pages = int.parse(pagesController.text.trim());
                  final suggestedBook = await _viewModel.updateReadingProgress(book['id'], pages);
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (suggestedBook != null) {
                      _showPromoteBacklogDialog(suggestedBook);
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: sakuraPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Catat Progress'),
            ),
          ],
        );
      },
    );
  }

  // WIDGET: Dialog Pancingan Backlog
  void _showPromoteBacklogDialog(Map<String, dynamic> book) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: bgBeige,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: const Row(
            children: [
              Icon(Icons.auto_awesome, color: warmBrown, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text('Perjalanan Baru?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: warmBrown)),
              ),
            ],
          ),
          content: Text(
            'Satu perjalanan telah usai! Maukah kamu mulai membaca "${book['title']}" sekarang?',
            style: TextStyle(fontSize: 14, color: warmBrown.withValues(alpha: 0.9)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Nanti Saja', style: TextStyle(color: warmBrown.withValues(alpha: 0.7))),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                // Status saat ini BACKLOG, jadi fungsi toggleStatus akan mengubahnya jadi ACTIVE
                await _viewModel.toggleStatus(book['id'], 'BACKLOG');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Buku "${book['title']}" telah diaktifkan!'), backgroundColor: sakuraPink),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: sakuraPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Aktifkan Grimoire'),
            ),
          ],
        );
      },
    );
  }

  // BUILDER: Render Rak Buku
  Widget _buildBookList(List<Map<String, dynamic>> books, String emptyMessage) {
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories, size: 80, color: warmBrown.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(color: warmBrown.withValues(alpha: 0.6), fontStyle: FontStyle.italic)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: books.length,
      separatorBuilder: (context, index) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        final book = books[index];
        final int bookId = book['id'];
        final String title = book['title'] ?? 'Tanpa Nama';
        final int totalPages = book['total_pages'] ?? 1;
        final int currentPage = book['current_page'] ?? 0;
        final String status = book['status'] ?? 'ACTIVE';

        final bool isCompleted = status == 'COMPLETED';
        final bool isActive = status == 'ACTIVE';
        
        final double progress = (currentPage / totalPages).clamp(0.0, 1.0);

        return Dismissible(
          key: Key('book_$bookId'),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: bgBeige,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text("Hapus Grimoire?", style: TextStyle(color: warmBrown, fontWeight: FontWeight.bold)),
                  content: const Text("Tindakan ini akan membakar buku dan menghapus seluruh catatan membacanya secara permanen. Lanjutkan?"),
                  actions: <Widget>[
                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Batal")),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Bakar Buku"),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) => _viewModel.deleteBook(bookId),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.local_fire_department, color: Colors.white, size: 36),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted ? Colors.green.withValues(alpha: 0.3) : sakuraPink.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(color: sakuraPink.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green.withValues(alpha: 0.15) : sakuraPink.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(isCompleted ? Icons.emoji_events : Icons.menu_book, size: 24, color: isCompleted ? Colors.green : const Color(0xFFFFB7C5)),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: warmBrown), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      // Progress Bar
                      Stack(
                        children: [
                          Container(height: 6, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                          FractionallySizedBox(
                            widthFactor: progress == 0 ? 0.02 : progress,
                            child: Container(height: 6, decoration: BoxDecoration(color: isCompleted ? Colors.green : sakuraPink, borderRadius: BorderRadius.circular(4))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('$currentPage/$totalPages halaman', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: warmBrown.withValues(alpha: 0.8))),
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
                      Text('Tamat', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  )
                else
                  Row(
                    children: [
                      // Tombol Update Manual
                      IconButton(
                        icon: const Icon(Icons.edit_note, color: sakuraPink),
                        onPressed: () => _showUpdateProgressDialog(book),
                        tooltip: 'Catat Halaman',
                      ),
                      // Switch Aktif/Backlog
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(isActive ? 'Aktif' : 'Antre', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.pink : Colors.grey)),
                          Switch(
                            value: isActive,
                            activeThumbColor: sakuraPink,
                            onChanged: (value) => _viewModel.toggleStatus(bookId, status),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bgBeige,
        appBar: AppBar(
          backgroundColor: bgBeige,
          elevation: 0,
          iconTheme: const IconThemeData(color: warmBrown),
          title: const Text('Pustaka Grimoire', style: TextStyle(color: warmBrown, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            labelColor: sakuraPink,
            unselectedLabelColor: warmBrown,
            indicatorColor: sakuraPink,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.menu_book), text: 'Rak Aktif'),
              Tab(icon: Icon(Icons.inventory_2), text: 'Antrean'),
              Tab(icon: Icon(Icons.emoji_events), text: 'Tamat'),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator(color: sakuraPink));
            }
            return TabBarView(
              children: [
                _buildBookList(_viewModel.activeBooks, 'Belum ada buku sihir yang sedang aktif dipelajari.'),
                _buildBookList(_viewModel.backlogBooks, 'Gudang belakang kosong. Semua buku sedang dibaca!'),
                _buildBookList(_viewModel.completedBooks, 'Belum ada buku yang berhasil ditamatkan. Terus berjuang!'),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: sakuraPink,
          onPressed: _showAddBookSheet,
          tooltip: 'Simpan Grimoire Baru',
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
