import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  Map<String, dynamic> data = {};

  // Login user
  Future<Map<String, dynamic>> loginUser(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$host/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);

      // Save authenticated user data.
      await saveUserData(data);

      return data;
    } else {
      throw Exception(response.body);
    }
  }

  // Save user data to SharedPreferences
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    final user = User.fromJson(userData);

    await prefs.setInt('id', user.id);

    await prefs.setString('username', user.username);

    await prefs.setString('email', user.email);

    await prefs.setString('firstName', user.firstName);

    await prefs.setString('lastName', user.lastName);

    await prefs.setString('gender', user.gender);

    await prefs.setString('image', user.image);

    await prefs.setString('accessToken', user.accessToken);

    await prefs.setString('refreshToken', user.refreshToken);

    // Support token key if returned by the API.
    if (userData.containsKey('token')) {
      await prefs.setString('token', userData['token']?.toString() ?? '');
    } else if (user.accessToken.isNotEmpty) {
      await prefs.setString('token', user.accessToken);
    }
  }

  // Retrieve user data from SharedPreferences
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'id': prefs.getInt('id') ?? 0,
      'username': prefs.getString('username') ?? '',
      'email': prefs.getString('email') ?? '',
      'firstName': prefs.getString('firstName') ?? '',
      'lastName': prefs.getString('lastName') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'image': prefs.getString('image') ?? '',
      'accessToken': prefs.getString('accessToken') ?? '',
      'refreshToken': prefs.getString('refreshToken') ?? '',
      'token': prefs.getString('token') ?? prefs.getString('accessToken') ?? '',
    };
  }

  // Lab Activity 4 - Enhancement 3:
  // Convert the saved SharedPreferences data back
  // into the User model.
  // ProfileScreen uses this method to render
  // the user's information.
  Future<User?> getUser() async {
    final userData = await getUserData();

    if (userData['id'] == 0) {
      return null;
    }

    return User.fromJson(userData);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    final accessToken = prefs.getString('accessToken') ?? '';

    final token = accessToken.isNotEmpty
        ? accessToken
        : (prefs.getString('token') ?? '');

    return token.isNotEmpty;
  }

  // Logout and clear user data
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to log out: $e');
    }
  }
}
