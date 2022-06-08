import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  late String? _token;
  late DateTime _expiryDate;
  late String _userId;

  Future<void> _authenticate(
      String email, String password, String _urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$_urlSegment?key=AIzaSyA09286pm0cLXVDY4fClBbsdeZlcZazmAk');

    try {
      final res = await http.post(url,
          body: json.encode({
            'email': email.trim(),
            'password': password.trim(),
            'returnSecureToken': true,
          }));

      final resBody = json.decode(res.body);

      if (resBody['error'] != null) {
        throw HttpException(resBody['error']['message']);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }
}
