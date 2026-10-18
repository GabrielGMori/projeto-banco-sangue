import 'package:latlong2/latlong.dart';

class DonationSite {
  final int? id;
  final String nome;
  final String endereco;
  final LatLng position;

  const DonationSite({
    this.id,
    required this.nome,
    required this.endereco,
    required this.position,
  });

  factory DonationSite.fromMap(Map<String, dynamic> json) => DonationSite(
    id: json['id'],
    nome: json['nome'],
    endereco: json['endereco'],
    position: LatLng(
      (json['latitude'] as num).toDouble(),
      (json['longitude'] as num).toDouble(),
    ),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nome': nome,
    'endereco': endereco,
    'latitude': position.latitude,
    'longitude': position.longitude,
  };
}
