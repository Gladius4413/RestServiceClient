import 'package:kp_restaurant/domain/Dish.dart';

class Basket {
  int id;
  int count;
  int summary; // Суммарная цена

  Dish dish; // Блюдо

  Basket({
    required this.id,
    required this.count,
    required this.summary,
    required this.dish,
  });

  factory Basket.fromJson(Map<String, dynamic> json) {
    return Basket(
      id: json['id'] as int,
      count: json['count'] as int,
      summary: json['summary'] as int,
      dish: Dish.fromJson(json['dish'] as Map<String, dynamic>),
    );
  }
}