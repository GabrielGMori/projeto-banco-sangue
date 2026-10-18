import 'package:flutter/material.dart';
import 'package:projeto_banco_sangue/model/auth/auth_dao.dart';
import 'package:projeto_banco_sangue/model/blood_donation/blood_donation_dao.dart';
import 'package:projeto_banco_sangue/views/users/user_form.dart';

import '../../model/auth/user.dart';
import '../itao_scaffold.dart';

class UserTable extends StatefulWidget {
  UserTable({super.key, donations});

  final BloodDonationDao dao = BloodDonationDao();

  @override
  State<UserTable> createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  @override
  Widget build(BuildContext context) {
    return ItaoScaffold(
      floatingActionButton: UserFloatingActionsButton(
        onChanged: () {
          setState(() {});
        },
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text(
              'Usuários e enfermeiros cadastrados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            Expanded(
              child: FutureBuilder<List<User>>(
                future: _loadUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Nenhum usuário cadastrado.'),
                    );
                  }

                  final users = snapshot.data!;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: const Icon(Icons.person),
                          ),
                          title: Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Matrícula: ${user.id}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<User>>? _loadUsers() async {
    return await AuthDAO().findAll();
  }
}

class UserFloatingActionsButton extends StatefulWidget {
  final AuthDAO dao = AuthDAO();
  final VoidCallback onChanged;

  UserFloatingActionsButton({super.key, required this.onChanged});

  @override
  State<UserFloatingActionsButton> createState() =>
      _UserFloatingActionsButtonState();
}

class _UserFloatingActionsButtonState extends State<UserFloatingActionsButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserFormScreen()),
        );
        if (result != null) {
          await widget.dao.add(result);
          widget.onChanged();
        }
      },
      backgroundColor: Theme.of(context).colorScheme.surfaceTint,
      child: Icon(Icons.add, color: Theme.of(context).colorScheme.surface),
    );
  }
}
