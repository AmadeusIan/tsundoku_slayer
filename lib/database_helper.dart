import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Membuat sistem Singleton agar database hanya dibuka satu kali
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tsundoku_slayer.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Menentukan lokasi penyimpanan file .db di perangkat
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Membuka database, versi 1
    return await openDatabase(path, version: 1, onCreate: _createDB);
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
        last_active_date TEXT,
        double_exp_end_time TEXT,
        vacation_start_date TEXT,
        vacation_end_date TEXT,
        vacation_cooldown_end TEXT,
        last_revive_date TEXT
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
      };
      
      await db.insert('users', defaultUser);
      return defaultUser;
    }
  }
}

