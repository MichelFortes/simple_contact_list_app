class ContactForm {

  String name;
  String email;
  String address;
  List<String> phones;

  ContactForm({ required this.name, required this.email, required this.address,required this.phones });

  static ContactForm? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return ContactForm(
      name: json['name'],
      email: json['email'],
      address: json['address'],
      phones: json['phones'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'address': address,
    'phones': phones,
  };

  static List<ContactForm>? listFromJson(List<dynamic>? json) {
    if (json == null) return null;
    List<ContactForm> list = [];
    for (var element in json) {
      var contact = ContactForm.fromJson(element);
      if (contact != null) list.add(contact);
    }
    return list;
  }

}