import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:projeto_banco_sangue/model/auth/authenticator.dart';
import 'package:projeto_banco_sangue/views/blood_donation/home_page.dart';
import 'package:projeto_banco_sangue/views/donation_site/site_map.dart';
import 'package:projeto_banco_sangue/views/users/user_table.dart';

import '../model/auth/user.dart';
import 'auth/login.dart';

class ItaoScaffold extends StatelessWidget {
  final Widget child;
  Widget? floatingActionButton;
  final storage = const FlutterSecureStorage();

  ItaoScaffold({super.key, required this.child, this.floatingActionButton});

  Future<User> _readUser() async {
    String? username = await storage.read(key: 'username');
    String? registration = await storage.read(key: 'userRegistration');

    return User(
      id: registration != null ? int.parse(registration) : 0,
      name: username ?? 'Usuário',
      password: '',
    );
  }

  void _logout(BuildContext context) async {
    await Authenticator().logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(storage: storage)),
      (route) => false,
    );
  }

  void _exclude(BuildContext context) async {
    await Authenticator().excludeAccount();

    String? registration = await storage.read(key: 'userRegistration');
    if (registration == null || registration == '1') {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Theme.of(context).colorScheme.surface),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'O usuário principal não pode ser excluído.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    _logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
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
      drawer: Drawer(
        child: FutureBuilder(
          future: _readUser(),
          builder: (context, snapshot) {
            final user =
                snapshot.data ?? User(id: 0, name: 'Usuário', password: '');

            return ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  accountEmail: Text('Matrícula: ${user.id}'),
                ),
                ListTile(
                  leading: const Icon(Icons.bloodtype),
                  title: const Text('Doações'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.local_hospital),
                  title: const Text('Postos de saúde'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DonationSiteMap()),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Usuários'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserTable()),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Mudar senha'),
                  onTap: () {
                    Navigator.pop(context);
                    _showChangePasswordModal(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Sair',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _logout(context),
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Excluir conta',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _exclude(context),
                ),
              ],
            );
          },
        ),
      ),

      body: SafeArea(child: child),
    );
  }

  void _showChangePasswordModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Alterar Senha',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Nova senha'),
                  validator: (value) {
                    if (value == null || value.length < 3) {
                      return 'A senha deve ter pelo menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await Authenticator().updatePassword(
                        passwordController.text,
                      );

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Senha alterada com sucesso!'),
                        ),
                      );
                    }
                  },
                  child: const Text('Salvar nova senha'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
