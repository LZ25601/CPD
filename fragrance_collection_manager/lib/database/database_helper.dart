import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/fragrance.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fragrances.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const intType = 'INTEGER';
    const realType = 'REAL';

    await db.execute('''
      CREATE TABLE fragrances (
        id $idType,
        name $textType,
        brand $textType,
        notes $textTypeNullable,
        size $intType,
        imagePath $textTypeNullable,
        description $textTypeNullable
      )
    ''');
  }

  Future<Fragrance> create(Fragrance fragrance) async {
    final db = await instance.database;
    final id = await db.insert('fragrances', fragrance.toMap());
    return fragrance.copyWith(id: id);
  }

  Future<Fragrance?> readFragrance(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'fragrances',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Fragrance.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Fragrance>> readAllFragrances() async {
    final db = await instance.database;
    const orderBy = 'name ASC';
    final result = await db.query('fragrances', orderBy: orderBy);
    return result.map((json) => Fragrance.fromMap(json)).toList();
  }

  Future<int> update(Fragrance fragrance) async {
    final db = await instance.database;
    return db.update(
      'fragrances',
      fragrance.toMap(),
      where: 'id = ?',
      whereArgs: [fragrance.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'fragrances',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}