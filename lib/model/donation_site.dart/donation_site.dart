class DonationSite {
  final String placeId;
  final String nome;
  final String endereco;
  final double latitude;
  final double longitude;

  DonationSite({
    required this.placeId,
    required this.nome,
    required this.endereco,
    required this.latitude,
    required this.longitude,
  });

  factory DonationSite.fromOverpassJson(Map<String, dynamic> json) {
    final tags = json['tags'] ?? {};

    // Pega o nome do local ou define um nome padrão
    String nomePosto =
        tags['name'] ?? tags['official_name'] ?? 'Posto de Saúde';

    // Monta o endereço a partir das tags do OpenStreetMap
    String rua = tags['addr:street'] ?? '';
    String numero = tags['addr:housenumber'] ?? '';
    String bairro = tags['addr:suburb'] ?? tags['addr:neighbourhood'] ?? '';

    String enderecoCompleto = [
      rua,
      numero,
      bairro,
    ].where((element) => element.isNotEmpty).join(', ');

    if (enderecoCompleto.isEmpty) {
      enderecoCompleto = tags['address'] ?? 'Endereço não informado';
    }

    // Nodes usam lat/lon diretos; Ways (áreas) usam center.lat/center.lon
    double lat = json['lat'] ?? json['center']?['lat'] ?? 0.0;
    double lon = json['lon'] ?? json['center']?['lon'] ?? 0.0;

    return DonationSite(
      placeId: 'osm_${json['type']}_${json['id']}',
      nome: nomePosto,
      endereco: enderecoCompleto,
      latitude: lat,
      longitude: lon,
    );
  }
}
