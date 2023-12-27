
import 'package:flutter/cupertino.dart';
import 'package:kp_restaurant/domain/Dish.dart';
import 'package:kp_restaurant/domain/user.dart';
enum Status {
  STATUS_PENDING,
  STATUS_APROVED,
  STATUS_DECLINE,
}


class Order {
  final int id;
  final int numberOrder;
  final int count;
  final int summaryDish;
  final int summary;
  final Dish dish;
  final User user;
  final List<Status> status; // Добавлено поле статуса

  Order({
    required this.id,
    required this.numberOrder,
    required this.count,
    required this.summaryDish,
    required this.summary,
    required this.dish,
    required this.user,
    required this.status, // Добавлено поле статуса
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<dynamic> statuses = json['statuses'] ?? [];
    List<String> statusStrings = statuses.map((status) => status.toString()).toList();

    List<Status> parsedStatuses = _parseStatus(statusStrings);
    print(parsedStatuses[0]);
    return Order(
      id: json['id'],
      numberOrder: json['number_order'],
      count: json['count'],
      summaryDish: json['summary_dish'],
      summary: json['summary'],
      dish: Dish.fromJson(json['dish']),
      user: User.fromJson(json['user']),
      status: parsedStatuses, // Используем обработанные статусы
    );
  }
  static List<Status> _parseStatus(List<String> statuses) {
    final lowerCaseStatuses = statuses.map((status) => status.toLowerCase()).toList();

    List<Status> parsedStatuses = lowerCaseStatuses.map((lowerCaseStatus) {
      print(lowerCaseStatus);
      switch (lowerCaseStatus) {
        case 'status_pending':
          return Status.STATUS_PENDING;
        case 'status_aproved':
          return Status.STATUS_APROVED;
        case 'status_decline':
          return Status.STATUS_DECLINE;
        default:
          return Status.STATUS_PENDING; // По умолчанию
      }
    }).toList();
    return parsedStatuses;
  }
}