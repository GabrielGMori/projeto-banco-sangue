import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../home_page.dart';
import 'login.dart';

class AuthMiddleware extends StatelessWidget {
  final storage = FlutterSecureStorage(aOptions: AndroidOptions());

  AuthMiddleware({super.key});

  Future<bool> _verifyLogin() async {
    String? isLogged = await storage.read(key: 'logged');
    return isLogged == 'true';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _verifyLogin(),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data!) {
          return HomePage();
        }

        return LoginScreen(storage: storage,);
      },
    );
  }
}
