import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:kp_restaurant/screens/login.dart';
class RegistrationPage extends StatelessWidget {
  RegistrationPage({Key? key}) : super(key: key);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  Dio dio = Dio();

  void _registerUser(BuildContext context) async {
    String _email = _emailController.text.trim();
    String _password = _passwordController.text.trim();
    String _firstName = _firstNameController.text.trim();
    String _lastName = _lastNameController.text.trim();

    if (_email.isEmpty || _password.isEmpty || _firstName.isEmpty || _lastName.isEmpty) {
      return;
    }

    try {
      var data = {
        'email': _email,
        'password': _password,
        'user_name': _firstName,
        'user_surname': _lastName,
      };

      var response = await dio.post(
        'http://192.168.0.101:8080/register',
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.statusCode == 200) {
        _showLoginScreen(context);
        _showSnackBar(context, 'Registration Successful');
      } else {
        _showSnackBar(context, 'Registration Failed');
      }
    } catch (e) {
      print("Error during registration: $e");
      _showSnackBar(context, 'Error during registration');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLoginScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => LoginPage(),
      ),
    );
  }

  Widget _input(String hint, TextEditingController controller, bool obscure) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _registerButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () {
          _registerUser(context);
        },
        child: const Text('Register'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _input('Email', _emailController, false),
            _input('Password', _passwordController, true),
            _input('First Name', _firstNameController, false),
            _input('Last Name', _lastNameController, false),
            _registerButton(context),
          ],
        ),
      ),
    );
  }
}
