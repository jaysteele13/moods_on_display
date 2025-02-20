import 'dart:async';
import 'dart:io';
import 'package:moods_on_display/utils/constants.dart';
import 'package:moods_on_display/utils/types.dart';
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
      id TEXT PRIMARY KEY NOT NULL,
      emotion TEXT NOT NULL
    )
  ''');
}

 Future<int> insertImage(String id, String emotion) async {


    const validEmotions = EMOTIONS.list;
    if (!validEmotions.contains(emotion)) {
      throw Exception('Invalid emotion');
    }

    try {
      print('trying to add ${id}');
      Database db = await instance.database;
      
      int result = await db.insert(
        'images',
        {
          'id': id,
          'emotion': emotion,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print("Inserted Image: ID=$id, Emotion=$emotion");
      return result;
      
    } catch (e) {
      print("Error inserting image: $e");
      return -1; // Or handle error appropriately
    }
  }

  // Get all images with their emotions
  Future<List<Map<String, dynamic>>> getAllImages() async {
    print('attempt to get ALL images');
    Database db = await instance.database;
    return await db.query('images');
  }

Future<List<EmotionPointer>> getImagesByEmotion(String emotion) async {
  print('attempt to get images');
  Database db = await instance.database;
  // Query the database for records
  final result = await db.query(
    'images',
    where: 'emotion = ?',
    whereArgs: [emotion],
  );

  // Map the result to List<FilePathPointer>
  return result.map((map) => EmotionPointer.fromMap(map)).toList();
}



Future<void> deleteDatabaseFile() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/emotions.db';
    final file = File(dbPath);

    if (await file.exists()) {
      await file.delete();
      print("Database deleted successfully.");
    } else {
      print("Database file not found.");
    }
  } catch (e) {
    print("Error deleting database: $e");
  }
}


  Future<void> closeDatabase() async {
    Database db = await instance.database;
    await db.close();
  }
}
