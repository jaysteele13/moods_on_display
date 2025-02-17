import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager{
  static final DatabaseManager instance = DatabaseManager._privateConstructor();
  static Database? _database;

  DatabaseManager._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = p.join(documentsDirectory.path, 'emotions.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // currently db accepts one key emotion per group of faces
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE images (
        id TEXT PRIMARY KEY,
        emotion TEXT NOT NULL
      )
    ''');
  }

 Future<int> insertImage(String id, String emotion) async {
    try {
      Database db = await instance.database;
      return await db.insert(
        'images',
        {
          'id': id,
          'emotion': emotion,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Error inserting image: $e");
      return -1; // Or handle error appropriately
    }
  }




  // Get all images with their emotions
  Future<List<Map<String, dynamic>>> getAllImages() async {
    Database db = await instance.database;
    return await db.query('images');
  }

  // Get images by album
  Future<List<Map<String, dynamic>>> getImagesByEmotion(String emotion) async {
    Database db = await instance.database;
    return await db.query(
      'images',
      where: 'emotion = ?',
      whereArgs: [emotion],
    );
  }



  Future<void> closeDatabase() async {
    Database db = await instance.database;
    await db.close();
  }
}
