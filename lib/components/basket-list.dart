import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kp_restaurant/Providers/userProvider.dart';
import 'package:kp_restaurant/domain/Basket.dart';
import 'package:provider/provider.dart';

class BasketList extends StatefulWidget {
  const BasketList({Key? key}) : super(key: key);

  @override
  _BasketListState createState() => _BasketListState();
}

class _BasketListState extends State<BasketList> {
  List<Basket> baskets = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    var user = userProvider.user;

    if (user != null) {
      var dio = Dio();
      var url = 'http://192.168.0.101:8080/getGoodsInBasket?id=${user.id}'; // Замените на ваш URL

      try {
        var response = await dio.get(url);

        if (response.statusCode == 200) {
          List<dynamic> responseData = response.data;
          setState(() {
            baskets = responseData.map((data) => Basket.fromJson(data)).toList();
          });
        } else {
          // Обработка других кодов состояния
          print('Произошла ошибка: ${response.statusCode}');
        }
      } catch (error) {
        // Обработка ошибок сети или других исключений
        print('Произошла ошибка: $error');
      }
    }
  }

  Future<void> updateCountInBasket(int index, int id) async {
    var dio = Dio();
    var url = 'http://192.168.0.101:8080/updateCountDishInBasket?index=$index&id=$id';

    try {
      var response = await dio.put(url);

      if (response.statusCode == 200) {
        // После успешного обновления данных, обновите состояние страницы
        fetchData();
      } else {
        // Обработка других кодов состояния
        print('Произошла ошибка: ${response.statusCode}');
      }
    } catch (error) {
      // Обработка ошибок сети или других исключений
      print('Произошла ошибка: $error');
    }
  }
  Future<void> clearBasket(int userId) async {
    var dio = Dio();
    var url = 'http://192.168.0.101:8080/clearBasket?id=$userId';

    try {
      var response = await dio.delete(url);

      if (response.statusCode == 200) {
        print('Корзина очищена');
      } else {
        print('Произошла ошибка: ${response.statusCode}');
      }
    } catch (error) {
      print('Произошла ошибка: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    var totalSum = baskets.fold<int>(0, (previousValue, element) => previousValue + element.summary);

    return Scaffold(
      body: baskets.isEmpty
          ? Center(
        child: Text('Корзина пуста'),
      )
          : ListView.builder(
        itemCount: baskets.length,
        itemBuilder: (context, index) {
          var basket = baskets[index];
          return ListTile(
            leading: Image.network(basket.dish.imageUrl),
            title: Text(
              basket.dish.name,
              style: TextStyle(color: Colors.white), // Изменяем цвет текста
            ),
            subtitle: Text(
              'Количество: ${basket.count}\nЦена: ${basket.summary} руб',
              style: TextStyle(color: Colors.white70), // Изменяем цвет текста
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.remove, color: Colors.white), // Изменяем цвет иконки
                  onPressed: () {
                    updateCountInBasket(0, basket.dish.id); // Уменьшение количества
                  },
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.white), // Изменяем цвет иконки
                  onPressed: () {
                    updateCountInBasket(1, basket.dish.id); // Увеличение количества
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: baskets.isEmpty // Показываем или скрываем кнопку заказа в зависимости от состояния корзины
          ? null
          : FloatingActionButton.extended(
        onPressed: () async {
          var dio = Dio();
          var userProvider = Provider.of<UserProvider>(context, listen: false);
          var user = userProvider.user;

          if (user != null) {
            var email = user.email;
            var url = 'http://192.168.0.101:8080/createOrder';

            for (var basketItem in baskets) {
              try {
                var response = await dio.post(
                  url,
                  data: {
                    'number_order': 2,
                    'count': basketItem.count,
                    'summary_dish': basketItem.summary,
                    'summary': totalSum,
                    'dish': {
                      'id': basketItem.dish.id,
                      'name': basketItem.dish.name,
                      'imageUrl': basketItem.dish.imageUrl

                    },
                    'user': {
                      'id': user.id,
                      'email': user.email,
                      'password': user.password,
                      'userName': user.userName,
                      'userSurname': user.userSurname,
                      'roles': user.roles,
                      // Другие данные о пользователе, если это необходимо
                    },
                    // Другие данные о статусе и т.д., если они необходимы
                  },
                );

                if (response.statusCode == 200) {

                  print('Заказ создан');
                  await clearBasket(user.id); // Вызов функции очистки корзины
                  setState(() {
                    baskets.clear(); // Очистка корзины в приложении
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Заказ создан'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  print('Произошла ошибка: ${response.statusCode}');
                }
              } catch (error) {
                print('Произошла ошибка: $error');
              }
            }
          }
        },
        label: Text('Заказать'),
        icon: Icon(Icons.shopping_cart),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      persistentFooterButtons: baskets.isEmpty // Скрыть суммарную цену, если корзина пуста
          ? null
          : [
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: Colors.grey[300],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Суммарная цена: $totalSum руб',
                style: TextStyle(color: Colors.deepPurple), // Изменяем цвет текста
              ),
              SizedBox(width: 16), // Добавьте промежуток между текстом и кнопкой
            ],
          ),
        ),
      ],
      backgroundColor: Colors.deepPurple, // Фон всей страницы deepPurple
    );
  }
}
