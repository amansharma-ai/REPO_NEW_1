import 'food_item.dart';

class MessMenu {
  final String dayOfWeek;
  final String mealType;
  final List<FoodItem> items;

  const MessMenu({
    required this.dayOfWeek,
    required this.mealType,
    required this.items,
  });

  factory MessMenu.fromJson(Map<String, dynamic> json) {
    return MessMenu(
      dayOfWeek: json['dayOfWeek'] as String,
      mealType: json['mealType'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  String toString() =>
      'MessMenu(dayOfWeek: $dayOfWeek, mealType: $mealType, items: ${items.length})';
}
