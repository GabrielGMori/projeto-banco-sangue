import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static const int _version = 2; // Incrementado para version 2
  static const String _dbName = 'itao.db';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> _initDatabase() async {
    String documentsDir = await getDatabasesPath();
    String path = join(documentsDir, _dbName);
    return openDatabase(
      path,
      version: _version,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
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
      create table donation_sites (
        id integer primary key autoincrement,
        nome text not null,
        endereco text not null,
        latitude real not null,
        longitude real not null
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        create table donation_sites (
          id integer primary key autoincrement,
          nome text not null,
          endereco text not null,
          latitude real not null,
          longitude real not null
        )
      ''');
    }
  }
}
