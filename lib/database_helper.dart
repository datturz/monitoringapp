import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static const _databaseName = 'users.db';
  static const _databaseVersion = 1;

  static const table = 'users';
  static const columnId = 'id';
  static const columnEmail = 'email';
  static const columnPassword = 'password';
  static const columnRole = 'role';
  Database? _database;

  DatabaseHelper._privateConstructor();
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    // ignore: unused_local_variable
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
     await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnEmail TEXT NOT NULL,
        $columnPassword TEXT NOT NULL,
        $columnRole TEXT NOT NULL
      )
    ''');
    await db.execute('''
    INSERT INTO $table ($columnEmail, $columnPassword, $columnRole)
    VALUES ('admin@melintu.com', 'admin123', 'admin')
    ''');
  }

  Future<int> insertUser(User user) async {
    Database db = await instance.database;
    return await db.insert(table, user.toMap());
  }

  Future<bool> isAdmin(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result =
        await db.query(table, where: '$columnEmail = ?', whereArgs: [email]);

    if (result.isNotEmpty && result.first['role'] == 'admin') {
      return true;
    }
    return false;
  }
  Future<User?> getUserByEmail(String email) async {
  Database db = await instance.database;
  List<Map<String, dynamic>>
  maps = await db.query(table,
        where: '$columnEmail = ?',
        whereArgs: [email]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
}
