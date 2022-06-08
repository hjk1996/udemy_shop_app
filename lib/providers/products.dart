import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product.dart';
import '../models/http_exception.dart';

// with는 mixin
class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02hh/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  final String? authToken;
  final String? userId;

  Products(this.authToken, this._items, this.userId);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite == true).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // []는 optional, positional parameter 설정을 위해서 사용함.
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    // authToken을 이용해 authentication하고, creatorId를 기준으로 정렬하고, userId가 creatorId와 일치하는 제품만 backend에 요청
    var url = Uri.parse(
        'https://udemy-shop-app-dd13c-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');

    try {
      final res = await http.get(url);
      final extractedData = json.decode(res.body) as Map<String, dynamic>?;
      if (extractedData == null) {
        return;
      }
      url = Uri.parse(
          'https://udemy-shop-app-dd13c-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');

      // user가 좋아요 누른 아이템 모두 받아옴
      final favoritesRes = await http.get(url);
      // favoriteData의 type은 Map임
      final favoriteData = json.decode(favoritesRes.body);
      final List<Product> loadedProducts = [];

      extractedData.forEach(
        (id, prodData) {
          loadedProducts.insert(
              0,
              Product(
                  id: id,
                  title: prodData['title'],
                  description: prodData['description'],
                  price: prodData['price'],
                  imageUrl: prodData['imageUrl'],
                  // 유저의 favoriteData 자체가 없으면 null
                  // 있지만 Map에 존재하지 않으면 false
                  isFavorite: favoriteData == null
                      ? false
                      : favoriteData[id] ?? false));
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product item) async {
    final url = Uri.parse(
        'https://udemy-shop-app-dd13c-default-rtdb.firebaseio.com/products.json?auth=$authToken');

    try {
      final res = await http.post(url,
          body: json.encode({
            'title': item.title,
            'description': item.description,
            'imageUrl': item.imageUrl,
            'price': item.price,
            'creatorId': userId
          }));

      final id = json.decode(res.body)['name'];
      final product = Product(
        id: id,
        description: item.description,
        imageUrl: item.imageUrl,
        price: item.price,
        title: item.title,
      );

      _items.add(product);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    // 같은 아이디를 가지는 아이템이 리스트의 몇번째 인덱스에 있는지 확인
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    // 리스트 내에 해당하는 아이템이 있다면,
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://udemy-shop-app-dd13c-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

      // patch는 기존에 존재하는 data를 업데이트 하는 역할을 함.
      // 기존 data를 drop하지는 않음.
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      // 인덱스에 있는 아이템을 새 프로덕트로 변경.
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> removeProduct(String id) async {
    final url = Uri.parse(
        'https://udemy-shop-app-dd13c-default-rtdb.firebaseio.com/products/$id.json&auth=$authToken');
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    // 잠시 보관하고 있음
    Product? existingProduct = _items[existingProductIndex];
    _items.removeWhere((product) => product.id == id);
    final res = await http.delete(url);

    // 만약 오류가 발생하면 리스트에 다시 집어넣음.

    if (res.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      throw HttpException("Could not delete product");
    }

    existingProduct = null;
    notifyListeners();
  }
}
