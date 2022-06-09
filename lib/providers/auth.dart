import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  final BuildContext context;
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  Auth(this.context);

  // 토큰이 있고 토큰이 만료되지 않았다면 유저는 authenticated 된 것임.
  bool get isAuth {
    // 토큰이 null이 아니라면 authenticated된 상태라고 할 수 있음.
    return token != null;
  }

  String? get token {
    // _expiryDate가 존재하고, _token이 존재하고, 토큰이 만료되지 않았다면.
    if (_expiryDate != null &&
        _token != null &&
        _expiryDate!.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

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

      _token = resBody['idToken'];
      _userId = resBody['localId'];
      // expiresIn은 토큰이 몇 초 동안 지속되는지 알려주는 값임.
      // 따라서 토큰의 만료 시간은 현재 시간에 expiresIn을 더해준 값으로 설정함.
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(resBody['expiresIn'])));
      _autoLogout();
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  // auth 정보를 모두 지움으로써 logout
  void logout() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    print("logout time passed");
    notifyListeners();
  }

  void _autoLogout() {
    // 이미 타이머가 있는 경우
    if (_authTimer != null) {
      // 타이머를 취소시킴
      _authTimer!.cancel();
    }

    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    // Timer는 입력한 시간이 지나면 전달받은 함수를 실행시킴.
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
