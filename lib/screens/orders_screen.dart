import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart';
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = '/order-screen';

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // 그럴 일은 없겠지만,
  // Orders가 update될 때마다 위젯이 rebuild 되는 것을 방지하기 위해서 (http request 계속 보내니까)
  // init할 때 Future를 한 번만 받아와서 사용함.
  late Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("building orders");
    // final orderProvider = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(),
        drawer: AppDrawer(),
        // FutreBuilder는 future가 반환하는 snapshot에 따라 다른 위젯을 빌딩할 수 있게 해주는 위젯임
        // loading 처리할 떄 좋음.
        body: FutureBuilder(
          future: _ordersFuture,
          builder: (ctx, dataSnapshot) {
            // 만약 아직 로딩중이라면,
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
        
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapshot.error != null) {
                // error handling..
                return Center(
                  child: Text('An error occured!'),
                );
              } else {
                return Consumer<Orders>(
                    builder: ((ctx, orderData, child) => ListView.builder(
                          itemCount: orderData.orders.length,
                          itemBuilder: (ctx, idx) {
                            return OrderItemWidget(orderData.orders[idx]);
                          },
                        )));
              }
            }
          },
        ));
  }
}
