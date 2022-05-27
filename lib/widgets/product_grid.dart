import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import 'package:provider/provider.dart';

import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showOnlyFavorites;

  ProductsGrid(this.showOnlyFavorites);

  @override
  Widget build(BuildContext context) {
    // Provider 폴더 안에 있는 Products와 직접 연결.
    // products provider의 변화를 들을 수 있음.
    final productsProvider = Provider.of<Products>(context);
    // filtering logic은 provider 내에서 하는 것이 좋다.
    final products =
        showOnlyFavorites ? productsProvider.favoriteItems : productsProvider.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        // 2열
        crossAxisCount: 2,
        // 가로세로비
        childAspectRatio: 3 / 2,
        // 열 간격
        crossAxisSpacing: 20,
        // 행 간격
        mainAxisSpacing: 20,
      ),
      itemBuilder: (ctx, i) {
        // GridView에서 item을 보여주는 각 셀인 ProductItem에
        // ChangeNotifierProvider를 달아주고 Product Provider를 제공해주면서
        // ProductItem이 Product의 변화를 들을 수 있게 됐음.
        // 이미 존재하는 object를 다시 사용하는 경우에는 value constructor를 사용하는 것이 좋음. (list)
        return ChangeNotifierProvider.value(
          // create: (context) => currentProduct,
          value: products[i],
          child: ProductItem(
              // id: currentProduct.id,
              // title: currentProduct.title,
              // imageUrl: currentProduct.imageUrl,
              ),
        );
      },
    );
  }
}
