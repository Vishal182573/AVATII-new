import 'dart:convert';
import 'package:avatii/models/usermodel.dart';
import 'package:avatii/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;
bool _isLoading=false;
bool get isLoading=>_isLoading;
  static const String _userKey = 'user_data';

  UserProvider() {
    _loadUserFromPrefs();
  }

  // Register User
  Future<void> registerUser(String name, String phoneNumber) async {
    _isLoading=true;
    notifyListeners();
    final url = Appurls.registeruser; // Replace with your actual backend URL
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'phoneNumber': phoneNumber,
        }),
      );
 _isLoading=false;
    notifyListeners();
      if (response.statusCode == 201) {

        print("Successfull registration.....................of the user.............");
        final responseData = json.decode(response.body);
        _user = UserModel.fromJson(responseData);


        final pref=await SharedPreferences.getInstance();
      await pref.setString('token',responseData['token']);
      await pref.setString('contact',responseData['phoneNumber']);
          await pref.setString('userid',responseData['_id']);

        notifyListeners();
     //   await _saveUserToPrefs(); // Save user data to shared preferences
      } else {
        print('failed to registeer.............${response.body}');
        throw Exception('Failed to register user');
      }
    } catch (error) {
      print('Failed to register .............${error}');
      throw Exception('Failed to register user: $error');
    }
  }

  // Login User
  Future<void> loginUser(String phoneNumber) async {
    final url = Appurls.loginuser; // Replace with your actual backend URL
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {

        print('Login ..........................successfull');
        final responseData = json.decode(response.body);
        _user = UserModel.fromJson(responseData);
        print(response.body);
      final pref=await SharedPreferences.getInstance();
      await pref.setString('token',responseData['token']);
      await pref.setString('contact',responseData['phoneNumber']);
          await pref.setString('userid',responseData['_id']);

        notifyListeners();
      //  await _saveUserToPrefs(); // Save user data to shared preferences
      } else {

        print('successfull login.......................... ');
        throw Exception('Failed to login user');
      }
    } catch (error) {
      throw Exception('Failed to login user: $error');
    }
  }

  // Logout User
  Future<void> logoutUser() async {
    _user = null;
    notifyListeners();
    await _clearUserFromPrefs(); // Remove user data from shared preferences
  }

  // Check if User is Logged In
  bool get isLoggedIn {
    return _user != null;
  }

  // Save user data to shared preferences
 

  // Load user data from shared preferences
  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      _user = UserModel.fromJson(json.decode(userData));
      notifyListeners();
    }
  }

  // Clear user data from shared preferences
  Future<void> _clearUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_userKey);
  }
}
