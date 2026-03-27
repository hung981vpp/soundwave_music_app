import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _avatarBase64;

  AuthProvider() {
    _initAvatar();
    _auth.authStateChanges().listen((user) {
      _initAvatar();
    });
  }

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  String? get avatarBase64 => _avatarBase64;

  Future<void> _initAvatar() async {
    if (_auth.currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      _avatarBase64 = prefs.getString('avatar_${_auth.currentUser!.uid}');
    } else {
      _avatarBase64 = null;
    }
    notifyListeners();
  }

  Future<void> updateAvatar(String base64String) async {
    if (_auth.currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_${_auth.currentUser!.uid}', base64String);
      _avatarBase64 = base64String;
      notifyListeners();
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _initAvatar();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _initAvatar();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _avatarBase64 = null;
    notifyListeners();
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
    await _initAvatar();
  }
}

