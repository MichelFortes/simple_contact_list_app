import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:simple_contact_list_app/model/user_dto.dart';
import 'package:simple_contact_list_app/model/user_form.dart';
import 'package:simple_contact_list_app/network/config/dio_client.dart';
import 'package:simple_contact_list_app/network/dto/client_response.dart';
import 'package:simple_contact_list_app/persistence/app_persistence.dart';

class UserClient {

  static String path = "/user";

  Future<ClientResponse<Response>> create({String? requestId, required UserForm form}) async {
    Response response = await dioClient.post<String>("/public$path", data: jsonEncode(form));
    return ClientResponse<Response>(
      requestId: requestId ?? "",
      wrappedResponse: response,
    );
  }

  Future<ClientResponse<Response>> update({String? requestId, required UserForm form}) async {
    AppPersistence persistence = AppPersistence();
    var response = await dioClient.patch<String>(path, data: jsonEncode(form));
    if(response.data != null && response.statusCode == HttpStatus.ok) {
      await persistence.updateAuthData(UserDto.fromJson(jsonDecode(response.data!)!)!);
    }
    return ClientResponse<Response>(
      requestId: requestId ?? "",
      wrappedResponse: response,
    );
  }

  Future<ClientResponse<Response>> get({String? requestId}) async {
    return ClientResponse<Response>(
      requestId: requestId ?? "",
      wrappedResponse: await dioClient.get<String>(path),
    );
  }

  Future<ClientResponse<Response>> delete({String? requestId}) async {
    var response = await dioClient.delete(path);
    return ClientResponse<Response>(
      requestId: requestId ?? "",
      wrappedResponse: response,
    );
  }

}
