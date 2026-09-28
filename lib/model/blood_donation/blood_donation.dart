enum RhFactor { positive, negative }

enum BloodType { A, B, AB, O }

class BloodDonation {
  int? id;
  BloodType type;
  RhFactor rh;
  String donator;
  DateTime dateDonation;
  bool used;
  String? grantee;
  DateTime? dateUsed;

  BloodDonation({
    this.id,
    required this.type,
    this.rh = RhFactor.positive,
    required this.donator,
    DateTime? dateDonation,
    this.used = false,
    this.grantee,
    this.dateUsed,
  }) : dateDonation = dateDonation ?? DateTime.now();

  void use(String grantee, DateTime? dateUsed) {
    used = true;

    this.grantee = grantee;
    this.dateUsed = dateUsed ?? DateTime.now();
  }

  bool isUsed() {
    return used;
  }

  String getTypeRH() {
    final rh = this.rh == RhFactor.positive ? '+' : '-';
    return '${this.type.name}$rh';
  }

  factory BloodDonation.fromMap(Map<String, dynamic> json) => BloodDonation(
    id: json['id'],
    type: BloodType.values.byName(json['type'] ?? 'A'),
    rh: RhFactor.values.byName(json['rh'] ?? 'positive'),
    donator: json['donator'],
    dateDonation: json['date_donation'] != null
        ? DateTime.parse(json['date_donation'])
        : DateTime.now(),
    used: json['used'] == 1,
    grantee: json['grantee'],
    dateUsed: json['date_used'] != null
        ? DateTime.parse(json['date_used'])
        : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'rh': rh.name,
    'donator': donator,
    'date_donation': dateDonation.toIso8601String(),
    'used': used ? 1 : 0,
    'grantee': grantee,
    'date_used': dateUsed?.toIso8601String(),
  };
}
