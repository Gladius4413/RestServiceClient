import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kp_restaurant/domain/Order.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kp_restaurant/domain/Order.dart';

class UserOrdersPage extends StatefulWidget {
  final int userId;

  const UserOrdersPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserOrdersPageState createState() => _UserOrdersPageState();
}

class _UserOrdersPageState extends State<UserOrdersPage> {
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    var dio = Dio();
    var url = 'http://192.168.0.101:8080/getOrderByUserId?id=${widget.userId}';

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

  Color _getBackgroundColor(List<Status> statuses) {
    if (statuses.contains(Status.STATUS_PENDING)) {
      return Colors.grey;
    } else if (statuses.contains(Status.STATUS_APROVED)) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
  String _getStatusString(List<Status> statuses) {
    if (statuses.contains(Status.STATUS_PENDING)) {
      return "Ожидание";
    } else if (statuses.contains(Status.STATUS_APROVED)) {
      return "Принят";
    } else {
      return "Отклонен";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      backgroundColor: Colors.deepPurple, // Фиолетовый цвет фона страницы
      body: ListView.builder(
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
                    'Номер заказа: ${order.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Статус: ${_getStatusString(order.status)}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Сумма: ${order.summary}',
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
