import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  static BackupService get instance => _instance;

  Database? _database;
  final Logger _logger = Logger();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'kilele_pos.db');

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _createTables,
      );

      _logger.i('Database initialized successfully');
      return _database!;
    } catch (e) {
      _logger.e('Database initialization error: $e');
      rethrow;
    }
  }

  Future<void> _createTables(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        barcode TEXT,
        category TEXT,
        image_url TEXT,
        cost_price REAL,
        min_stock INTEGER,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        subtotal REAL NOT NULL,
        tax REAL NOT NULL,
        discount REAL DEFAULT 0,
        total REAL NOT NULL,
        payment_method TEXT NOT NULL,
        payment_reference TEXT,
        customer_phone TEXT,
        customer_name TEXT,
        cashier_id TEXT NOT NULL,
        cashier_name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        status TEXT DEFAULT 'completed',
        etims_receipt_number TEXT,
        etims_signature TEXT,
        is_etims_submitted INTEGER DEFAULT 0
      )
    ''');

    // Transaction items table
    await db.execute('''
      CREATE TABLE transaction_items (
        id TEXT PRIMARY KEY,
        transaction_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        discount REAL DEFAULT 0,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id)
      )
    ''');

    // Pending eTIMS submissions
    await db.execute('''
      CREATE TABLE pending_etims (
        id TEXT PRIMARY KEY,
        transaction_id TEXT NOT NULL,
        transaction_data TEXT NOT NULL,
        error_message TEXT,
        retry_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id)
      )
    ''');

    _logger.i('Database tables created successfully');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
