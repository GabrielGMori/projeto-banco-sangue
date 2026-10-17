import 'package:projeto_banco_sangue/database/database_helper.dart';
import 'package:projeto_banco_sangue/model/auth/user.dart';
import 'package:sqflite/sqflite.dart';

class AuthDAO {
  const AuthDAO();

  Future<User?> findByRegistration(int id) async {
    Database db = await DatabaseHelper.instance.database;
    var query = await db.query('users', where: "id = ?", whereArgs: [id]);
    if (query.isNotEmpty) {
      return User.fromMap(query.first);
    }
    return null;
  }

  Future<int> add(User newUser) async {
    Database db = await DatabaseHelper.instance.database;
    if (newUser.id > 0) {
      return await update(newUser);
    }
    return await db.insert('users', newUser.toMap());
  }

  Future<int> remove(User user) async {
    Database db = await DatabaseHelper.instance.database;
    if (user.id == 1) {
      return 0;
    }
    return await db.delete('users', where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> update(User user) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
