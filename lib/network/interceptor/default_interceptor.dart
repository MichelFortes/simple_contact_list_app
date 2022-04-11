import 'dart:io';

import 'package:dio/dio.dart';
import 'package:simple_contact_list_app/model/auth/auth_data.dart';
import 'package:simple_contact_list_app/persistence/app_persistence.dart';

class DefaultInterceptor implements Interceptor {

  final AppPersistence _appPersistence = AppPersistence();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    String serverIP = await _appPersistence.getServerIP() ?? "";
    options.path = "http://$serverIP${options.path}";

    if(!options.headers.containsKey(HttpHeaders.contentTypeHeader)) {
      options.headers.putIfAbsent(HttpHeaders.contentTypeHeader, () => ContentType.json.mimeType);
    }

    AuthData? data = await _appPersistence.getAuthData();
    if(data != null) options.headers.putIfAbsent(HttpHeaders.authorizationHeader, () => "Bearer ${data.token}");
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }

}
