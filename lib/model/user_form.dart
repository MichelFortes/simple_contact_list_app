class UserForm {

  String name;
  String email;
  String password;

  UserForm({ required this.name, required this.email, required this.password });

  static UserForm? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return UserForm(
      name: json['name'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
  };

}