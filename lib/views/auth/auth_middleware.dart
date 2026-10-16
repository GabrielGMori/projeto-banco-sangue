import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:projeto_banco_sangue/model/auth/user.dart';

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

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  final _registrationController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _registrationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 20,
            children: [
              TextFormField(
                controller: _registrationController,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: false,
                  signed: false,
                ),
                decoration: const InputDecoration(
                  label: Text("Insira a matrícula"),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o número de matrícula';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a senha';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Salvando')));
                    // Navigator.pop(
                    //   context,
                    //   User(
                    //     id: int.parse(_registrationController.text),
                    //     password: _passwordController.text,
                    //   ),
                    // );
                  }
                },
                child: const Text("Salvar doação de sangue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
