import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:projeto_banco_sangue/model/donation_site.dart/donation_site.dart';
import 'package:projeto_banco_sangue/model/donation_site.dart/donation_site_dao.dart';

class MapTestScreen extends StatefulWidget {
  const MapTestScreen({super.key});

  @override
  State<MapTestScreen> createState() => _MapTestScreenState();
}

class _MapTestScreenState extends State<MapTestScreen> {
  final MapController _mapController = MapController();
  final DonationSiteDao _siteDao = const DonationSiteDao();

  Position? _currentPosition;
  List<DonationSite> _savedSites = [];

  LatLng? _selectedLatLng;
  DonationSite? _selectedSavedSite;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Inicializa GPS e carrega os postos salvos via DAO
  Future<void> _initMap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Serviço de GPS desativado.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de GPS negada.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão negada permanentemente.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final sites = await _siteDao.getSites();

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _savedSites = sites;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Exibe modal para registrar o posto no ponto clicado
  void _openRegisterDialog() {
    if (_selectedLatLng == null) return;

    final nomeController = TextEditingController();
    final enderecoController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cadastrar Novo Posto de Doação',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Lat: ${_selectedLatLng!.latitude.toStringAsFixed(5)}, Lng: ${_selectedLatLng!.longitude.toStringAsFixed(5)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Posto / Hospital',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_hospital),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: enderecoController,
                decoration: const InputDecoration(
                  labelText: 'Endereço Completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.place),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('SALVAR POSTO'),
                  onPressed: () async {
                    if (nomeController.text.trim().isEmpty) return;

                    final newSite = DonationSite(
                      id: DateTime.now().millisecondsSinceEpoch,
                      nome: nomeController.text.trim(),
                      endereco: enderecoController.text.trim().isEmpty
                          ? 'Endereço não informado'
                          : enderecoController.text.trim(),
                      latitude: _selectedLatLng!.latitude,
                      longitude: _selectedLatLng!.longitude,
                    );

                    await _siteDao.add(newSite);
                    final updatedList = await _siteDao.getSites();

                    if (mounted) {
                      setState(() {
                        _savedSites = updatedList;
                        _selectedLatLng = null;
                      });
                      Navigator.of(ctx).pop();
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Remove o posto selecionado
  Future<void> _deleteSite(DonationSite site) async {
    await _siteDao.remove(site);
    final updatedList = await _siteDao.getSites();
    setState(() {
      _savedSites = updatedList;
      _selectedSavedSite = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Postos de Doação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _initMap,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_currentPosition != null)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                initialZoom: 15.0,
                minZoom: 10.0,
                maxZoom: 18.0,
                onTap: (_, point) {
                  setState(() {
                    _selectedSavedSite = null;
                    _selectedLatLng = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.projeto_banco_sangue',
                ),
                MarkerLayer(
                  markers: [
                    // Posição Atual
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blueAccent,
                        size: 30,
                      ),
                    ),

                    // Ponto Temporário Selecionado no Toque
                    if (_selectedLatLng != null)
                      Marker(
                        point: _selectedLatLng!,
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.add_location_alt,
                          color: Colors.orange,
                          size: 44,
                        ),
                      ),

                    // Postos Cadastrados no Banco
                    ..._savedSites.map((site) {
                      final isSelected = _selectedSavedSite?.id == site.id;
                      return Marker(
                        point: LatLng(site.latitude, site.longitude),
                        width: isSelected ? 50 : 40,
                        height: isSelected ? 50 : 40,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLatLng = null;
                              _selectedSavedSite = site;
                            });
                          },
                          child: Icon(
                            Icons.location_on,
                            color: isSelected
                                ? Colors.red.shade900
                                : Colors.red,
                            size: isSelected ? 48 : 38,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),

          if (_isLoading) const Center(child: CircularProgressIndicator()),

          if (_errorMessage != null && !_isLoading)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),

          // Botão para Cadastrar Novo Posto
          if (_selectedLatLng != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add),
                label: const Text('CADASTRAR NESTE PONTO'),
                onPressed: _openRegisterDialog,
              ),
            ),

          // Detalhes do Posto Selecionado
          if (_selectedSavedSite != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedSavedSite!.nome,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteSite(_selectedSavedSite!),
                          ),
                        ],
                      ),
                      Text(
                        _selectedSavedSite!.endereco,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
