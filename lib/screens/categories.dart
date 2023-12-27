import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:kp_restaurant/Providers/userProvider.dart';
import 'package:kp_restaurant/components/basket-list.dart';
import 'package:kp_restaurant/components/categories-list.dart';
import 'package:kp_restaurant/components/my-profile.dart';
import 'package:kp_restaurant/screens/login.dart';
import 'package:provider/provider.dart';


class CategoriesPage extends StatefulWidget {
  CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  int sectionIndex = 0;

  @override
  void initState() {
    super.initState();
    _displayUserInfo();
  }

  void _displayUserInfo() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      print('User Info:');
      print('Email: ${userProvider.user!.email}');
      print('First Name: ${userProvider.user!.userName}');
      print('Last Name: ${userProvider.user!.userSurname}');
      print('Roles:');
      userProvider.user!.roles.forEach((role) {
        print('- $role');
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: Text('Rest'),
          leading: Icon(Icons.restaurant,  color: Colors.deepPurple),
          actions: <Widget>[
            TextButton.icon(
              onPressed: () {
                _logout(context);
              },
              icon: Icon(Icons.exit_to_app, color: Colors.deepPurple),
              label: Text('Выход'),
            )
          ],
        ),
        body: _getBodyWidget(),
        bottomNavigationBar: CurvedNavigationBar(
          items: const <Widget>[
            Icon(Icons.menu_book , color: Colors.deepPurple),
            Icon(Icons.shopping_basket, color: Colors.deepPurple),
            Icon(Icons.person, color: Colors.deepPurple),
          ],
          index: sectionIndex,
          height: 50,
          color: Colors.white,
          buttonBackgroundColor: Colors.white,
          backgroundColor: Colors.deepPurple.withOpacity(0.5),
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 500),
          onTap: (int index) {
            setState(() => sectionIndex = index);
          },
        ),
      ),
    );
  }

  Widget _getBodyWidget() {
    switch (sectionIndex) {
      case 0:
        return CategoriesList();
      case 1:
        return BasketList();
      case 2:
        return MyProfile(); // Замените на вашу страницу профиля
      default:
        return CategoriesList();
    }
  }

  void _logout(BuildContext context) {
    // Получаем экземпляр провайдера пользователя
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Вызываем метод для выхода из аккаунта (очистка данных пользователя)
    userProvider.logout();

    // После выхода из аккаунта переходим на страницу логина
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
