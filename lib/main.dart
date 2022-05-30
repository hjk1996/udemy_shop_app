import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/cart.dart';
import './providers/products.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';


// provider를 통해 data를 제공해주기 위해서는 모든 interested widgets에 대해
// 가장 높은 포인트에서 data를 제공해줘야한다.

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider로 widget을 감싸줘야 change news를 전달할 수 있다.
    // ChangeNotifierProvider를 이용해 데이터를 전해주기 위해서는 데이터를 전달받는 위젯이 위젯 트리의 하위에 있어야한다.
    // 여러 개의 Provider를 사용하기 위해서는 MultiProvider를 사용하자.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Products()),
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProvider(create: (context) => Orders())
      ],
      child: MaterialApp(
        title: 'My Shop',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          accentColor: Colors.red,
          // default font
          fontFamily: 'Lato',
        ),
        home: ProductOverviewScreen(),
        routes: {
          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),
          OrderScreen.routeName: (ctx) => OrderScreen()
        },
      ),
    );
  }
}
