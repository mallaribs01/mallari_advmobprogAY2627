import 'dart:convert';

import 'package:http/http.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  Future<User> login(String username, String password) async {
    final uri = Uri.parse('$HOST/user/login');

    final response = await post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 30,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return User.fromJson(data);
    }

    throw Exception('Login failed: ${response.statusCode}');
  }

  Future<User> getUser(int userId) async {
    final uri = Uri.parse('$HOST/users/$userId');

    final response = await get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return User.fromJson(data);
    }

    throw Exception('Failed to load user: ${response.statusCode}');
  }
}
