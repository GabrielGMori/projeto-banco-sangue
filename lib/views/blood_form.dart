import 'package:flutter/material.dart';
import 'package:projeto_banco_sangue/model/blood_donation/blood_donation.dart';
import 'package:projeto_banco_sangue/views/type_row.dart';

class FormScreen extends StatelessWidget {
  BloodDonation? donation;

  FormScreen({super.key, this.donation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: BloodForm(donation: donation),
    );
  }
}

class BloodForm extends StatefulWidget {
  BloodDonation? donation;

  BloodForm({super.key, this.donation});

  @override
  State<BloodForm> createState() => _BloodFormState();
}

class _BloodFormState extends State<BloodForm> {
  final _formKey = GlobalKey<FormState>();

  final _donatorController = TextEditingController();
  final _dateTimeDonationController = TextEditingController();
  BloodType? selectedType = BloodType.A;
  RhFactor? selectedFactor = RhFactor.positive;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();

    if (widget.donation != null) {
      _donatorController.text = widget.donation!.donator;
      selectedFactor = widget.donation!.rh;
      selectedType = widget.donation!.type;
      _selectedDateTime = widget.donation!.dateDonation;
    } else {
      _selectedDateTime = DateTime.now();
    }
    _dateTimeDonationController.text =
        "${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year}";
  }

  @override
  void dispose() {
    _donatorController.dispose();
    _dateTimeDonationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
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
                controller: _donatorController,
                decoration: const InputDecoration(
                  label: Text("Nome do doador"),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o doador';
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
                      "Selecione a data de doação",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.scrim,
                      ),
                    ),
                  ),
                  Text(_dateTimeDonationController.text),
                ],
              ),
              TypeRow(
                selectedType: selectedType,
                selectedFactor: selectedFactor,
                onChanged: (type, factor) {
                  setState(() {
                    selectedType = type;
                    selectedFactor = factor;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Salvando')));
                    Navigator.pop(
                      context,
                      BloodDonation(
                        id: widget.donation?.id,
                        type: selectedType ?? BloodType.A,
                        donator: _donatorController.text,
                        rh: selectedFactor ?? RhFactor.positive,
                        dateDonation: _selectedDateTime,
                      ),
                    );
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
