import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:projeto_banco_sangue/model/donation_site.dart/donation_site.dart';

class DonationSiteService {
  // Busca postos em um raio de 10km (10000m) ao redor da latitude/longitude do usuário
  static Future<List<DonationSite>> fetchNearbyPostos(
    double lat,
    double lng, {
    double radiusMeters = 10000,
  }) async {
    final overpassQuery =
        '''
      [out:json][timeout:25];
      (
        node["healthcare"="blood_donation"](around:$radiusMeters,$lat,$lng);
        node["amenity"="hospital"](around:$radiusMeters,$lat,$lng);
        node["amenity"="clinic"](around:$radiusMeters,$lat,$lng);
        way["amenity"="hospital"](around:$radiusMeters,$lat,$lng);
      );
      out center 30;
    ''';

    final url = Uri.parse('https://overpass-api.de/api/interpreter');

    try {
      final response = await http.post(url, body: {'data': overpassQuery});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List elements = data['elements'] ?? [];

        List<DonationSite> postos = elements
            .map((e) => DonationSite.fromOverpassJson(e))
            .where((p) => p.latitude != 0.0 && p.longitude != 0.0)
            .toList();

        return postos;
      } else {
        throw Exception('Falha ao carregar dados do servidor.');
      }
    } catch (e) {
      throw Exception('Erro ao buscar postos reais: $e');
    }
  }
}
