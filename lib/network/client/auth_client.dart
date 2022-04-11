import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:simple_contact_list_app/model/auth/auth_data.dart';
import 'package:simple_contact_list_app/model/auth/auth_form.dart';
import 'package:simple_contact_list_app/network/config/dio_client.dart';
import 'package:simple_contact_list_app/network/dto/client_response.dart';
import 'package:simple_contact_list_app/persistence/app_persistence.dart';

class AuthClient {

  static String path = "/public/auth";

  Future<ClientResponse<Response>> auth({String? requestId, required String email, required String pass}) async {
    Response response = await dioClient.post<String>(path, data: jsonEncode(AuthForm(email: email, pass: pass)));

    if(response.statusCode == HttpStatus.created) {
      AuthData authData = AuthData.fromJson(jsonDecode(response.data))!;
      AppPersistence appPersistence = AppPersistence();
      await appPersistence.setAuthData(authData);
    }

    return ClientResponse<Response>(
      requestId: requestId ?? "",
      wrappedResponse: response,
    );
  }

}
