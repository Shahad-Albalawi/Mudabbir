import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  LocalDatabase._privateConstructor();
  static final LocalDatabase instance = LocalDatabase._privateConstructor();

  static Database? _database;
  String? _currentUserId;

  Future<Database> get database async {
    if (_database == null) {
      throw Exception("Database not initialized. Call initForUser() first.");
    }
    return _database!;
  }

  /// Release the open database (e.g. after logout when guest mode is off).
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      _currentUserId = null;
    }
  }

  /// Initialize DB after registration/login with a unique identifier like an email.
  Future<void> initForUser(String userIdentifier) async {
    if (_currentUserId == userIdentifier && _database != null) {
      return;
    }
    await close();
    final dbName =
        '${userIdentifier.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_finance.db';
    final path = join(await getDatabasesPath(), dbName);

    _database = await openDatabase(
      path,
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
        await _createAuditTables(db);
      },
    );
    _currentUserId = userIdentifier;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('PRAGMA foreign_keys = ON');
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS category_budgets');
      await db.execute('DROP TABLE IF EXISTS app_notes');
      await db.execute('DROP TABLE IF EXISTS app_tasks');
    }
    if (oldVersion < 4) {
      await db.execute(
        'ALTER TABLE transactions ADD COLUMN is_recurring INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE transactions ADD COLUMN recurrence_interval TEXT',
      );
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE goals ADD COLUMN image_path TEXT');
      await db.execute(
        'ALTER TABLE goals ADD COLUMN is_completed INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute('ALTER TABLE goals ADD COLUMN completed_at TEXT');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS goal_contributions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          goal_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          contributed_at TEXT NOT NULL,
          note TEXT,
          FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 6) {
      await db.execute(
        'ALTER TABLE transactions ADD COLUMN updated_at TEXT',
      );
    }
  }

  /// Creates all the necessary tables for the financial app.
  Future _onCreate(Database db, int version) async {
    // Enable foreign key support
    await db.execute('PRAGMA foreign_keys = ON');

    // --- Create tables ---
    await db.execute('''
    CREATE TABLE accounts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      balance REAL NOT NULL DEFAULT 0.0
    )
  ''');

    await db.execute('''
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      type TEXT NOT NULL, -- 'income' or 'expense'
      UNIQUE(name, type)
    )
  ''');

    await db.execute('''
    CREATE TABLE goals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      target REAL NOT NULL,
      current_amount REAL NOT NULL DEFAULT 0.0,
      type TEXT NOT NULL,
      start_date TEXT NOT NULL,
      end_date TEXT NOT NULL,
      image_path TEXT,
      is_completed INTEGER NOT NULL DEFAULT 0,
      completed_at TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE goal_contributions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      goal_id INTEGER NOT NULL,
      amount REAL NOT NULL,
      contributed_at TEXT NOT NULL,
      note TEXT,
      FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
      CREATE TABLE challenges (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      start_date TEXT NOT NULL,
      end_date TEXT NOT NULL,
      status TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      type TEXT NOT NULL, -- 'income' or 'expense'
      notes TEXT,
      account_id INTEGER NOT NULL,
      category_id INTEGER NOT NULL,
      is_recurring INTEGER NOT NULL DEFAULT 0,
      recurrence_interval TEXT,
      updated_at TEXT,
      FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE,
      FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
    )
  ''');

    await db.execute('''
    CREATE TABLE budgets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      amount REAL NOT NULL,
      start_date TEXT NOT NULL,
      end_date TEXT NOT NULL,
      account_id INTEGER NOT NULL,
      FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
    )
  ''');

    await _createAuditTables(db);

    // --- Insert default data ---

    // Default Accounts
    await db.insert('accounts', {'name': 'النقدية', 'balance': 0.0});
    await db.insert('accounts', {'name': 'البنك', 'balance': 0.0});

    // Income Categories
    final incomeCategories = ['راتب', 'مكافأة', 'هبه', 'اخرى'];
    for (var name in incomeCategories) {
      await db.insert('categories', {'name': name, 'type': 'income'});
    }

    // Expense Categories
    final expenseCategories = [
      'طعام',
      'نقل',
      'تسوق',
      'فواتير',
      'صحة',
      'ترفيه',
      'اخرى',
    ];
    for (var name in expenseCategories) {
      await db.insert('categories', {'name': name, 'type': 'expense'});
    }
  }

  Future<void> _createAuditTables(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS action_audit_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      action TEXT NOT NULL,
      status TEXT NOT NULL, -- preview | confirmed | cancelled | executed | undone | failed
      payload TEXT,
      created_at TEXT NOT NULL
    )
  ''');
  }
}
