class ContactDto {

  int id;
  String name;
  String? email;
  String? address;
  String? pictureUrl;
  List<String>? phones;

  ContactDto({ required this.id, required this.name, this.email, this.address, this.pictureUrl, this.phones });

  static ContactDto? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return ContactDto(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      address: json['address'],
      pictureUrl: json['pictureUrl'],
      phones: json['phones'] != null ? List.from(json['phones']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'address': address,
    'pictureUrl': pictureUrl,
    'phones': phones,
  };

  static List<ContactDto>? listFromJson(List<dynamic>? json) {
    if (json == null) return null;
    List<ContactDto> list = [];
    for (var element in json) {
      var contact = ContactDto.fromJson(element);
      if (contact != null) list.add(contact);
    }
    return list;
  }

}