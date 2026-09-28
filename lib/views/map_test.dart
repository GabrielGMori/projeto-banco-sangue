import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:projeto_banco_sangue/model/donation_site.dart/donation_site.dart';
import 'package:projeto_banco_sangue/model/donation_site.dart/donation_site_service.dart';

class RealMapScreen extends StatefulWidget {
  const RealMapScreen({super.key});

  @override
  State<RealMapScreen> createState() => _RealMapScreenState();
}

class _RealMapScreenState extends State<RealMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _userPosition;
  List<DonationSite> _postosList = [];
  DonationSite? _selectedPosto;

  bool _isLoadingLocation = true;
  bool _isLoadingPostos = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initLocationAndFetchPostos();
  }

  Future<void> _initLocationAndFetchPostos() async {
    try {
      // 1. Obtém GPS do Usuário
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final userLocation = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _userPosition = userLocation;
        _isLoadingLocation = false;
        _isLoadingPostos = true;
      });

      // 2. Busca Postos Reais Próximos via Overpass API
      List<DonationSite> postos = await DonationSiteService.fetchNearbyPostos(
        pos.latitude,
        pos.longitude,
      );

      setState(() {
        _postosList = postos;
        _isLoadingPostos = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingLocation = false;
        _isLoadingPostos = false;
      });
    }
  }

  String _calculateDistance(DonationSite posto) {
    if (_userPosition == null) return '-- km';
    double distanceInMeters = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      posto.latitude,
      posto.longitude,
    );
    return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
  }

  void _selectPosto(DonationSite posto) {
    setState(() => _selectedPosto = posto);
    _mapController.move(LatLng(posto.latitude, posto.longitude), 15.5);
    _showDetailsBottomSheet(posto);
  }

  void _showDetailsBottomSheet(DonationSite posto) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      posto.nome,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _calculateDistance(posto),
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      posto.endereco,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.bloodtype),
                  label: const Text('REGISTRAR DOAÇÃO NESTE POSTO'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Aqui você chama a função para salvar no banco de dados (Supabase/Firebase)
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) => setState(() => _selectedPosto = null));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.red),
              SizedBox(height: 12),
              Text('Obtendo sua localização GPS...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Postos Próximos (${_postosList.length})'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userPosition ?? const LatLng(-25.4284, -49.2733),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.blood_donation_app',
              ),
              MarkerLayer(
                markers: [
                  // Marcador do Usuário
                  if (_userPosition != null)
                    Marker(
                      point: _userPosition!,
                      width: 30,
                      height: 30,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blueAccent,
                        size: 28,
                      ),
                    ),
                  // Marcadores de Postos Reais
                  ..._postosList.map((posto) {
                    final isSelected = _selectedPosto?.placeId == posto.placeId;
                    return Marker(
                      point: LatLng(posto.latitude, posto.longitude),
                      width: isSelected ? 48 : 36,
                      height: isSelected ? 48 : 36,
                      child: GestureDetector(
                        onTap: () => _selectPosto(posto),
                        child: Icon(
                          Icons.location_on,
                          color: isSelected ? Colors.redAccent : Colors.red,
                          size: isSelected ? 48 : 36,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Indicador de Carregamento dos Postos sobre o Mapa
          if (_isLoadingPostos)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: const [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Buscando hospitais e hemocentros reais...'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        child: const Icon(Icons.my_location),
        onPressed: () {
          if (_userPosition != null) {
            _mapController.move(_userPosition!, 14.0);
          }
        },
      ),
    );
  }
}
