import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Membuat sistem Singleton agar database hanya dibuka satu kali
  static DatabaseHelper instance = DatabaseHelper.internal();
  static Database? _database;

  DatabaseHelper.internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tsundoku_slayer.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Menentukan lokasi penyimpanan file .db di perangkat
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Membuka database, versi 5 dengan migrasi onUpgrade
    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // Melakukan migrasi skema database dengan aman saat terjadi peningkatan versi
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN last_evaluation_date TEXT;');
      } catch (_) {
        // Kolom mungkin sudah ditambahkan
      }
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN previous_streak INTEGER DEFAULT 0;');
      } catch (_) {
        // Kolom mungkin sudah ditambahkan
      }
    }
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN last_read_date TEXT;');
      } catch (_) {
        // Kolom mungkin sudah ditambahkan
      }
    }
    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN vacation_until TEXT;');
      } catch (_) {
        // Kolom mungkin sudah ditambahkan
      }
    }
  }

  // Mengeksekusi rancangan tabel saat aplikasi pertama kali dijalankan
  Future _createDB(Database db, int version) async {
    
    // 1. Tabel Users (Profil & Gamifikasi)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL DEFAULT 'King',
        current_exp INTEGER DEFAULT 0,
        current_level INTEGER DEFAULT 1,
        current_streak INTEGER DEFAULT 0,
        previous_streak INTEGER DEFAULT 0,
        last_active_date TEXT,
        last_read_date TEXT,
        double_exp_end_time TEXT,
        vacation_start_date TEXT,
        vacation_end_date TEXT,
        vacation_cooldown_end TEXT,
        vacation_until TEXT,
        last_revive_date TEXT,
        last_evaluation_date TEXT
      )
    ''');

    // 2. Tabel Books (Manajemen Buku & Target)
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        total_pages INTEGER NOT NULL,
        current_page INTEGER DEFAULT 0,
        target_days INTEGER NOT NULL,
        status TEXT NOT NULL, 
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 3. Tabel Inventory (Toko & Item Player)
    await db.execute('''
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_code TEXT NOT NULL UNIQUE,
        quantity INTEGER DEFAULT 0
      )
    ''');

    // 4. Tabel Reading Sessions (Log Pomodoro & History)
    await db.execute('''
      CREATE TABLE reading_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER NOT NULL,
        session_date TEXT DEFAULT CURRENT_TIMESTAMP,
        duration_minutes INTEGER NOT NULL,
        pages_read INTEGER NOT NULL,
        exp_earned INTEGER NOT NULL,
        session_status TEXT NOT NULL,
        session_type TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES books(id)
      )
    ''');
  }

  // --- FUNGSI LOGIKA PENGGUNA ---

  Future<Map<String, dynamic>> getUserProfile() async {
    final db = await instance.database;
    
    // Mengecek apakah sudah ada data di dalam tabel 'users'
    final result = await db.query('users', limit: 1);
    
    if (result.isNotEmpty) {
      // Jika data sudah ada, kembalikan data tersebut
      return result.first;
    } else {
      // Jika tabel masih kosong (pertama kali buka aplikasi), 
      // suntikkan profil default
      final defaultUser = {
        'username': 'King',
        'current_exp': 0,
        'current_level': 1,
        'current_streak': 0,
        'previous_streak': 0,
      };
      
      await db.insert('users', defaultUser);
      return defaultUser;
    }
  }

  // --- FUNGSI LOGIKA CUTI (VACATION MODE) ---

  bool isVacationActive(String? vacationDate) {
    if (vacationDate == null) return false;
    try {
      final DateTime until = DateTime.parse(vacationDate);
      final DateTime now = DateTime.now();
      // Bandingkan tanpa mempedulikan jam
      final DateTime todayDate = DateTime(now.year, now.month, now.day);
      final DateTime vacationUntilDate = DateTime(until.year, until.month, until.day);
      
      return todayDate.compareTo(vacationUntilDate) <= 0;
    } catch (e) {
      return false;
    }
  }

  Future<void> activateVacationMode(int days) async {
    final db = await instance.database;
    final userResult = await db.query('users', limit: 1);
    if (userResult.isEmpty) return;

    final userId = userResult.first['id'] as int;
    final DateTime targetDate = DateTime.now().add(Duration(days: days));
    final String vacationUntil = targetDate.toIso8601String().substring(0, 10);

    await db.update(
      'users',
      {'vacation_until': vacationUntil},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // --- FUNGSI LOGIKA BUKU (GRIMOIRE) ---

  Future<int> insertBook(Map<String, dynamic> row) async {
    final db = await instance.database;
    final data = Map<String, dynamic>.from(row);
    if (!data.containsKey('created_at')) {
      data['created_at'] = DateTime.now().toIso8601String();
    }
    return await db.insert('books', data);
  }

  Future<List<Map<String, dynamic>>> getActiveBooks() async {
    final db = await instance.database;
    return await db.query(
      'books',
      where: 'status = ?',
      whereArgs: ['ACTIVE'],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllBooks() async {
    final db = await instance.database;
    return await db.query(
      'books',
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getBacklogBooks() async {
    final db = await instance.database;
    return await db.query(
      'books',
      where: 'status = ?',
      whereArgs: ['BACKLOG'],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> toggleBookStatus(int bookId, String newStatus) async {
    final db = await instance.database;
    return await db.update(
      'books',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  // --- FUNGSI LOGIKA MEMBACA & GAMIFIKASI ---

  int getTargetExp(int level) {
    return level * 100 + 50;
  }

  Future<Map<String, dynamic>> completeReadingSession({
    required int bookId,
    required int pagesRead,
  }) async {
    final db = await instance.database;
    int levelsGained = 0;
    Map<String, dynamic>? suggestedBook;

    await db.transaction((txn) async {
      // 1. Dapatkan info buku saat ini
      final bookResult = await txn.query(
        'books',
        columns: ['current_page', 'total_pages'],
        where: 'id = ?',
        whereArgs: [bookId],
      );
      if (bookResult.isEmpty) return;

      final book = bookResult.first;
      final int totalPages = book['total_pages'] as int;
      final int oldCurrentPage = book['current_page'] as int;

      // Hitung halaman baru, batasi maksimal total_pages
      int newCurrentPage = oldCurrentPage + pagesRead;
      String bookStatus = 'ACTIVE';
      if (newCurrentPage >= totalPages) {
        newCurrentPage = totalPages;
        bookStatus = 'COMPLETED';
      }

      // Update data buku
      await txn.update(
        'books',
        {
          'current_page': newCurrentPage,
          if (bookStatus == 'COMPLETED') 'status': bookStatus,
        },
        where: 'id = ?',
        whereArgs: [bookId],
      );

      // Hitung penambahan EXP (1 halaman = 10 EXP)
      final int expEarned = pagesRead * 10;

      // 2. Insert data ke tabel reading_sessions
      await txn.insert('reading_sessions', {
        'book_id': bookId,
        'session_date': DateTime.now().toIso8601String(),
        'duration_minutes': 25,
        'pages_read': pagesRead,
        'exp_earned': expEarned,
        'session_status': 'COMPLETED',
        'session_type': 'MANUAL',
      });

      // 3. Ambil profil user saat ini
      final userResult = await txn.query('users', limit: 1);
      if (userResult.isEmpty) return;

      final user = userResult.first;
      final int currentExp = user['current_exp'] as int? ?? 0;
      final int currentLevel = user['current_level'] as int? ?? 1;
      final int currentStreak = user['current_streak'] as int? ?? 0;
      final String? lastReadDate = user['last_read_date'] as String?;
      final String today = DateTime.now().toIso8601String().substring(0, 10);

      // Cek streak harian
      int newStreak = currentStreak;
      if (lastReadDate != today) {
        newStreak += 1;
      }

      // Hitung level baru dan sisa EXP dengan sistem progresif
      int totalExp = currentExp + expEarned;
      int newLevel = currentLevel;
      
      while (totalExp >= getTargetExp(newLevel)) {
        totalExp -= getTargetExp(newLevel);
        newLevel++;
        levelsGained++;
      }

      // Update data user
      await txn.update(
        'users',
        {
          'current_exp': totalExp,
          'current_level': newLevel,
          'current_streak': newStreak,
          'last_read_date': today,
        },
        where: 'id = ?',
        whereArgs: [user['id']],
      );

      // Pancingan Buku Baru
      if (bookStatus == 'COMPLETED') {
        final activeCountResult = await txn.rawQuery(
          'SELECT COUNT(*) as count FROM books WHERE status = "ACTIVE"'
        );
        int activeCount = Sqflite.firstIntValue(activeCountResult) ?? 0;
        
        if (activeCount == 0) {
          final backlogResult = await txn.rawQuery(
            'SELECT * FROM books WHERE status = "BACKLOG" ORDER BY RANDOM() LIMIT 1'
          );
          if (backlogResult.isNotEmpty) {
            suggestedBook = backlogResult.first;
          }
        }
      }
    });

    return {
      'levelsGained': levelsGained,
      'suggestedBook': suggestedBook,
    };
  }

  // --- FUNGSI LOGIKA TOKO & INVENTARIS ---

  Future<Map<String, dynamic>> buyItem({
    required String itemCode,
    required int price,
    required int maxLimit,
  }) async {
    final db = await instance.database;
    String status = 'FAILED';
    String message = '';

    await db.transaction((txn) async {
      // 1. Ambil data user saat ini untuk cek EXP
      final userResult = await txn.query('users', limit: 1);
      if (userResult.isEmpty) {
        message = 'Profil user tidak ditemukan.';
        return;
      }
      final user = userResult.first;
      final int currentExp = user['current_exp'] as int? ?? 0;

      if (currentExp < price) {
        message = 'EXP kamu tidak cukup. Kumpulkan lebih banyak mantra!';
        return;
      }

      // 2. Cek inventory saat ini
      final inventoryResult = await txn.query(
        'inventory',
        where: 'item_code = ?',
        whereArgs: [itemCode],
      );

      int currentQty = 0;
      if (inventoryResult.isNotEmpty) {
        currentQty = inventoryResult.first['quantity'] as int? ?? 0;
      }

      if (currentQty >= maxLimit) {
        message = 'Kapasitas maksimum untuk item ini telah tercapai ($maxLimit)!';
        return;
      }

      // 3. Kurangi EXP user
      final int newExp = currentExp - price;
      await txn.update(
        'users',
        {'current_exp': newExp},
        where: 'id = ?',
        whereArgs: [user['id']],
      );

      // 4. Update/Insert inventory
      if (inventoryResult.isEmpty) {
        await txn.insert('inventory', {
          'item_code': itemCode,
          'quantity': 1,
        });
      } else {
        await txn.update(
          'inventory',
          {'quantity': currentQty + 1},
          where: 'item_code = ?',
          whereArgs: [itemCode],
        );
      }

      status = 'SUCCESS';
      message = 'Pembelian berhasil! Item disimpan di dalam inventaris.';
    });

    return {'status': status, 'message': message};
  }

  Future<Map<String, int>> getInventory() async {
    final db = await instance.database;
    final results = await db.query('inventory');
    final Map<String, int> inventoryMap = {};
    for (var row in results) {
      final code = row['item_code'] as String;
      final qty = row['quantity'] as int? ?? 0;
      inventoryMap[code] = qty;
    }
    return inventoryMap;
  }

  // --- FUNGSI LOGIKA EVALUASI STREAK ---

  Future<String> evaluateDailyStreak() async {
    final db = await instance.database;
    String status = 'ALREADY_EVALUATED';

    await db.transaction((txn) async {
      // 1. Ambil data user
      final userResult = await txn.query('users', limit: 1);
      if (userResult.isEmpty) return;

      final user = userResult.first;
      final int userId = user['id'] as int;
      final String? lastEvaluationDate = user['last_evaluation_date'] as String?;
      final int currentStreak = user['current_streak'] as int? ?? 0;

      final String today = DateTime.now().toIso8601String().substring(0, 10);
      final String yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);

      // Jika sudah dievaluasi hari ini, lewati
      if (lastEvaluationDate == today) {
        status = 'ALREADY_EVALUATED';
        return;
      }

      // Jika evaluasi pertama kali (baru instal / belum ada tanggal evaluasi)
      if (lastEvaluationDate == null) {
        await txn.update(
          'users',
          {'last_evaluation_date': today},
          where: 'id = ?',
          whereArgs: [userId],
        );
        status = 'ALREADY_EVALUATED';
        return;
      }

      // --- Cek Status Cuti (Vacation Mode) ---
      final String? vacationUntil = user['vacation_until'] as String?;
      
      if (instance.isVacationActive(vacationUntil)) {
        await txn.update(
          'users',
          {'last_evaluation_date': today},
          where: 'id = ?',
          whereArgs: [userId],
        );
        status = 'VACATION_ACTIVE';
        return;
      } else if (vacationUntil != null) {
        // Cuti sudah kedaluwarsa, hapus dari database
        await txn.update(
          'users',
          {'vacation_until': null},
          where: 'id = ?',
          whereArgs: [userId],
        );
      }

      // 2. Cek apakah ada sesi membaca kemarin
      final sessions = await txn.query(
        'reading_sessions',
        where: "session_date LIKE ? AND pages_read > 0 AND session_status = 'COMPLETED'",
        whereArgs: ['$yesterday%'],
      );

      if (sessions.isNotEmpty) {
        // Skenario A: Membaca Kemarin
        await txn.update(
          'users',
          {
            'last_evaluation_date': today,
          },
          where: 'id = ?',
          whereArgs: [userId],
        );
        status = 'STREAK_SAFE';
      } else {
        // Skenario B: Tidak Membaca Kemarin
        // Cek kuantitas Streak Shield di inventaris
        final inventoryResult = await txn.query(
          'inventory',
          where: "item_code = 'STREAK_SHIELD'",
        );
        int shieldQty = 0;
        if (inventoryResult.isNotEmpty) {
          shieldQty = inventoryResult.first['quantity'] as int? ?? 0;
        }

        if (shieldQty > 0) {
          // Kurangi shield, pertahankan streak
          await txn.update(
            'inventory',
            {'quantity': shieldQty - 1},
            where: "item_code = 'STREAK_SHIELD'",
          );
          await txn.update(
            'users',
            {'last_evaluation_date': today},
            where: 'id = ?',
            whereArgs: [userId],
          );
          status = 'SHIELD_USED';
        } else {
          // Reset streak & catat last_revive_date (simpan streak lama)
          await txn.update(
            'users',
            {
              'previous_streak': currentStreak,
              'current_streak': 0,
              'last_revive_date': today,
              'last_evaluation_date': today,
            },
            where: 'id = ?',
            whereArgs: [userId],
          );
          status = 'STREAK_BROKEN';
        }
      }
    });

    return status;
  }

  Future<Map<String, dynamic>> useRevivePotion() async {
    final db = await instance.database;
    String status = 'FAILED';
    String message = '';

    await db.transaction((txn) async {
      final userResult = await txn.query('users', limit: 1);
      if (userResult.isEmpty) {
        message = 'Profil user tidak ditemukan.';
        return;
      }
      final user = userResult.first;
      final int previousStreak = user['previous_streak'] as int? ?? 0;

      final inventoryResult = await txn.query(
        'inventory',
        where: "item_code = 'REVIVE_POTION'",
      );

      int potionQty = 0;
      if (inventoryResult.isNotEmpty) {
        potionQty = inventoryResult.first['quantity'] as int? ?? 0;
      }

      if (potionQty > 0) {
        // Kurangi potion
        await txn.update(
          'inventory',
          {'quantity': potionQty - 1},
          where: "item_code = 'REVIVE_POTION'",
        );
        // Kembalikan streak
        await txn.update(
          'users',
          {
            'current_streak': previousStreak,
            'previous_streak': 0,
          },
          where: 'id = ?',
          whereArgs: [user['id']],
        );
        status = 'SUCCESS';
        message = 'Ramuan berhasil digunakan! Streak telah dipulihkan.';
      } else {
        message = 'Kamu tidak memiliki Revive Potion.';
      }
    });

    return {'status': status, 'message': message};
  }
  // --- FUNGSI DARURAT: WIPE AKUN ---
  Future<void> wipeAccountData() async {
    final db = await instance.database;
    
    // Menjalankan transaksi massal agar aman dan tidak korup
    await db.transaction((txn) async {
      await txn.delete('books');
      await txn.delete('reading_sessions');
      await txn.delete('inventory');

      // Mengembalikan status karakter ke titik awal
      await txn.update('users', {
        'current_level': 1,
        'current_exp': 0,
        'current_streak': 0,
        'last_evaluation_date': null,
        'last_read_date': null,
        'previous_streak': 0,
      });
    });
  }
}

