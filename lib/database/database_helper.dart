import 'package:bcrypt/bcrypt.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static const int _version = 1;
  static const String _dbName = 'itao.db';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> _initDatabase() async {
    String documentsDir = await getDatabasesPath();
    String path = join(documentsDir, _dbName);
    return openDatabase(
      path,
      onCreate: _createDb,
      version: _version,
      onConfigure: (db) async => await db.execute('pragma foreign_keys = on'),
    );
  }

  Future<Database> get database async => _database ??= await _initDatabase();

  Future _createDb(Database db, int version) async {
    await db.execute('''
      create table blood_donations (
        id integer primary key autoincrement,
        type text not null,
        rh text not null,
        donator text not null,
        date_donation text not null default CURRENT_TIMESTAMP,
        used integer not null default 0,
        grantee text,
        date_used text
      )
    ''');

    await db.execute('''
      create table users (
        id integer primary key,
        name text not null,
        password text not null
      )
    ''');

    String hashedPassword = BCrypt.hashpw('1', BCrypt.gensalt());
    await db.execute(
      'insert into users(id, name, password) values (1, "ADMIN", "$hashedPassword")',
    );
  }
}
