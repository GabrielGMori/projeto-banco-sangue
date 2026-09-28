import 'package:flutter/material.dart';
import 'package:projeto_banco_sangue/model/blood_donation/blood_donation.dart';

class TypeRow extends StatefulWidget {
  BloodType? selectedType = BloodType.A;
  RhFactor? selectedFactor = RhFactor.positive;
  final Function(BloodType, RhFactor)? onChanged;

  TypeRow({
    super.key,
    this.selectedType,
    this.selectedFactor,
    required this.onChanged,
  });

  @override
  State<TypeRow> createState() => TypeRowState();
}

class TypeRowState extends State<TypeRow> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Tipo sanguíneo", style: TextStyle(fontSize: 20)),
        ),
        RadioGroup<BloodType>(
          groupValue: widget.selectedType,
          onChanged: (BloodType? newValue) {
            if (newValue != null) {
              widget.onChanged?.call(
                newValue,
                widget.selectedFactor ?? RhFactor.positive,
              );
            }
          },
          child: Row(
            children: [
              for (BloodType value in BloodType.values)
                Row(
                  children: [
                    Radio<BloodType>(
                      value: value,
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    Text(value.name),
                  ],
                ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Fator RH", style: TextStyle(fontSize: 20)),
        ),
        RadioGroup<RhFactor>(
          groupValue: widget.selectedFactor,
          onChanged: (RhFactor? newValue) {
            if (newValue != null) {
              widget.onChanged?.call(
                widget.selectedType ?? BloodType.A,
                newValue,
              );
            }
          },
          child: Row(
            children: [
              for (RhFactor value in RhFactor.values)
                Row(
                  children: [
                    Radio<RhFactor>(
                      value: value,
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    Text(value == RhFactor.positive ? '+' : '-'),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
