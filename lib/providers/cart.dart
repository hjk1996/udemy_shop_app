import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String productId;
  final String title;
  final int quantity;
  final double price;

  CartItem(
      {required this.id,
      required this.productId,
      required this.title,
      required this.quantity,
      required this.price});


}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  void addItem(
    String productId,
    double price,
    String title,
  ) {
    // 제품 id 값이 key 값이 됨.
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (existingCartItem) => CartItem(
                id: existingCartItem.id,
                productId: productId,
                title: title,
                quantity: existingCartItem.quantity + 1,
                price: price,
              ));
    } else {
      _items.putIfAbsent(
          productId,
          () => CartItem(
              id: DateTime.now().toString(),
              productId: productId,
              title: title,
              quantity: 1,
              price: price));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    // map에서 특정 key 값을 가지고 있는 item을 제거함.
    _items.remove(productId);
    notifyListeners();
  }

  // 하나(수량)의 아이템만 없앰
  void removeSingleItem(String productId) {
    // 찾는 아이템이 없으면 그냥 함수 종료
    if (!_items.containsKey(productId)) {
      return;
    }

    if (_items[productId]!.quantity > 1) {
      _items.update(
          productId,
          (prev) => CartItem(
                id: prev.id,
                productId: prev.productId,
                title: prev.title,
                quantity: prev.quantity - 1,
                price: prev.price,
              ));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
