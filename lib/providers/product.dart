import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Product class 자체를 provider로 만들면서
// Product의 property가 변하는 경우 widget이 알아챌 수 있도록 했음.
class Product with ChangeNotifier {
  final String? id;
  final String? title;
  final String? description;
  final double? price;
  final String? imageUrl;
  bool isFavorite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  // isFavorite 변경되는 것만 notify하는 기능 추가.
  // Favorite 버튼 누르면 서버에 전송.
  // 즉각적으로 변했다가 실패하면 다시 변경
  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final url = Uri.parse(
        'https://udemy-shop-app-dd13c-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token');

    isFavorite = !isFavorite;
    notifyListeners();

    // productId와 bool 값이 mapping됨 (put)
    try {
      final res =
          await http.put(url, body: json.encode(isFavorite));
      print(res.body);
    } catch (error) {
      // 에러 발생하면 원복시킴
      isFavorite = !isFavorite;
      notifyListeners();
      throw error;
    }
  }
}
