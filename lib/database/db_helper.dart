
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/expense.dart';

class DBHelper {
  DBHelper._();

  static final DBHelper instance = DBHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String dbPath = await getDatabasesPath();

    String path = join(dbPath, 'expense_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL
          )
        ''');
      },
    );
  }

  // Insert Expense
  Future<int> insertExpense(Expense expense) async {
    final db = await database;

    return await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get All Expenses
  Future<List<Expense>> getExpenses() async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query('expenses', orderBy: 'id DESC');

    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  // Delete Expense
  Future<int> deleteExpense(int id) async {
    final db = await database;

    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
