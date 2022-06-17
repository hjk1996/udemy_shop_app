import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem({required this.id, required this.title, required this.imageUrl});
  Widget _buildFavoriteIconButton(
      BuildContext context, Product product, Widget? child) {
    final authData = Provider.of<Auth>(context, listen: false);
    return IconButton(
        icon: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border),
        onPressed: () async {
          try {
            await product.toggleFavoriteStatus(
                authData.token!, authData.userId!);
          } catch (error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
              'An Error Occured.',
              textAlign: TextAlign.center,
            )));
          }
        },
        color: Theme.of(context).accentColor);
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    // cart에 아이템만 추가할 것이기 때문에 change를 듣지 않아도 됨.
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    print("product rebuilds");
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(ProductDetailScreen.routeName, arguments: product.id);
        },
        child: GridTile(
          // 이미지 로딩되기 전에는 placeholder image를 보여주고
          // 이미지 로딩이 완료되면 placeholder image에서 image로 fade됨.
          child: Hero(
            tag: product.id!,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl!),
              fit: BoxFit.cover,
            ),
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
