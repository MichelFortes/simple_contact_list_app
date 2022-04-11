import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_contact_list_app/model/auth/auth_data.dart';
import 'package:simple_contact_list_app/model/user_dto.dart';

class AppPersistence {

  static const String _serverIPKey = "server_ip";
  static const String _authDataKey = "auth_data";

  Future<bool> setServerIP(String ip) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(_serverIPKey, ip);
  }

  Future<String?> getServerIP() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_serverIPKey);
  }

  Future<bool> setAuthData(AuthData data) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String json = jsonEncode(data);
    return await preferences.setString(_authDataKey, json);
  }

  Future<AuthData?> getAuthData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? json = preferences.getString(_authDataKey);
    AuthData? data;
    try {
      data = AuthData.fromJson(jsonDecode(json!));
    } catch(_) {}
    return data;
  }

  Future<bool> updateAuthData(UserDto dto) async {
    AuthData? authData = await getAuthData();
    if(authData != null) {
      authData.name = dto.name;
      authData.email = dto.email;
      return await setAuthData(authData);
    } else {
      return false;
    }
  }

  Future<bool> clearAuthData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.remove(_authDataKey);
  }

}