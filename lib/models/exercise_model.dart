enum ExerciseCategory {
  strength,
  cardio,
  flexibility,
  yoga,
  mixed,
}

enum TrackingMode {
  reps,
  time,
  both,
}

class Exercise {
  final String id;
  final String name;
  final ExerciseCategory category;
  final String? imageUrl;
  final String? description;
  final TrackingMode trackingMode;
  final bool hasWeights;
  final String createdByUserId;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    this.imageUrl,
    this.description,
    required this.trackingMode,
    required this.hasWeights,
    required this.createdByUserId,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: _parseCategory(json['category']),
      imageUrl: json['imageUrl'],
      description: json['description'],
      trackingMode: _parseTrackingMode(json['trackingMode']),
      hasWeights: json['hasWeights'] ?? false,
      createdByUserId: json['createdByUserId']?.toString() ?? '',
    );
  }

  static ExerciseCategory _parseCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'strength':
        return ExerciseCategory.strength;
      case 'cardio':
        return ExerciseCategory.cardio;
      case 'flexibility':
        return ExerciseCategory.flexibility;
      case 'yoga':
        return ExerciseCategory.yoga;
      case 'mixed':
        return ExerciseCategory.mixed;
      default:
        return ExerciseCategory.mixed;
    }
  }

  static TrackingMode _parseTrackingMode(String? mode) {
    switch (mode?.toLowerCase()) {
      case 'reps':
        return TrackingMode.reps;
      case 'time':
        return TrackingMode.time;
      case 'both':
        return TrackingMode.both;
      default:
        return TrackingMode.reps;
    }
  }

  String get categoryDisplayName {
    switch (category) {
      case ExerciseCategory.strength:
        return 'Strength';
      case ExerciseCategory.cardio:
        return 'Cardio';
      case ExerciseCategory.flexibility:
        return 'Flexibility';
      case ExerciseCategory.yoga:
        return 'Yoga';
      case ExerciseCategory.mixed:
        return 'Mixed';
    }
  }

  String get trackingModeDisplayName {
    switch (trackingMode) {
      case TrackingMode.reps:
        return 'Reps';
      case TrackingMode.time:
        return 'Time';
      case TrackingMode.both:
        return 'Both';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name.toUpperCase(),
      'imageUrl': imageUrl,
      'description': description,
      'trackingMode': trackingMode.name.toUpperCase(),
      'hasWeights': hasWeights,
      'createdByUserId': createdByUserId,
    };
  }
}

class CreateExerciseDto {
  final String name;
  final ExerciseCategory category;
  final String? imageUrl;
  final String? description;
  final TrackingMode trackingMode;
  final bool hasWeights;

  CreateExerciseDto({
    required this.name,
    required this.category,
    this.imageUrl,
    this.description,
    required this.trackingMode,
    required this.hasWeights,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category.name.toUpperCase(),
      'imageUrl': imageUrl,
      'description': description,
      'trackingMode': trackingMode.name.toUpperCase(),
      'hasWeights': hasWeights,
    };
  }
}

class UpdateExerciseDto {
  final String? name;
  final ExerciseCategory? category;
  final String? imageUrl;
  final String? description;
  final TrackingMode? trackingMode;
  final bool? hasWeights;

  UpdateExerciseDto({
    this.name,
    this.category,
    this.imageUrl,
    this.description,
    this.trackingMode,
    this.hasWeights,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category?.name.toUpperCase(),
      'imageUrl': imageUrl,
      'description': description,
      'trackingMode': trackingMode?.name.toUpperCase(),
      'hasWeights': hasWeights,
    };
  }
}
