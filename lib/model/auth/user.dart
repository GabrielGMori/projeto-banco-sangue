class User {
  int id;
  String name;
  String password;

  User({required this.id, required this.name, required this.password});

  factory User.fromMap(Map<String, dynamic> json) =>
      User(id: json['id'], name: json['name'], password: json['password']);

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'password': password,
  };
}
