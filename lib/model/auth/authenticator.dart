import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:projeto_banco_sangue/model/auth/auth_dao.dart';
import 'package:projeto_banco_sangue/model/auth/user.dart';

class Authenticator {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final AuthDAO dao = AuthDAO();

  Authenticator();

  String encryptPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  bool compare(String password, String hashed) {
    return BCrypt.checkpw(password, hashed);
  }

  Future<bool> authenticate(String registration, String password) async {
    User? user = await dao.findByRegistration(int.parse(registration));

    if (user == null) {
      return false;
    }

    if (!compare(password, user.password)) {
      return false;
    }

    await storage.write(key: 'logged', value: 'true');
    await storage.write(
      key: 'userRegistration',
      value: registration.toString(),
    );
    await storage.write(key: 'username', value: user.name);
    return true;
  }

  Future<void> logout() async {
    await storage.deleteAll();
  }

  Future<void> excludeAccount() async {
    String? registration = await storage.read(key: 'userRegistration');
    await dao.remove(User(id: int.parse(registration!), name: '', password: ''));
    return;
  }

  Future<void> updatePassword(String text) async {
    String hashed = encryptPassword(text);
    String? registration = await storage.read(key: 'userRegistration');
    User? user = await dao.findByRegistration(int.parse(registration!));

    if(user == null) return;

    user.password = hashed;
    await dao.update(user);
  }
}
