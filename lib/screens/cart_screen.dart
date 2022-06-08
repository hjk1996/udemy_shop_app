import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../widgets/cart_item.dart';
import '../providers/orders.dart';
import '../screens/orders_screen.dart';

class TotalPriceBar extends StatelessWidget {
  const TotalPriceBar({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Total",
              style: const TextStyle(fontSize: 20),
            ),
            // spacer widget 아래 있는 위젯을 한쪽으로 몰아 버린다. (spacer가 남은 공간을 차지한다는 의미)
            Spacer(),
            Chip(
              label: Text(
                '\$${cart.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Theme.of(context).accentColor,
            ),
            OrderButton(cart: cart)
          ],
        ),
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading == true)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });

              final cartItemList = widget.cart.items.values.toList();
              // order의 변화는 들을 필요가 없음

              try {
                await Provider.of<Orders>(context, listen: false)
                    .addOrder(cartItemList, widget.cart.totalAmount);

                setState(() {
                  _isLoading = false;
                });

                // 하지만 카트를 비워야하므로 cart의 변화는 들어야함.
                if (cartItemList.isNotEmpty) {
                  widget.cart.clear();
                }
              } catch (error) {
                throw error;
              }
            },
      child: _isLoading ? CircularProgressIndicator() : Text('Order Now'),
      style: TextButton.styleFrom(
          textStyle: TextStyle(color: Theme.of(context).primaryColor)),
    );
  }
}

class CartScreen extends StatelessWidget {
  static const routeName = "/cart";

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final cartItemList = cart.items.values.toList();
    return Scaffold(
        appBar: AppBar(title: Text('Your cart')),
        body: Column(
          children: <Widget>[
            TotalPriceBar(cart: cart),
            SizedBox(
              height: 10,
            ),
            // Expanded widget은 남은 공간을 모두 차지해버림.
            Expanded(
                child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, idx) {
                final cartItem = cartItemList[idx];
                return CartItemWidget(
                    id: cartItem.id,
                    productId: cartItem.productId,
                    title: cartItem.title,
                    quantity: cartItem.quantity,
                    price: cartItem.price);
              },
            ))
          ],
        ));
  }
}
