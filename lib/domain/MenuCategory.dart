import 'package:kp_restaurant/domain/Dish.dart';

class MenuCategory {
  final int id;
  final String name;
  final String imageUrl;


  MenuCategory({
    required this.id,
    required this.name,
    required this.imageUrl,

  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    // Предполагая, что поля JSON имеют такие же имена, как и поля в модели Category
    return MenuCategory(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }
}