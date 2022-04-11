class AuthForm {

  String email;
  String pass;

  AuthForm({ required this.email, required this.pass });

  static AuthForm? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return AuthForm(
      email: json['email'],
      pass: json['pass'],
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'pass': pass,
  };

}