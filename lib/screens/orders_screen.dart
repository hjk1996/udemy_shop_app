import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart';
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/order-screen';

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemCount: orderProvider.orders.length,
        itemBuilder: (ctx, idx) {
          return OrderItemWidget(orderProvider.orders[idx]);
        },
      ),
    );
  }
}
