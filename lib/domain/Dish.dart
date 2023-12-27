import 'package:kp_restaurant/domain/MenuCategory.dart';

class Dish {
  int id;
  String name;
  String description;
  int price;
  MenuCategory category;
  String imageUrl;

  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      imageUrl: json['imageUrl'] as String,
      category: MenuCategory.fromJson(json['category'] as Map<String, dynamic>),
    );
  }
}