class DonationSite {
  final int id;
  final String nome;
  final String endereco;
  final double latitude;
  final double longitude;

  const DonationSite({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.latitude,
    required this.longitude,
  });

  factory DonationSite.fromMap(Map<String, dynamic> json) => DonationSite(
    id: json['id'] ?? '',
    nome: json['nome'] ?? '',
    endereco: json['endereco'] ?? '',
    latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nome': nome,
    'endereco': endereco,
    'latitude': latitude,
    'longitude': longitude,
  };
}
