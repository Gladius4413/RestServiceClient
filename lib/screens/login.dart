import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kp_restaurant/Providers/userProvider.dart';
import 'package:kp_restaurant/domain/user.dart';
import 'package:kp_restaurant/screens/categories.dart';
import 'package:kp_restaurant/screens/register.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  Dio dio = Dio();

  void _loginUser(BuildContext context, String email, String password) async {
    try {
      var data = {
        'email': email,
        'password': password,
      };

      var response = await dio.post(
        'http://192.168.0.101:8080/auth',
        data: data,
      );

      if (response.statusCode == 200) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final user = User.fromJson(response.data);

        userProvider.setUser(user);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoriesPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка авторизации'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Ошибка при авторизации: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Произошла ошибка при авторизации'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String email = '';
    String password = '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              onChanged: (value) {
                email = value;
              },
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              onChanged: (value) {
                password = value;
              },
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _loginUser(context, email, password);
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) => RegistrationPage()),
              );},
              child: Text(
                "Вы еще не зарегистрированы? Нажмите сюда, чтобы зарегистрироваться",
                style: TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
