class WorkoutExercise {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final String? sets;
  final String? reps;
  final String? duration;
  final String? weight;

  WorkoutExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    this.sets,
    this.reps,
    this.duration,
    this.weight,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id']?.toString() ?? '',
      exerciseId: json['exerciseId']?.toString() ?? '',
      exerciseName: json['exerciseName'] ?? '',
      sets: json['sets']?.toString(),
      reps: json['reps']?.toString(),
      duration: json['duration']?.toString(),
      weight: json['weight']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'weight': weight,
    };
  }
}

class Workout {
  final String id;
  final String name;
  final String? description;
  final bool isShared;
  final String createdById;
  final List<WorkoutExercise> workoutExercises;

  Workout({
    required this.id,
    required this.name,
    this.description,
    required this.isShared,
    required this.createdById,
    required this.workoutExercises,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      isShared: json['isShared'] ?? false,
      createdById: json['createdById']?.toString() ?? '',
      workoutExercises: (json['workoutExercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isShared': isShared,
      'createdById': createdById,
      'workoutExercises': workoutExercises.map((e) => e.toJson()).toList(),
    };
  }
}

class CreateWorkoutDto {
  final String name;
  final String? description;
  final bool isShared;

  CreateWorkoutDto({
    required this.name,
    this.description,
    required this.isShared,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'isShared': isShared,
    };
  }
}

class UpdateWorkoutDto {
  final String? name;
  final String? description;
  final bool? isShared;

  UpdateWorkoutDto({
    this.name,
    this.description,
    this.isShared,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'isShared': isShared,
    };
  }
}
