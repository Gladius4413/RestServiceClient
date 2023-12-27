import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kp_restaurant/Providers/userProvider.dart';
import 'package:kp_restaurant/components/orders-overview-page.dart';
import 'package:kp_restaurant/components/user-order-page.dart';
import 'package:kp_restaurant/domain/user.dart';
import 'package:provider/provider.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key});

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user != null) {
      _firstNameController.text = user.userName ?? '';
      _lastNameController.text = user.userSurname ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("My Profile"),
      ),
      backgroundColor: Colors.deepPurple,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileField(
              labelText: 'First Name',
              controller: _firstNameController,
            ),
            SizedBox(height: 10),
            _buildProfileField(
              labelText: 'Last Name',
              controller: _lastNameController,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _isEditing
                    ? ElevatedButton(
                  onPressed: () {
                    _updateUserData(userProvider);
                  },
                  child: Text('Submit'),
                )
                    : ElevatedButton(
                  onPressed: () {
                    _enableEditing();
                  },
                  child: Text('Edit'),
                ),
                if (_isEditing)
                  ElevatedButton(
                    onPressed: () {
                      _disableEditing();
                    },
                    child: Text('Cancel'),
                  ),
              ],
            ),
            SizedBox(height: 20),
            if (userProvider.isAdmin()) // Показать кнопку только для админа
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrdersOverviewPage(), // Замените на вашу страницу просмотра заказов пользователей
                      ),
                    );
                  },
                  child: Text('Просмотреть заказы пользователей'),
                ),
              ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserOrdersPage(userId: userProvider.user!.id),
                    ),
                  );
                },
                child: Text('Просмотреть заказы'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String labelText,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          style: TextStyle(color: Colors.deepPurple),
          enabled: _isEditing,
          controller: controller,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.deepPurple),
              borderRadius: BorderRadius.circular(15.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.deepPurple),
              borderRadius: BorderRadius.circular(15.0),
            ),
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
          ),
        ),
      ],
    );
  }

  void _enableEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _disableEditing() {
    setState(() {
      _isEditing = false;
    });
  }

  void _updateUserData(UserProvider userProvider) {
    if (_firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty) {
      User updatedUser = User(
        id: userProvider.user!.id,
        email: userProvider.user!.email,
        password: userProvider.user!.password,
        userName: _firstNameController.text,
        userSurname: _lastNameController.text,
        roles: userProvider.user!.roles,
      );

      _sendUpdatedUserDataToServer(updatedUser, userProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    setState(() {
      _isEditing = false;
    });
  }

  void _sendUpdatedUserDataToServer(
      User updatedUser, UserProvider userProvider) {
    Dio dio = Dio();
    String endpoint = 'http://192.168.0.101:8080/updateUserDataById';

    dio.put(endpoint, data: updatedUser.toJson()).then((response) {
      if (response.statusCode == 200) {
        userProvider.setUser(updatedUser);
      } else {
        // Handle server update error
      }
    }).catchError((error) {
      // Handle server connection error
    });
  }
}