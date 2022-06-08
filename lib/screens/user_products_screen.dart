import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import '../screens/edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = "/user-product-screen";

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // FutureBuilder를 사용할 경우 build 내에서 provider의 listen을 true로 해놓으면 무한루프가 발생함.
    // future가 실행되면서 provider의 state를 변경하고 그 state를 build 내에서 listen 하므로 다시 build가 계속 발생
    print('Rebuilding User Products Screen..');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: Icon(Icons.add))
        ],
      ),
      drawer: AppDrawer(),
      // FutureBuilder를 이용해서 새로고침한 이후의 products를 products로 받아올 수 있다.
      body: FutureBuilder(
        future: _refreshProducts(context),
        // RefreshIndicator를 통해 pull-to-refresh를 구현할 수 있다.
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await _refreshProducts(context);
                    },
                    child: Consumer<Products>(
                      builder: ((context, products, child) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: ListView.builder(
                              itemCount: products.items.length,
                              itemBuilder: (ctx, idx) => Column(
                                children: [
                                  UserProductItem(
                                    id: products.items[idx].id!,
                                    title: products.items[idx].title!,
                                    imageUrl: products.items[idx].imageUrl!,
                                  ),
                                  Divider()
                                ],
                              ),
                            ),
                          )),
                    ),
                  ),
      ),
    );
  }
}
