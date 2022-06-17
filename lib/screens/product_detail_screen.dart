import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';
  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    // listen을 false로 설정해놓으면 provider로 전달받은 object가 변하더라도 rendering 다시 안됨.
    // data를 한번만 가져오고 업데이트 할 필요가 없을 때 사용함.
    // 다른 widget에서 product를 추가했을때 이 화면이 업데이트 될 필요가 없으므로 listen을 false로 설정함.
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title!),
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          // SliverAppBar는 view에서 사라지면 (scroll-down) app bar로 변함.
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title!),
              // Hero widget은 화면을 넘나드는 widget이다.
              // 한 화면에 있는 동일한 이미지를 다른 화면에 있는 동일한 이미지로
              // 자연스럽게 전환시키기 위해서 주로 사용한다.
              // tag를 통해 child를 식별하므로 유니크한 tag를 전달해줘야한다.
              background: Hero(
                tag: loadedProduct.id!,
                child: Image.network(
                  loadedProduct.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(
              height: 10,
            ),
            Text(
              '\$${loadedProduct.price}',
              style: TextStyle(color: Colors.grey, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(
                loadedProduct.description!,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
            SizedBox(
              height: 800,
            )
          ])),
        ],
      ),
    );
  }
}
