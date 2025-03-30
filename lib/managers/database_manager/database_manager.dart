import 'dart:async';
import 'dart:io';
import 'package:moods_on_display/managers/services/services.dart';
import 'package:moods_on_display/utils/constants.dart';
import 'package:moods_on_display/utils/types.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseManager{
  final GetDirectoryService getDirectoryService;
  DatabaseManager({required this.getDirectoryService});

  static final DatabaseManager instance = DatabaseManager._privateConstructor(GetDirectoryService());
  static Database? _database;

  DatabaseManager._privateConstructor(this.getDirectoryService);

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getDirectoryService.getCurrentDirectory();
    String path = p.join(documentsDirectory.path, 'emotions.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

 Future<void> _onCreate(Database db, int version) async {
  await db.execute('''
    CREATE TABLE images (
      id TEXT PRIMARY KEY NOT NULL, 
      emotion TEXT NOT NULL
    );
  ''');

  await db.execute('''
    CREATE TABLE bounding_boxes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      emotion_id TEXT NOT NULL, 
      emotion TEXT NOT NULL,
      x INTEGER NOT NULL,
      y INTEGER NOT NULL,
      width INTEGER NOT NULL,
      height INTEGER NOT NULL,
      FOREIGN KEY (emotion_id) REFERENCES images(id) ON DELETE CASCADE
    );
  ''');

 await db.execute('''
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    has_updated_profile BOOLEAN NOT NULL DEFAULT 0
  );
''');

  // 2. Initialize default user (with has_updated_profile = false)
await db.execute('''
    INSERT OR IGNORE INTO users (id, name, has_updated_profile) 
    VALUES (1, 'Guest', 0)
  ''');
}

// 3. Updated function to track profile updates
Future<int> updateDefaultUser(String name) async {
  Database db = await instance.database;
  return await db.update(
    'users',
    {
      'name': name,
      'has_updated_profile': 1, // Mark as updated
    },
    where: 'id = ?',
    whereArgs: [1],
  );
}

// 4. New function to check if profile was updated
Future<bool> hasUserUpdatedProfile() async {
  Database db = await instance.database;
  final result = await db.query(
    'users',
    columns: ['has_updated_profile'],
    where: 'id = ?',
    whereArgs: [1],
  );
  return result.isNotEmpty && result.first['has_updated_profile'] == 1;
}

Future<String> getDefaultUser() async {
  Database db = await instance.database;
  List<Map<String, dynamic>> result = await db.query(
    'users',
    where: 'id = ?',
    whereArgs: [1],  // Targeting the default user with id = 1
  );

  if (result.isNotEmpty) {
    return result.first['name'] as String;
  } else {
    throw Exception('No default user found');
  }
}


Future<int> insertBoundingBoxes(
  String emotionPointer, // FK to `images.id`
  List<EmotionBoundingBox> boundingBoxes,
) async {
  const validEmotions = EMOTIONS.list;

  if (boundingBoxes.isEmpty) {
    throw Exception('Bounding box list is empty');
  }

  try {
    print('Trying to add ${boundingBoxes.length} bounding boxes');
    Database db = await instance.database;
    Batch batch = db.batch(); // Use a batch transaction for efficiency

    for (EmotionBoundingBox ebbx in boundingBoxes) {
      if (!validEmotions.contains(ebbx.emotion)) {
        throw Exception('Invalid emotion: ${ebbx.emotion}');
      }

      batch.insert(
        'bounding_boxes',
        {
          'emotion_id': emotionPointer,
          'emotion': ebbx.emotion,
          'x': ebbx.boundingBox.x, // No need for `ebb.boundingBox.x`, just `ebb.x`
          'y': ebbx.boundingBox.y,
          'width': ebbx.boundingBox.width,
          'height': ebbx.boundingBox.height,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(); // Execute all inserts in one go

    print("Inserted ${boundingBoxes.length} bounding boxes for Image ID: $emotionPointer");
    return boundingBoxes.length;
  } catch (e) {
    print("Error inserting bounding boxes: $e");
    return -1;
  }
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

Future<List<EmotionBoundingBox>> getEmotionBoundingBoxesByPointer(String pointer) async {
  print('attempt to get bounding boxes');
  Database db = await instance.database;
  // Query the database for records
  final result = await db.query(
    'bounding_boxes',
    where: 'emotion_id = ?',
    whereArgs: [pointer],
  );

  // Map the result to List<FilePathPointer>
  return result.map((map) => EmotionBoundingBox.fromMap(map)).toList();
}

Future<void> deleteImageRecords(List<String> records) async {
  Database db = await instance.database;

  for (String record in records) {
    // Check if the record exists in the database
    List<Map<String, dynamic>> existingRecord = await db.query(
      'images',
      where: 'id = ?',
      whereArgs: [record],
    );

    // If the record exists, delete it from the database
    if (existingRecord.isNotEmpty) {
      await db.delete(
        'images',
        where: 'id = ?',
        whereArgs: [record],
      );
    }
  }
}

Future<void> deleteBoundingBoxRecords(List<String> records) async {
  Database db = await instance.database;

  for (String record in records) {
    // Check if the record exists in the database
    List<Map<String, dynamic>> existingRecord = await db.query(
      'bounding_boxes',
      where: 'emotion_id = ?',
      whereArgs: [record],
    );

    // If the record exists, delete it from the database
    if (existingRecord.isNotEmpty) {
      await db.delete(
        'bounding_boxes',
        where: 'emotion_id = ?',
        whereArgs: [record],
      );
    }
  }
}




Future<void> deleteDatabaseFile() async {
  try {
    final dir = await getDirectoryService.getCurrentDirectory();
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
