import 'package:flutter/material.dart';
import 'package:projeto_banco_sangue/views/auth/auth_middleware.dart';
import 'package:projeto_banco_sangue/views/donations/home_page.dart';
import 'package:projeto_banco_sangue/views/auth/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.red)),
      home: AuthMiddleware(),
    );
  }
}
