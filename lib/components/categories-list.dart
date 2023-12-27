import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kp_restaurant/Providers/userProvider.dart';
import 'package:kp_restaurant/components/category-items-page.dart';
import 'package:kp_restaurant/domain/Dish.dart';
import 'package:kp_restaurant/domain/MenuCategory.dart';
import 'package:provider/provider.dart';

class CategoriesList extends StatefulWidget {
  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _imageUrlController = TextEditingController();

  Dio dio = Dio();

  Future<List<MenuCategory>> _fetchCategories() async {
    try {
      Response response = await dio.get(
          'http://192.168.0.101:8080/getAllCategories');
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = response.data;
        return jsonResponse.map((category) => MenuCategory.fromJson(category))
            .toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<List<Dish>> _fetchDishesByCategoryId(int categoryId) async {
    try {
      Response response = await dio.get(
          'http://192.168.0.101:8080/getDishesByCategoryId?id=$categoryId');
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = response.data;
        return jsonResponse.map((dish) => Dish.fromJson(dish)).toList();
      } else {
        throw Exception('Failed to load dishes');
      }
    } catch (e) {
      throw Exception('Failed to load dishes: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isAdmin = userProvider.isAdmin();
    return Scaffold(

      backgroundColor: Colors.deepPurple,
      body: FutureBuilder<List<MenuCategory>>(
        future: _fetchCategories(),
        builder: (BuildContext context,
            AsyncSnapshot<List<MenuCategory>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryItemsPage(
                        category: snapshot.data![index],
                        fetchDishesByCategoryId: _fetchDishesByCategoryId,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        snapshot.data![index].imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 8),
                      Text(
                        snapshot.data![index].name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin ? FloatingActionButton(
        onPressed: () {
          _showCreateItemModal(context);
        },
        child: Icon(Icons.add),
      ) : null,
    );
  }

  void _showCreateItemModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Разрешение на прокрутку модального окна
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
                  'Создание категории',
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
                  decoration: InputDecoration(labelText: 'Название'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(labelText: 'Ссылка на изображение'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _createCategory();
                    Navigator.pop(context);
                    setState(() {});
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
  Future<void> _createCategory() async {
    try {
      var data = {
        'name': _titleController.text,
        'imageUrl': _imageUrlController.text,
      };

      var response = await dio.post(
        'http://192.168.0.101:8080/createCategory',
        data: data,
      );

      if (response.statusCode == 200) {
        // Обработка успешного создания категории
      } else {
        // Обработка ошибки создания категории
      }
    } catch (e) {
      // Обработка других ошибок
    }
  }
}

