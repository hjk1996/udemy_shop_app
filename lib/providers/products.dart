import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product.dart';

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

  // var _showFavoritesOnly = false;

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where(((product) => product.isFavorite == true)).toList();
    // }
    // _items의 copy를 반환한다.
    // 지정되지 않은 방법으로 _item에 접근해서 수정하는 것을 방지하기 위함.
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite == true).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.parse(
        'https://udemy-shop-app-dd13c-default-rtdb.firebaseio.com/products.json');

    try {
      final res = await http.get(url);
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
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
                  isFavorite: prodData['isFavorite']));
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // 리스트 요소가 변경될 때만 notify함.
  Future<void> addProduct(Product item) async {
    final url = Uri.parse(
        'https://udemy-shop-app-dd13c-default-rtdb.firebaseio.com/products.json');

    try {
      final res = await http.post(url,
          body: json.encode({
            'title': item.title,
            'description': item.description,
            'imageUrl': item.imageUrl,
            'price': item.price,
            'isFavorite': item.isFavorite
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

  void updateProduct(String id, Product newProduct) {
    // 같은 아이디를 가지는 아이템이 리스트의 몇번째 인덱스에 있는지 확인
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    // 리스트 내에 해당하는 아이템이 있다면,
    if (prodIndex >= 0) {
      // 인덱스에 있는 아이템을 새 프로덕트로 변경.
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  void removeProduct(String id) {
    _items.removeWhere((product) => product.id == id);
    notifyListeners();
  }
}
