import 'package:dio/dio.dart';

class ResponseWrapper {
  Response? response;
  Exception? exception;

  ResponseWrapper({this.response, this.exception});
}
