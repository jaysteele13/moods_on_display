import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:moods_on_display/utils/types.dart';

class MockDatabaseManager {
  static final MockDatabaseManager instance = MockDatabaseManager._privateConstructor();
  static Database? _database;

  MockDatabaseManager._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Use an in-memory database for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    return await openDatabase(
      inMemoryDatabasePath, // Creates an in-memory database
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
  }

  // Insert mock images
  Future<int> insertImage(String id, String emotion) async {
    Database db = await instance.database;
    return await db.insert('images', {'id': id, 'emotion': emotion});
  }

  // Insert mock bounding boxes
  Future<int> insertBoundingBoxes(String emotionPointer, List<EmotionBoundingBox> boundingBoxes) async {
    Database db = await instance.database;
    Batch batch = db.batch();

    for (var ebbx in boundingBoxes) {
      batch.insert('bounding_boxes', {
        'emotion_id': emotionPointer,
        'emotion': ebbx.emotion,
        'x': ebbx.boundingBox.x,
        'y': ebbx.boundingBox.y,
        'width': ebbx.boundingBox.width,
        'height': ebbx.boundingBox.height,
      });
    }

    await batch.commit();
    return boundingBoxes.length;
  }

  // Fetch all images
  Future<List<Map<String, dynamic>>> getAllImages() async {
    Database db = await instance.database;
    return await db.query('images');
  }

  // Get images by emotion
  Future<List<EmotionPointer>> getImagesByEmotion(String emotion) async {
    Database db = await instance.database;
    final result = await db.query('images', where: 'emotion = ?', whereArgs: [emotion]);

    return result.map((map) => EmotionPointer.fromMap(map)).toList();
  }

  // Get bounding boxes by image ID
  Future<List<EmotionBoundingBox>> getEmotionBoundingBoxesByPointer(String pointer) async {
    Database db = await instance.database;
    final result = await db.query('bounding_boxes', where: 'emotion_id = ?', whereArgs: [pointer]);

    return result.map((map) => EmotionBoundingBox.fromMap(map)).toList();
  }

  // Delete images
  Future<void> deleteImageRecords(List<String> records) async {
    Database db = await instance.database;

    for (String record in records) {
      await db.delete('images', where: 'id = ?', whereArgs: [record]);
    }
  }

  // Close the mock database
  Future<void> closeDatabase() async {
    Database db = await instance.database;
    await db.close();
  }
}
