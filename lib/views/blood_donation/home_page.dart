import 'package:flutter/material.dart';
import 'package:projeto_banco_sangue/model/blood_donation/blood_donation.dart';
import 'package:projeto_banco_sangue/model/blood_donation/blood_donation_dao.dart';
import 'package:projeto_banco_sangue/model/donation_site/donation_site.dart';
import 'package:projeto_banco_sangue/model/donation_site/donation_site_dao.dart';
import 'package:projeto_banco_sangue/views/blood_donation/blood_form.dart';
import 'package:projeto_banco_sangue/views/blood_donation/blood_tile.dart';
import 'package:projeto_banco_sangue/views/blood_donation/use_form.dart';
import 'package:projeto_banco_sangue/views/components/filters.dart';
import 'package:projeto_banco_sangue/views/itao_scaffold.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, donations});
  final BloodDonationDao bloodDonationDao = BloodDonationDao();
  final DonationSiteDao donationSiteDao = DonationSiteDao();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BloodType? selectedType;
  RhFactor? selectedFactor;
  DonationSite? selectedSite;
  List<BloodDonation> donations = [];
  List<DonationSite> sites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final sites = await widget.donationSiteDao.getSites();

      DonationSite? currentSite;
      for (final site in sites) {
        if (site.id == selectedSite?.id) {
          currentSite = site;
        }
      }

      final donations = await widget.bloodDonationDao.getDonations(
        selectedFactor,
        selectedType,
        currentSite,
      );
      if (!mounted) return;
      setState(() {
        this.sites = sites;
        this.donations = donations;
        selectedSite = currentSite;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ItaoScaffold(
      floatingActionButton: AppFloatingActionsButton(onChanged: _reload),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: Column(
          children: [
            FiltersDropdown(
              selectedType: selectedType,
              selectedFactor: selectedFactor,
              selectedSite: selectedSite,
              sites: sites,
              onChanged:
                  ({
                BloodType? type,
                RhFactor? factor,
                DonationSite? site,
              }) {
                setState(() {
                  selectedType = type;
                  selectedFactor = factor;
                  selectedSite = site;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<BloodDonation>>(
                future: widget.bloodDonationDao.getDonations(
                  selectedFactor,
                  selectedType,
                  selectedSite,
                ),
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
    await widget.bloodDonationDao.remove(donation);
    _reload();
  }

  void editDonation(BloodDonation donation) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormScreen(donation: donation)),
    );
    if (result != null) {
      await widget.bloodDonationDao.update(result);
    }
    _reload();
  }

  void onChangeStatus(BloodDonation donation) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UseDonationFormScreen(donation: donation),
      ),
    );
    if (result != null) {
      await widget.bloodDonationDao.update(result);
    }
    _reload();
  }
}

class AppFloatingActionsButton extends StatefulWidget {
  final BloodDonationDao bloodDonationDao = BloodDonationDao();
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
          await widget.bloodDonationDao.add(result);
          widget.onChanged();
        }
      },
      backgroundColor: Theme.of(context).colorScheme.surfaceTint,
      child: Icon(Icons.add, color: Theme.of(context).colorScheme.surface),
    );
  }
}