class User {
  final int id;
  final String email;
  final String password;
  final String userName; // Используем user_name вместо firstName
  final String userSurname; // Используем user_surname вместо lastName
  final List<String> roles;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.userName,
    required this.userSurname,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      userName: json['user_name'], // Обновлено использование поля user_name
      userSurname: json['user_surname'], // Обновлено использование поля user_surname
      roles: List<String>.from(json['roles']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'user_name': userName,
      'user_surname': userSurname,
      'roles': roles,
      // Другие поля, если есть
    };
  }
}