import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

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
      final prefs = await SharedPreferences.getInstance();
      // user 데이터를 json으로 바꿔서
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String()
      });
      // 로컬 저장소에 저장.
      prefs.setString('userData', userData);
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

  Future<bool> tryAutoSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    // 로컬 저장소에 userData라는 이름의 data가 존재하지 않는다면
    if (!prefs.containsKey('userData')) {
      return false;
    }
    // 존재한다면 데이터 추출해서 맵으로 변환
    final extractedUserData = json.decode(prefs.getString('userData') as String)
        as Map<String, dynamic>;

    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    print(extractedUserData['expiryDate']);

    // 현재시점보다 만기일이 이전이라면 토큰 만료됐으므로 false 반환.
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    // 만약 모두 정상이라면 state 설정하고 알리고 타이머 설정하고 true 반환
    // 그리고 알리기
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  // auth 정보를 모두 지움으로써 logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("token");
    await prefs.remove("userId");
    await prefs.remove("expiryDate");

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
