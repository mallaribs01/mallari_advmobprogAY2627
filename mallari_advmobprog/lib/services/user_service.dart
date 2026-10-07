import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  Map<String, dynamic> data = {};

  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // DUMMYJSON LOGIN
  // ============================================================

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

      await saveUserData(data);

      return data;
    } else {
      throw Exception(response.body);
    }
  }

  // ============================================================
  // FIREBASE SIGN UP
  // ============================================================

  Future<firebase_auth.User?> createAccount({
    required String firstName,
    required String lastName,
    required String age,
    required String contactNo,
    required String username,
    required String emailAddress,
    required String password,
  }) async {
    try {
      // Create Firebase Authentication account.
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailAddress.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Unable to create Firebase account.');
      }

      // Store username as Firebase display name.
      await user.updateDisplayName(username.trim());

      // Store additional signup information in Firestore.
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'age': int.tryParse(age.trim()) ?? 0,
        'contactNo': contactNo.trim(),
        'username': username.trim(),
        'emailAddress': emailAddress.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Refresh Firebase user information.
      await user.reload();

      return _firebaseAuth.currentUser;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_firebaseErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ============================================================
  // FIREBASE SIGN IN USING EMAIL
  // ============================================================

  Future<firebase_auth.User?> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return credential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_firebaseErrorMessage(e));
    }
  }

  // ============================================================
  // FIREBASE SIGN IN USING USERNAME OR EMAIL
  // ============================================================

  Future<firebase_auth.User?> signInWithUsernameOrEmail(
    String usernameOrEmail,
    String password,
  ) async {
    try {
      String email = usernameOrEmail.trim();

      // If the user entered an email address,
      // use it directly for Firebase Authentication.
      if (!email.contains('@')) {
        // User entered a username.
        // Find the matching account in Firestore.
        final query = await _firestore
            .collection('users')
            .where('username', isEqualTo: usernameOrEmail.trim())
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          throw Exception('Firebase account not found.');
        }

        final userData = query.docs.first.data();

        email = userData['emailAddress']?.toString() ?? '';

        if (email.isEmpty) {
          throw Exception('Email address not found for this account.');
        }
      }

      // Sign in using the email found in Firestore.
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_firebaseErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ============================================================
  // FIREBASE SIGN OUT
  // ============================================================

  Future<void> signOut() async {
    try {
      // Sign out from Firebase.
      await _firebaseAuth.signOut();

      // Also clear the DummyJSON session.
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // ============================================================
  // FIREBASE GET USER DATA
  // ============================================================

  Future<Map<String, dynamic>> getFirebaseUserData() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return {};
    }

    final document = await _firestore.collection('users').doc(user.uid).get();

    if (document.exists) {
      final firestoreData = document.data() ?? {};

      return {
        ...firestoreData,
        'uid': user.uid,
        'emailAddress': user.email ?? '',
        'displayName': user.displayName ?? '',
      };
    }

    return {
      'uid': user.uid,
      'emailAddress': user.email ?? '',
      'displayName': user.displayName ?? '',
    };
  }

  // ============================================================
  // FIREBASE UPDATE USERNAME
  // ============================================================

  Future<void> updateUsername(String newUsername) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('No Firebase user is currently signed in.');
    }

    final username = newUsername.trim();

    if (username.isEmpty) {
      throw Exception('Username cannot be empty.');
    }

    // Update Firebase display name.
    await user.updateDisplayName(username);

    // Update username in Firestore.
    await _firestore.collection('users').doc(user.uid).set({
      'username': username,
    }, SetOptions(merge: true));

    await user.reload();
  }

  // ============================================================
  // FIREBASE CHANGE PASSWORD
  // ============================================================

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;

    if (user == null || user.email == null) {
      throw Exception('No Firebase user is currently signed in.');
    }

    try {
      // Re-authenticate before changing the password.
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_firebaseErrorMessage(e));
    }
  }

  // ============================================================
  // FIREBASE DELETE ACCOUNT
  // ============================================================

  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('No Firebase user is currently signed in.');
    }

    try {
      // Delete Firestore profile first.
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Authentication account.
      await user.delete();

      // Clear local session.
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_firebaseErrorMessage(e));
    }
  }

  // ============================================================
  // CHECK FIREBASE LOGIN
  // ============================================================

  bool isFirebaseLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // ============================================================
  // FIREBASE AUTH ERROR MESSAGES
  // ============================================================

  String _firebaseErrorMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';

      case 'user-not-found':
        return 'No account was found with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';

      case 'email-already-in-use':
        return 'This email address is already registered.';

      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'requires-recent-login':
        return 'Please sign in again before performing this action.';

      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      default:
        return e.message ?? 'Firebase authentication failed.';
    }
  }

  // ============================================================
  // DUMMYJSON SAVE USER DATA
  // ============================================================

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

    if (userData.containsKey('token')) {
      await prefs.setString('token', userData['token']?.toString() ?? '');
    } else if (user.accessToken.isNotEmpty) {
      await prefs.setString('token', user.accessToken);
    }
  }

  // ============================================================
  // GET DUMMYJSON USER DATA
  // ============================================================

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

  // ============================================================
  // GET DUMMYJSON USER MODEL
  // ============================================================

  Future<User?> getUser() async {
    final userData = await getUserData();

    if (userData['id'] == 0) {
      return null;
    }

    return User.fromJson(userData);
  }

  // ============================================================
  // CHECK DUMMYJSON LOGIN
  // ============================================================

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    final accessToken = prefs.getString('accessToken') ?? '';

    final token = accessToken.isNotEmpty
        ? accessToken
        : (prefs.getString('token') ?? '');

    return token.isNotEmpty;
  }

  // ============================================================
  // OLD LOGOUT
  // ============================================================

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to log out: $e');
    }
  }
}
