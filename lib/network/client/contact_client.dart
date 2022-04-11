import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:simple_contact_list_app/model/contact_form.dart';
import 'package:simple_contact_list_app/network/config/dio_client.dart';
import 'package:simple_contact_list_app/network/dto/client_response.dart';
import 'package:simple_contact_list_app/network/dto/pageable.dart';

class ContactClient {
  static String path = "/user/contacts";

  Future<ClientResponse<Response>> create({String? requestId, required ContactForm form, String? filePath}) async {
    Map<String, dynamic> map = {
      "form": MultipartFile.fromString(
        jsonEncode(form),
        filename: "form",
        contentType: MediaType.parse(ContentType.json.mimeType),
      ),
    };

    if (filePath != null) {
      map.putIfAbsent(
        "file",
        () => MultipartFile.fromFileSync(
          filePath,
          filename: "file",
          contentType: MediaType.parse(lookupMimeType(filePath)!),
        ),
      );
    }

    Response response = await dioClient.post(path, data: FormData.fromMap(map));
    return ClientResponse<Response>(
      requestId: requestId ?? "",
      wrappedResponse: response,
    );
  }

  Future<ClientResponse<Response>> update({String? requestId, required int contactId, required ContactForm form, String? filePath}) async {
    Map<String, dynamic> map = {
      "form": MultipartFile.fromString(
        jsonEncode(form),
        filename: "form",
        contentType: MediaType.parse(ContentType.json.mimeType),
      ),
    };

    if (filePath != null) {
      map.putIfAbsent(
        "file",
            () => MultipartFile.fromFileSync(
          filePath,
          filename: "file",
          contentType: MediaType.parse(lookupMimeType(filePath)!),
        ),
      );
    }

    Response response = await dioClient.patch("$path/$contactId", data: FormData.fromMap(map));
    return ClientResponse<Response>(
      requestId: requestId ?? "",
      wrappedResponse: response,
    );
  }

  Future<ClientResponse<Response>> get({String? requestId, required int contactId}) async {
    return ClientResponse<Response>(
      requestId: requestId ?? "",
      wrappedResponse: await dioClient.get<String>("$path/$contactId"),
    );
  }

  Future<ClientResponse<Pageable>> getPage({String? requestId, String name = "", int page = 0}) async {
    return ClientResponse(
      requestId: requestId ?? "",
      wrappedResponse: Pageable.from(await dioClient.get<String>("$path?name=$name&page=$page")),
    );
  }

  Future<ClientResponse<Response>> delete({String? requestId, required int contactId}) async {
    var response = await dioClient.delete("$path/$contactId");
    return ClientResponse<Response>(
      requestId: requestId ?? "",
      wrappedResponse: response,
    );
  }
}
