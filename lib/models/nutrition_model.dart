enum NutritionCategory {
  fruit,
  vegetable,
  meat,
  dairy,
  grain,
  beverage,
  other,
}

class Nutrition {
  final String id;
  final String name;
  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatsPer100g;
  final double? fiberPer100g;
  final double? sugarPer100g;
  final NutritionCategory category;

  Nutrition({
    required this.id,
    required this.name,
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatsPer100g,
    this.fiberPer100g,
    this.sugarPer100g,
    required this.category,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      caloriesPer100g: json['caloriesPer100g']?.toDouble(),
      proteinPer100g: json['proteinPer100g']?.toDouble(),
      carbsPer100g: json['carbsPer100g']?.toDouble(),
      fatsPer100g: json['fatsPer100g']?.toDouble(),
      fiberPer100g: json['fiberPer100g']?.toDouble(),
      sugarPer100g: json['sugarPer100g']?.toDouble(),
      category: _parseCategory(json['category']),
    );
  }

  static NutritionCategory _parseCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'fruit':
        return NutritionCategory.fruit;
      case 'vegetable':
        return NutritionCategory.vegetable;
      case 'meat':
        return NutritionCategory.meat;
      case 'dairy':
        return NutritionCategory.dairy;
      case 'grain':
        return NutritionCategory.grain;
      case 'beverage':
        return NutritionCategory.beverage;
      case 'other':
        return NutritionCategory.other;
      default:
        return NutritionCategory.other;
    }
  }

  String get categoryDisplayName {
    switch (category) {
      case NutritionCategory.fruit:
        return 'Fruit';
      case NutritionCategory.vegetable:
        return 'Vegetable';
      case NutritionCategory.meat:
        return 'Meat';
      case NutritionCategory.dairy:
        return 'Dairy';
      case NutritionCategory.grain:
        return 'Grain';
      case NutritionCategory.beverage:
        return 'Beverage';
      case NutritionCategory.other:
        return 'Other';
    }
  }

  String get categoryEmoji {
    switch (category) {
      case NutritionCategory.fruit:
        return '🍎';
      case NutritionCategory.vegetable:
        return '🥬';
      case NutritionCategory.meat:
        return '🥩';
      case NutritionCategory.dairy:
        return '🥛';
      case NutritionCategory.grain:
        return '🌾';
      case NutritionCategory.beverage:
        return '🥤';
      case NutritionCategory.other:
        return '🍽️';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatsPer100g': fatsPer100g,
      'fiberPer100g': fiberPer100g,
      'sugarPer100g': sugarPer100g,
      'category': category.name.toUpperCase(),
    };
  }
}

class CreateNutritionDto {
  final String name;
  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatsPer100g;
  final double? fiberPer100g;
  final double? sugarPer100g;
  final NutritionCategory category;

  CreateNutritionDto({
    required this.name,
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatsPer100g,
    this.fiberPer100g,
    this.sugarPer100g,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatsPer100g': fatsPer100g,
      'fiberPer100g': fiberPer100g,
      'sugarPer100g': sugarPer100g,
      'category': category.name.toUpperCase(),
    };
  }
}

class UpdateNutritionDto {
  final String? name;
  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatsPer100g;
  final double? fiberPer100g;
  final double? sugarPer100g;
  final NutritionCategory? category;

  UpdateNutritionDto({
    this.name,
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatsPer100g,
    this.fiberPer100g,
    this.sugarPer100g,
    this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatsPer100g': fatsPer100g,
      'fiberPer100g': fiberPer100g,
      'sugarPer100g': sugarPer100g,
      'category': category?.name.toUpperCase(),
    };
  }
}
