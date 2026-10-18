import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:projeto_banco_sangue/model/donation_site/donation_site.dart';
import 'package:projeto_banco_sangue/model/donation_site/donation_site_dao.dart';
import 'package:projeto_banco_sangue/services/location_service.dart';
import 'package:projeto_banco_sangue/views/donation_site/site_form.dart';
import 'package:projeto_banco_sangue/views/donation_site/site_info.dart';

class DonationSiteMap extends StatefulWidget {
  DonationSiteMap({super.key});
  final DonationSiteDao dao = DonationSiteDao();

  @override
  State<DonationSiteMap> createState() => _DonationSiteMapState();
}

class _DonationSiteMapState extends State<DonationSiteMap> {
  final _mapController = MapController();
  String? _errorMessage;
  LatLng? _userPosition;
  List<DonationSite> _sites = [];
  LatLng? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _loadSites();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    try {
      final LatLng position = LocationService.geolocationPositionToLatLng(
        await LocationService.getCurrentLocation(),
      );
      if (!mounted) return;
      setState(() => _userPosition = position);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _loadSites() async {
    final List<DonationSite> sites = await widget.dao.getSites();
    if (!mounted) return;
    setState(() => _sites = sites);
  }

  Future<void> _openForm({
    required LatLng position,
    DonationSite? currentSite,
  }) async {
    final site = await showModalBottomSheet<DonationSite>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          DonationSiteCreateForm(position: position, site: currentSite),
    );

    if (!mounted) return;
    setState(() => _selectedPosition = null);
    if (site == null) return;

    try {
      if (currentSite != null) {
        await widget.dao.update(site);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Posto atualizado!')));
      } else {
        await widget.dao.add(site);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Posto cadastrado!')));
      }
      await _loadSites();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  Future<void> _onMapTap(_, LatLng position) async {
    setState(() => _selectedPosition = position);
    await _openForm(position: position);
  }

  Future<void> _onSiteMarkerTap(DonationSite site) async {
    final SiteAction? action = await showModalBottomSheet<SiteAction>(
      context: context,
      builder: (context) => DonationSiteInfo(site: site),
    );

    if (!mounted || action == SiteAction.cancel) return;

    if (action == SiteAction.edit) {
      await _openForm(position: site.position, currentSite: site);
    } else if (action == SiteAction.select) {
      Navigator.pop(context, site);
    } else if (action == SiteAction.delete) {
      final total = await widget.dao.countDonations(site.id!);

      if (total > 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Este posto tem $total doação(ões) registrada(s) e não pode ser removido.',
              ),
            ),
          );
        }
        return;
      }

      try {
        await widget.dao.remove(site);
        await _loadSites();
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Posto removido!')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao remover: $e')));
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _errorMessage = null;
      _userPosition = null;
      _selectedPosition = null;
      _sites = [];
    });
    await Future.wait([_loadLocation(), _loadSites()]);
  }

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
              "Postos disponíveis",
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 16,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceTint,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: Icon(
              Icons.refresh,
              size: 32,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ],
      ),
      body: _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _userPosition == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userPosition!,
                initialZoom: 16,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.projeto_banco_sangue',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userPosition!,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: _sites
                      .map(
                        (site) => Marker(
                          point: site.position,
                          child: GestureDetector(
                            onTap: () => _onSiteMarkerTap(site),
                            child: Icon(
                              Icons.location_on,
                              size: 36,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                MarkerLayer(
                  markers: [
                    if (_selectedPosition != null)
                      Marker(
                        point: _selectedPosition!,
                        child: Icon(
                          Icons.add_location_alt,
                          size: 36,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
      floatingActionButton: _userPosition != null
          ? FloatingActionButton(
              onPressed: () => _mapController.move(_userPosition!, 16),
              child: const Icon(Icons.my_location),
            )
          : null,
    );
  }
}
