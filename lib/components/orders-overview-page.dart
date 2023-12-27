import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kp_restaurant/domain/Order.dart';



class OrdersOverviewPage extends StatefulWidget {
  const OrdersOverviewPage({Key? key}) : super(key: key);

  @override
  _OrdersOverviewPageState createState() => _OrdersOverviewPageState();
}

class _OrdersOverviewPageState extends State<OrdersOverviewPage> {
  List<Order> orders = [];

  Future<void> fetchOrders() async {
    var dio = Dio();
    var url = 'http://192.168.0.101:8080/getAllOrders';

    try {
      var response = await dio.get(url);

      if (response.statusCode == 200) {
        List<dynamic> responseData = response.data;
        setState(() {
          orders = responseData.map((data) => Order.fromJson(data)).toList();

        });
      } else {
        // Handle other status codes
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network errors or exceptions
      print('Error: $error');
    }
  }

  void _updateOrderStatus(int orderId, int index) async {
    var dio = Dio();
    var url = 'http://192.168.0.101:8080/updateOrderStatus?id=$orderId&index=$index';

    try {
      var response = await dio.put(url);

      if (response.statusCode == 200) {
        print('Status updated successfully');
        // Обновляем список заказов после изменения статуса
        await fetchOrders();
        setState(() {}); // Обновляем состояние страницы
      } else {
        // Handle other status codes
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network errors or exceptions
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Color _getBackgroundColor(List<Status> statuses) {
    print("Status in method getColor${statuses[0]}");
    if (statuses.contains(Status.STATUS_PENDING)) {
      return Colors.grey;
    } else if (statuses.contains(Status.STATUS_APROVED)) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders Overview'),
      ),
      backgroundColor: Colors.deepPurple,
      body: ListView.builder(
        key: UniqueKey(), // Добавляем ключ
        itemCount: orders.length,
        itemBuilder: (context, index) {
          var order = orders[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: _getBackgroundColor(order.status),
                border: Border.all(
                  color: Colors.black,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID: ${order.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Status: ${order.status[0].toString()}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Summary: ${order.summary}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'User ID: ${order.user.id}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  if (order.status.contains(Status.STATUS_PENDING))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _updateOrderStatus(order.id, 1); // Принять: index = 1
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                          ),
                          child: Text('Принять'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _updateOrderStatus(order.id, 0); // Отклонить: index = 0
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                          ),
                          child: Text('Отклонить'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
