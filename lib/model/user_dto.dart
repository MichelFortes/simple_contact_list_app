class UserDto {

  String id;
  String name;
  String email;

  UserDto({ required this.id, required this.name, required this.email });

  static UserDto? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return UserDto(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };

}