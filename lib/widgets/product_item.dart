import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem({required this.id, required this.title, required this.imageUrl});
  Widget _buildFavoriteIconButton(
      BuildContext context, Product product, Widget? child) {
    return IconButton(
        icon: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border),
        onPressed: () {
          product.toggleFavoriteStatus();
        },
        color: Theme.of(context).accentColor);
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    // cart에 아이템만 추가할 것이기 때문에 change를 듣지 않아도 됨.
    final cart = Provider.of<Cart>(context, listen: false);
    print("product rebuilds");
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(ProductDetailScreen.routeName, arguments: product.id);
        },
        child: GridTile(
          child: Image.network(
            product.imageUrl!,
            fit: BoxFit.cover,
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            // Consumer를 이용해서 re-render될 범위를 좁혀줄 수 있다.
            leading: Consumer<Product>(
              builder: _buildFavoriteIconButton,
            ),
            title: Text(
              product.title!,
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                cart.addItem(product.id!, product.price!, product.title!);
                // widget에서 가장 가까이 있는 scaffold에 message를 보냄.
                // 이 경우에는 ProductOverViewScreen
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    'HI',
                    textAlign: TextAlign.center,
                  ),
                  duration: Duration(seconds: 1),
                  // SnackBar widget을 눌렀을 때 실행할 행동을 정의할 수 있음.
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeSingleItem(product.id!);
                    },
                  ),
                ));
              },
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
      ),
    );
  }
}
