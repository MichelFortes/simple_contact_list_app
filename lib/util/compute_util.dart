import 'package:flutter/foundation.dart';
import 'package:simple_contact_list_app/model/contact_dto.dart';

/// This class has static methods that realize heavy works in its own isolate.
class ComputeUtil {

  /// Parses a string [text], typically a response body, into a [List<ContactDto>]
  static Future<List<ContactDto>> parseContactList(List<dynamic> list) async {
    return await compute(_parseContactList, list);
  }

  static List<ContactDto> _parseContactList(List<dynamic> list) {
    return ContactDto.listFromJson(list) ?? [];
  }

}



