class AuthData {

  String name;
  String email;
  String tokenType;
  String token;

  AuthData({ required this.name, required this.email, required this.tokenType, required this.token });

  static AuthData? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return AuthData(
      name: json['name'],
      email: json['email'],
      tokenType: json['tokenType'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'tokenType': tokenType,
    'token': token,
  };

}