import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:projeto_banco_sangue/model/auth/auth_dao.dart';
import 'package:projeto_banco_sangue/model/auth/user.dart';

class Authenticator {
  final FlutterSecureStorage storage;
  final AuthDAO dao = AuthDAO();
  Authenticator({required this.storage});

  String encryptPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  bool compare(String password, String hashed) {
    return BCrypt.checkpw(password, hashed);
  }

  Future<bool> authenticate(int registration, String password) async {
    User? user = await dao.findByRegistration(registration);

    if(user == null) {
      return false;
    }

    if(!compare(password, user.password)) {
      return false;
    }

    storage.write(key: 'logged', value: 'true');
    storage.write(key: 'userRegistration', value: registration.toString());
    storage.write(key: 'username', value: user.name);
    return true;
  }

  void logout() {
    storage.deleteAll();
  }
}
