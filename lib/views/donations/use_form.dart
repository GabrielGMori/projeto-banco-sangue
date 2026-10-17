import 'package:flutter/material.dart';
import 'package:projeto_banco_sangue/model/blood_donation/blood_donation.dart';

class UseDonationFormScreen extends StatelessWidget {
  BloodDonation donation;

  UseDonationFormScreen({super.key, required this.donation});

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
      body: UseForm(donation: donation),
    );
  }
}

class UseForm extends StatefulWidget {
  BloodDonation donation;

  UseForm({super.key, required this.donation});

  @override
  State<UseForm> createState() => _UseFormState();
}

class _UseFormState extends State<UseForm> {
  final _formKey = GlobalKey<FormState>();

  final _granteeController = TextEditingController();
  final _dateTimeDonationController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();

    _granteeController.text = widget.donation.grantee ?? '';
    _selectedDateTime = widget.donation.dateDonation.isAfter(DateTime.now())
        ? widget.donation.dateDonation
        : DateTime.now();

    _dateTimeDonationController.text =
        "${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year}";
  }

  @override
  void dispose() {
    _granteeController.dispose();
    _dateTimeDonationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: widget.donation.dateDonation,
      firstDate: widget.donation.dateDonation,
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDateTime = selectedDate;
        _dateTimeDonationController.text =
            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
      });
    }
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
                controller: _granteeController,
                decoration: const InputDecoration(
                  label: Text("Nome do donatário"),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o donatário';
                  }
                  return null;
                },
              ),
              Row(
                spacing: 10,
                children: [
                  TextButton(
                    onPressed: () => _selectDate(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.inversePrimary,
                    ),
                    child: Text(
                      "Selecione a data de uso",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.scrim,
                      ),
                    ),
                  ),
                  Text(_dateTimeDonationController.text),
                ],
              ),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Salvando')));

                    widget.donation.use(
                      _granteeController.text,
                      _selectedDateTime,
                    );

                    Navigator.pop(context, widget.donation);
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
