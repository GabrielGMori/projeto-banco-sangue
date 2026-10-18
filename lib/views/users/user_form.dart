import 'package:flutter/material.dart';
import 'package:projeto_banco_sangue/model/auth/auth_dao.dart';
import 'package:projeto_banco_sangue/model/auth/authenticator.dart';
import 'package:projeto_banco_sangue/model/blood_donation/blood_donation.dart';

import '../../model/auth/user.dart';

class UserFormScreen extends StatelessWidget {

  UserFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Itaó+",
              style: TextStyle(color: Theme.of(context).colorScheme.surface),
            ),
            Text(
              "Banco de doação de sangue",
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 16,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceTint,
      ),
      body: UserForm(),
    );
  }
}

class UserForm extends StatefulWidget {
  UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final AuthDAO dao = AuthDAO();

  final _registrationController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _registrationController.text = '';
    _nameController.text = '';
  }

  @override
  void dispose() {
    _registrationController.dispose();
    _nameController.dispose();
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
                keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                decoration: const InputDecoration(
                  label: Text("Matrícula"),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a matrícula';
                  }
                  if (value == '0') {
                    return 'Matrícula inválida';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  label: Text("Nome"),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o nome';
                  }
                  return null;
                },
              ),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    int id = int.parse(_registrationController.text);
                    User? user = await dao.findByRegistration(id);
                    if (user != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Matrícula já existe')),
                      );
                      return;
                    }

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Salvando, senha padrão 123')));

                    Navigator.pop(
                      context,
                      User(
                        id: id,
                        name: _nameController.text,
                        password: _encrypt(),
                      ),
                    );
                  }
                },
                child: const Text("Salvar usuário"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _encrypt() {
    return Authenticator().encryptPassword('123');
  }
}