import 'package:flutter/material.dart';

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
  void toggleFavoriteStatus() {
    isFavorite = !isFavorite;
    notifyListeners();
  }
}
