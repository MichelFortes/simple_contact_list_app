import 'dart:convert';

import 'package:dio/dio.dart';

class Pageable {
  dynamic content;
  bool last;
  int number;

  Pageable({required this.content, required this.last, required this.number});

  static Pageable from(Response<String> response) {
    var json = jsonDecode(response.data!);
    return Pageable(content: json['content'], last: json['last'], number: json['number']);
  }
}
