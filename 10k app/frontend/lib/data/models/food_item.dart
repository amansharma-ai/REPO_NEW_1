class FoodItem {
  final int id;
  final String name;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String? servingSize;
  final bool isCustom;
  final String? foodCategory;

  const FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.servingSize,
    this.isCustom = false,
    this.foodCategory,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as int,
      name: json['name'] as String,
      calories: (json['calories'] as num).toDouble(),
      proteinG: (json['proteinG'] as num).toDouble(),
      carbsG: (json['carbsG'] as num).toDouble(),
      fatG: (json['fatG'] as num).toDouble(),
      servingSize: json['servingSize'] as String?,
      isCustom: json['custom'] as bool? ?? false,
      foodCategory: json['foodCategory'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'calories': calories,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatG': fatG,
    'servingSize': servingSize,
  };
}
