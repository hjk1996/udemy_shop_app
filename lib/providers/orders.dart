import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

// OrderItem의 products 다시 List<CartItem>으로 바꾸고
// 문제 해결할 방법 찾자.

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://udemy-shop-app-dd13c-default-rtdb.firebaseio.com/orders.json');

    try {
      final res = await http.get(url);
      final List<OrderItem> loadedOrders = [];
      final extractedData = json.decode(res.body) as Map<String, dynamic>?;
      if (extractedData == null) {
        return;
      }
      extractedData.forEach(
        (id, data) {
          loadedOrders.add(OrderItem(
            id: id,
            amount: data['amount'],
            products: (data['products'] as List<dynamic>)
                .map((item) => CartItem(
                      id: item['id'],
                      productId: item['productId'],
                      title: item['title'],
                      quantity: item['quantity'],
                      price: item['price'],
                    ))
                .toList(),
            dateTime: DateTime.parse(data['dateTime']),
          ));
        },
      );
      _orders = loadedOrders;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://udemy-shop-app-dd13c-default-rtdb.firebaseio.com/orders.json');

    try {
      final now = DateTime.now();
      final res = await http.post(url,
          body: json.encode({
            'amount': total,
            'products': cartProducts
                .map((p) => {
                      'id': p.id,
                      'productId': p.productId,
                      'title': p.title,
                      'quantity': p.quantity,
                      'price': p.price
                    })
                .toList(),
            'dateTime': now.toIso8601String()
          }));

      final order = OrderItem(
          id: json.decode(res.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: now);

      _orders.add(order);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
