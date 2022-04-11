import 'dart:io';

import 'package:dio/dio.dart';
import 'package:simple_contact_list_app/config/app_constraints.dart';
import 'package:simple_contact_list_app/network/interceptor/default_interceptor.dart';

final Dio dioClient = Dio(
  BaseOptions(
    connectTimeout: connectTimeout.inMilliseconds,
    sendTimeout: sendTimeout.inMilliseconds,
    receiveTimeout: receiveTimeout.inMilliseconds,
    contentType: ContentType.json.value,
  ),
)..interceptors.add(DefaultInterceptor());
