import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/fruit_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fruits_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    print("db Path....$dbPath");
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE fruits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        note TEXT
      )
    ''');

    // Seed initial sample fruit items in INR (₹)
    final sampleFruits = [
      FruitItem(
        name: 'Honeycrisp Apples',
        price: 140.00,
        quantity: 6,
        note: 'Crisp, juicy, and sweet.',
      ),
      FruitItem(
        name: 'Cavendish Bananas',
        price: 60.00,
        quantity: 12,
        note: 'Rich in potassium and natural energy.',
      ),
      FruitItem(
        name: 'Fresh Strawberries',
        price: 180.00,
        quantity: 2,
        note: 'Sweet organic berries packed with Vitamin C.',
      ),
      FruitItem(
        name: 'Hass Avocado',
        price: 150.00,
        quantity: 3,
        note: 'Creamy texture, high in healthy fats.',
      ),
      FruitItem(
        name: 'Alphonso Mangoes',
        price: 250.00,
        quantity: 4,
        note: 'King of fruits. Extremely sweet & aromatic.',
      ),
      FruitItem(
        name: 'Valencia Oranges',
        price: 80.00,
        quantity: 5,
        note: 'Juicy citrus fruit great for fresh juice.',
      ),
      FruitItem(
        name: 'Organic Blueberries',
        price: 290.00,
        quantity: 1,
        note: 'Rich in antioxidants.',
      ),
      FruitItem(
        name: 'Red Seedless Grapes',
        price: 120.00,
        quantity: 2,
        note: 'Sweet and crunchy snacking grapes.',
      ),
    ];

    for (var fruit in sampleFruits) {
      await db.insert('fruits', fruit.toMap());
    }
  }

  Future<int> insertFruit(FruitItem fruit) async {
    final db = await instance.database;
    print("insertFruit......${fruit.toMap()}");
    return await db.insert('fruits', fruit.toMap());
  }

  Future<List<FruitItem>> getFruits() async {
    final db = await instance.database;
    final result = await db.query('fruits', orderBy: 'name ASC');
    return result.map((json) => FruitItem.fromMap(json)).toList();
  }

  Future<int> updateFruit(FruitItem fruit) async {
    final db = await instance.database;
    return await db.update(
      'fruits',
      fruit.toMap(),
      where: 'id = ?',
      whereArgs: [fruit.id],
    );
  }

  Future<int> deleteFruit(int id) async {
    final db = await instance.database;
    return await db.delete('fruits', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
