import 'package:flutter/material.dart';
import 'package:projeto_banco_sangue/model/blood_donation/blood_donation.dart';

const List<BloodType> types = BloodType.values;
const List<RhFactor> rh = RhFactor.values;

class FiltersDropdown extends StatefulWidget {
  BloodType? selectedType = BloodType.A;
  RhFactor? selectedFactor = RhFactor.positive;
  final Function(BloodType, RhFactor)? onChanged;

  FiltersDropdown({
    super.key,
    this.selectedFactor,
    this.selectedType,
    this.onChanged,
  });

  @override
  State<FiltersDropdown> createState() => _FiltersDropdownState();
}

class _FiltersDropdownState extends State<FiltersDropdown> {
  BloodType dropdownTypeValue = types.first;
  RhFactor dropdownRHValue = rh.first;

  @override
  void initState() {
    super.initState();
    dropdownTypeValue = widget.selectedType ?? types.first;
    dropdownRHValue = widget.selectedFactor ?? rh.first;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Tipo sanguíneo", style: TextStyle(fontSize: 20)),
            ),
            DropdownButton<BloodType>(
              value: dropdownTypeValue,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              onChanged: (BloodType? newValue) {
                if (newValue != null) {
                  dropdownTypeValue = newValue;
                  widget.onChanged?.call(
                    newValue,
                    widget.selectedFactor ?? RhFactor.positive,
                  );
                }
              },
              items: types.map<DropdownMenuItem<BloodType>>((BloodType value) {
                return DropdownMenuItem<BloodType>(
                  value: value,
                  child: Text(value.name),
                );
              }).toList(),
            ),
          ],
        ),
        Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Fator RH", style: TextStyle(fontSize: 20)),
            ),
            DropdownButton<RhFactor>(
              value: dropdownRHValue,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              onChanged: (RhFactor? newValue) {
                if (newValue != null) {
                  dropdownRHValue = newValue;
                  widget.onChanged?.call(
                    widget.selectedType ?? BloodType.A,
                    newValue,
                  );
                }
              },
              items: rh.map<DropdownMenuItem<RhFactor>>((RhFactor value) {
                return DropdownMenuItem<RhFactor>(
                  value: value,
                  child: Text(
                    value == RhFactor.positive ? 'Positivo' : 'Negativo',
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}
