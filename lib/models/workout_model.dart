class WorkoutExercise {
  final String id;
  final String exerciseName;
  final String? workoutName;
  final int? sets;
  final int? reps;
  final int? duration;
  final int? calories;
  final int? orderInWorkout;
  final String? notes;

  WorkoutExercise({
    required this.id,
    required this.exerciseName,
    this.workoutName,
    this.sets,
    this.reps,
    this.duration,
    this.calories,
    this.orderInWorkout,
    this.notes,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id']?.toString() ?? '',
      exerciseName: json['exerciseName'] ?? '',
      workoutName: json['workoutName'],
      sets: json['sets'],
      reps: json['reps'],
      duration: json['duration'],
      calories: json['calories'],
      orderInWorkout: json['orderInWorkout'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseName': exerciseName,
      'workoutName': workoutName,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'calories': calories,
      'orderInWorkout': orderInWorkout,
      'notes': notes,
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

class CreateWorkoutExerciseDto {
  final String exerciseName;
  final int? sets;
  final int? reps;
  final int? duration;
  final int? calories;
  final int? orderInWorkout;
  final String? notes;

  CreateWorkoutExerciseDto({
    required this.exerciseName,
    this.sets,
    this.reps,
    this.duration,
    this.calories,
    this.orderInWorkout,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'calories': calories,
      'orderInWorkout': orderInWorkout,
      'notes': notes,
    };
  }
}
