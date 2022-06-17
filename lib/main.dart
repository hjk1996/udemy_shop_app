import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/auth.dart';
import 'package:flutter_complete_guide/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import './providers/cart.dart';
import './providers/products.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './helpers/custom_route.dart';

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
          ChangeNotifierProvider(create: (context) => Auth()),
          // auth가 변경될 때마다 Provider 또한 rebuild된다.
          // Auth의 데이터를 Products에 제공함.
          ChangeNotifierProxyProvider<Auth, Products>(
            update: ((context, auth, previousProducts) => Products(
                auth.token,
                previousProducts == null ? [] : previousProducts.items,
                auth.userId)),
            create: (context) => Products(null, [], null),
          ),
          ChangeNotifierProvider(create: (context) => Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
            update: (context, auth, previousOrders) => Orders(
              auth.token,
              auth.userId,
              previousOrders == null ? [] : previousOrders.orders,
            ),
            create: (context) => Orders(null, null, []),
          )
        ],
        // notifty될 때마다 MaterialApp이 rebuild됨.
        child: Consumer<Auth>(
          builder: (ctx, authData, child) {
            return MaterialApp(
              title: 'My Shop',
              theme: ThemeData(
                  primarySwatch: Colors.blue,
                  accentColor: Colors.red,
                  // default font
                  fontFamily: 'Lato',
                  pageTransitionsTheme: PageTransitionsTheme(builders: {
                    TargetPlatform.android: CustomPageTransitionBuilder(),
                    TargetPlatform.iOS: CustomPageTransitionBuilder(),
                  })),
              // auth 상태에 따라 homepage가 변해야함.
              // auth 상태면 ProductDtailScreen이 홈페이지고 아니면 AuthScreen이 홈페이지임.
              home: authData.isAuth
                  // authenticate 확인됐다면 제품 스크린을 보여주고
                  ? ProductOverviewScreen()
                  // authenticate 확인되지 않으면
                  : FutureBuilder(
                      // 로컬 저장소에서 auth data 불러오기 시도
                      future: authData.tryAutoSignIn(),
                      builder: (ctx, snapshot) =>
                          snapshot.connectionState == ConnectionState.waiting
                              ? SplashScreen()
                              : AuthScreen()),
              routes: {
                ProductOverviewScreen.routeName: (ctx) =>
                    ProductOverviewScreen(),
                ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                CartScreen.routeName: (ctx) => CartScreen(),
                OrderScreen.routeName: (ctx) => OrderScreen(),
                UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
                EditProductScreen.routeName: (ctx) => EditProductScreen(),
              },
            );
          },
        ));
  }
}
