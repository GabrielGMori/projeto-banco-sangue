import 'package:flutter/material.dart';
import 'package:projeto_banco_sangue/model/blood_donation/blood_donation.dart';
import 'package:projeto_banco_sangue/model/blood_donation/blood_donation_dao.dart';
import 'package:projeto_banco_sangue/views/blood_form.dart';
import 'package:projeto_banco_sangue/views/filters.dart';
import 'package:projeto_banco_sangue/views/auth/login.dart';
import 'package:projeto_banco_sangue/views/use_form.dart';

import 'blood_tile.dart';
import 'itao_scaffold.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, donations});

  final BloodDonationDao dao = BloodDonationDao();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BloodType selectedType = BloodType.A;
  RhFactor selectedFactor = RhFactor.positive;

  @override
  Widget build(BuildContext context) {
    return ItaoScaffold(
      floatingActionButton: AppFloatingActionsButton(
        onChanged: () => setState(() {}),
      ),
      child: Center(
        child: Column(
          children: [
            FiltersDropdown(
              selectedType: selectedType,
              selectedFactor: selectedFactor,
              onChanged: (type, factor) {
                setState(() {
                  selectedType = type;
                  selectedFactor = factor;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<BloodDonation>>(
                future: widget.dao.getDonations(selectedFactor, selectedType),
                builder: (context, snapshot) {
                  final donations = snapshot.data ?? [];

                  if (donations.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhuma doação encontrada para este filtro.',
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: donations.length,
                    itemBuilder: (context, index) {
                      final donation = donations[index];
                      return BloodTile(
                        donation: donation,
                        onDelete: deleteDonation,
                        onEdit: editDonation,
                        onChangeStatus: onChangeStatus,
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

  void deleteDonation(BloodDonation donation) async {
    await widget.dao.remove(donation);
    setState(() {});
  }

  void editDonation(BloodDonation donation) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormScreen(donation: donation)),
    );
    if (result != null) {
      await widget.dao.update(result);
      setState(() {});
    }
  }

  void onChangeStatus(BloodDonation donation) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UseDonationFormScreen(donation: donation),
      ),
    );
    if (result != null) {
      await widget.dao.update(result);
      setState(() {});
    }
  }
}

class AppFloatingActionsButton extends StatefulWidget {
  final BloodDonationDao dao = BloodDonationDao();
  final VoidCallback onChanged;

  AppFloatingActionsButton({super.key, required this.onChanged});

  @override
  State<AppFloatingActionsButton> createState() =>
      _AppFloatingActionsButtonState();
}

class _AppFloatingActionsButtonState extends State<AppFloatingActionsButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FormScreen()),
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
