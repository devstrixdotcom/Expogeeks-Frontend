import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Local SQLite database for offline user authentication (login + signup).
class DBHelper {
  DBHelper._ctor();
  static final DBHelper instance = DBHelper._ctor();

  static const String _dbName = 'event_pro.db';
  static const int _dbVersion = 1;

  static const String usersTable = 'users';

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $usersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  /// Hash a password with SHA-256 so plain text is never stored.
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// Returns true if a user with [email] already exists.
  Future<bool> emailExists(String email) async {
    final db = await database;
    final rows = await db.query(
      usersTable,
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Creates a new user. Returns the new row id, or `-1` if the email
  /// is already registered.
  Future<int> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final db = await database;
    final normalizedEmail = email.trim().toLowerCase();

    if (await emailExists(normalizedEmail)) {
      return -1;
    }

    return db.insert(usersTable, {
      'name': name.trim(),
      'email': normalizedEmail,
      'phone': phone.trim(),
      'password': _hashPassword(password),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Validates credentials. Returns the user row on success, or `null`.
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    final db = await database;
    final rows = await db.query(
      usersTable,
      where: 'email = ? AND password = ?',
      whereArgs: [email.trim().toLowerCase(), _hashPassword(password)],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }
}
