import 'package:flutter/material.dart';
import 'package:projeto_banco_sangue/model/blood_donation/blood_donation.dart';
import 'package:projeto_banco_sangue/model/donation_site/donation_site.dart';

const List<BloodType> types = BloodType.values;
const List<RhFactor> rh = RhFactor.values;

class FiltersDropdown extends StatefulWidget {
  BloodType? selectedType;
  RhFactor? selectedFactor;
  DonationSite? selectedSite;
  List<DonationSite> sites;
  final Function({BloodType? type, RhFactor? factor, DonationSite? site})?
  onChanged;

  FiltersDropdown({
    super.key,
    this.selectedFactor,
    this.selectedType,
    this.onChanged,
    this.selectedSite,
    this.sites = const [],
  });

  @override
  State<FiltersDropdown> createState() => _FiltersDropdownState();
}

class _FiltersDropdownState extends State<FiltersDropdown> {
  BloodType? dropdownTypeValue;
  RhFactor? dropdownRHValue;

  @override
  void initState() {
    super.initState();
    dropdownTypeValue = widget.selectedType;
    dropdownRHValue = widget.selectedFactor;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Tipo sanguíneo", style: TextStyle(fontSize: 16)),
            ),
            SizedBox(width: 10),
            DropdownButton<BloodType?>(
              value: dropdownTypeValue,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              onChanged: (BloodType? newValue) {
                setState(() {
                  dropdownTypeValue = newValue;
                });
                widget.onChanged?.call(
                  type: newValue,
                  factor: dropdownRHValue,
                  site: widget.selectedSite,
                );
              },
              items: [
                const DropdownMenuItem<BloodType?>(
                  value: null,
                  child: Text("Todos"),
                ),
                ...types.map<DropdownMenuItem<BloodType?>>((BloodType value) {
                  return DropdownMenuItem<BloodType?>(
                    value: value,
                    child: Text(value.name),
                  );
                }),
              ],
            ),
          ],
        ),
        SizedBox(width: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Fator RH", style: TextStyle(fontSize: 16)),
            ),
            SizedBox(width: 10),
            DropdownButton<RhFactor?>(
              value: dropdownRHValue,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              onChanged: (RhFactor? newValue) {
                setState(() {
                  dropdownRHValue = newValue;
                });
                widget.onChanged?.call(
                  type: dropdownTypeValue,
                  factor: newValue,
                  site: widget.selectedSite,
                );
              },
              items: [
                const DropdownMenuItem<RhFactor?>(
                  value: null,
                  child: Text("Todos"),
                ),
                ...rh.map<DropdownMenuItem<RhFactor?>>((RhFactor value) {
                  return DropdownMenuItem<RhFactor?>(
                    value: value,
                    child: Text(
                      value == RhFactor.positive ? 'Positivo' : 'Negativo',
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
        SizedBox(width: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Posto de Doação", style: TextStyle(fontSize: 16)),
            ),
            SizedBox(width: 10),
            DropdownButton<DonationSite?>(
              value: widget.selectedSite,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              onChanged: (DonationSite? newValue) {
                widget.onChanged?.call(
                  type: dropdownTypeValue,
                  factor: dropdownRHValue,
                  site: newValue,
                );
              },
              items: [
                const DropdownMenuItem<DonationSite?>(
                  value: null,
                  child: Text("Todos"),
                ),
                ...widget.sites.map(
                      (site) => DropdownMenuItem<DonationSite?>(
                    value: site,
                    child: Text(site.nome),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}