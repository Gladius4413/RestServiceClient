import 'package:flutter/material.dart';
import 'package:kp_restaurant/domain/user.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  User? get user => _user;

  bool isAdmin() {

    return _user != null && _user!.roles.contains('ROLE_ADMIN');
  }

  void logout() {
    _user = null; // Очистка данных пользователя
    notifyListeners();
  }
}