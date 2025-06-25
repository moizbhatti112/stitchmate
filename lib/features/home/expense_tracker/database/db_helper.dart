import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the application documents directory
    final documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'trip_expenses.db');

    developer.log('Initializing database at path: $path');

    // Check if database exists
    bool exists = await databaseExists(path);
    developer.log('Database exists: $exists');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        developer.log('Database opened successfully');
        // Verify tables exist
        final tables = await db.query(
          'sqlite_master',
          where: 'type = ? AND name IN (?, ?)',
          whereArgs: ['table', 'trips', 'expenses'],
        );
        developer.log(
          'Existing tables: ${tables.map((t) => t['name']).toList()}',
        );
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    developer.log('Creating database tables for version: $version');
    await db.execute('''
      CREATE TABLE trips(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        destination TEXT NOT NULL,
        startDate TEXT NOT NULL,
        totalExpense REAL DEFAULT 0.0,
        currency TEXT NOT NULL DEFAULT 'USD',
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tripId INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (tripId) REFERENCES trips (id) ON DELETE CASCADE
      )
    ''');
    developer.log('Database tables created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    developer.log('Upgrading database from version $oldVersion to $newVersion');
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS expenses');
      await db.execute('DROP TABLE IF EXISTS trips');
      await _onCreate(db, newVersion);
    } else if (oldVersion < 4) {
      // Add currency column to trips table
      await db.execute(
        'ALTER TABLE trips ADD COLUMN currency TEXT NOT NULL DEFAULT "USD"',
      );
    }
  }

  // Trip operations
  Future<int> insertTrip(Map<String, dynamic> trip) async {
    final db = await database;
    developer.log('Inserting trip: $trip');
    final cleanTrip = Map<String, dynamic>.from(trip)
      ..removeWhere((key, value) => value == null);
    final id = await db.insert('trips', cleanTrip);
    developer.log('Trip inserted with id: $id');
    return id;
  }

  Future<List<Map<String, dynamic>>> getTrips() async {
    final db = await database;
    developer.log('Fetching all trips');
    final trips = await db.query('trips', orderBy: 'createdAt DESC');
    developer.log('Found ${trips.length} trips');
    return trips;
  }

  Future<void> updateTripExpense(int tripId, double totalExpense) async {
    final db = await database;
    developer.log('Updating trip $tripId total expense to $totalExpense');
    await db.update(
      'trips',
      {'totalExpense': totalExpense},
      where: 'id = ?',
      whereArgs: [tripId],
    );
  }

  Future<void> updateTrip(Map<String, dynamic> trip) async {
    final db = await database;
    developer.log('Updating trip: $trip');
    await db.update('trips', trip, where: 'id = ?', whereArgs: [trip['id']]);
  }

  Future<void> deleteTrip(int tripId) async {
    final db = await database;
    developer.log('Deleting trip with id: $tripId');
    await db.delete('trips', where: 'id = ?', whereArgs: [tripId]);
  }

  // Expense operations
  Future<int> insertExpense(Map<String, dynamic> expense) async {
    final db = await database;
    developer.log('Inserting expense: $expense');
    final id = await db.insert('expenses', expense);
    developer.log('Expense inserted with id: $id');
    return id;
  }

  Future<List<Map<String, dynamic>>> getExpensesByTrip(int tripId) async {
    final db = await database;
    developer.log('Fetching expenses for trip: $tripId');
    final expenses = await db.query(
      'expenses',
      where: 'tripId = ?',
      whereArgs: [tripId],
      orderBy: 'createdAt DESC',
    );
    developer.log('Found ${expenses.length} expenses for trip $tripId');
    return expenses;
  }

  Future<void> deleteExpense(int expenseId, int tripId) async {
    final db = await database;
    developer.log('Deleting expense: $expenseId for trip: $tripId');
    await db.delete('expenses', where: 'id = ?', whereArgs: [expenseId]);
  }

  Future<void> updateExpense(Map<String, dynamic> expense) async {
    final db = await database;
    developer.log('Updating expense: $expense');
    await db.update(
      'expenses',
      expense,
      where: 'id = ?',
      whereArgs: [expense['id']],
    );
  }
}
