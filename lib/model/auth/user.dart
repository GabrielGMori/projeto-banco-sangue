class User {
  int? id;
  String? name;
  String? password;

  User({this.id, this.name, this.password});

  factory User.fromMap(Map<String, dynamic> json) =>
      User(id: json['id'], name: json['name'], password: json['password']);

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'password': password,
  };
}
