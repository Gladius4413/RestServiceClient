
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kp_restaurant/Providers/userProvider.dart';
import 'package:kp_restaurant/domain/Dish.dart';
import 'package:kp_restaurant/domain/MenuCategory.dart';
import 'package:provider/provider.dart';

class CategoryItemsPage extends StatefulWidget {
  final MenuCategory category;
  final Future<List<Dish>> Function(int) fetchDishesByCategoryId;

  CategoryItemsPage({required this.category, required this.fetchDishesByCategoryId});

  @override
  _CategoryItemsPageState createState() => _CategoryItemsPageState();
}

class _CategoryItemsPageState extends State<CategoryItemsPage> {
  late Future<List<Dish>> _dishesFuture;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _imageUrlController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    _dishesFuture = widget.fetchDishesByCategoryId(widget.category.id);
  }

  Future<void> addToBasket(String dishName, BuildContext context) async {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      var email = userProvider.user!.email;
      var dio = Dio();
      var url = 'http://192.168.0.101:8080/addToBasket?name=$dishName&email=$email'; // Замените на ваш URL

      try {
        var response = await dio.post(
          url,
          data: {
            'name': dishName,
            'email': email,
          },
        );

        if (response.statusCode == 200) {
          // Обработка успешного ответа
          print('Товар добавлен в корзину');
        } else {
          // Обработка других кодов состояния
          print('Произошла ошибка: ${response.statusCode}');
        }
      } catch (error) {
        // Обработка ошибок сети или других исключений
        print('Произошла ошибка: $error');
      }
    } else {
      print('Пользователь не авторизован'); // Обработка случая, когда пользователь не авторизован
    }
  }


  void _showDishDetailsModal(BuildContext context, Dish dish) {
    showModalBottomSheet(
      isScrollControlled: true, // Позволяет содержимому модального окна использовать весь доступный экран
      context: context,
      builder: (BuildContext modalContext) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dish.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    dish.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Описание: ${dish.description}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Цена: ${dish.price.toString()} руб',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                 await   addToBasket(dish.name, modalContext);
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Text('Товар добавлен в корзину'),
                   ),
                 );
                 Navigator.pop(modalContext);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurple, // Цвет фона кнопки
                  ),
                  child: Text(
                    'Добавить в корзину',
                    style: TextStyle(
                      color: Colors.white, // Цвет текста на кнопке
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = Provider.of<UserProvider>(context).isAdmin();

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      backgroundColor: Colors.deepPurple,
      body: FutureBuilder<List<Dish>>(
        future: _dishesFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Dish>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Нет данных'));
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  _showDishDetailsModal(context, snapshot.data![index]);
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            snapshot.data![index].imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.data![index].name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Price: ${snapshot.data![index].price.toString()} руб',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () {
          _showCreateDishModal(context);
        },
        child: Icon(Icons.add),
      )
          : null,
    );
  }
  void _showCreateDishModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Создание блюда',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Название блюда'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Описание блюда'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(labelText: 'Ссылка на изображение блюда'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Цена блюда (в рублях)'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _createDish();
                    Navigator.pop(context);
                    setState(() {
                      // Перезагрузить данные после создания блюда
                      _dishesFuture = widget.fetchDishesByCategoryId(widget.category.id);
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: Text('Создать'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Future<void> _createDish() async {
    var categoryName = widget.category.name;
    try {
      var data = {
        'name': _titleController.text,
        'description': _descriptionController.text,
        'imageUrl': _imageUrlController.text,
        'price': double.parse(_priceController.text),
      };

      var response = await dio.post(
        'http://192.168.0.101:8080/createDish?categoryName=$categoryName',
        data: data,
      );

      if (response.statusCode == 200) {
        // Обработка успешного создания блюда
      } else {
        // Обработка ошибки создания блюда
      }
    } catch (e) {
      // Обработка других ошибок
    }
  }
}

