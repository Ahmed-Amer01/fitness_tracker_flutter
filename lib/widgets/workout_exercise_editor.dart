import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';

class WorkoutExerciseEditor extends StatefulWidget {
  final WorkoutExercise? workoutExercise;
  final Exercise? exercise;
  final VoidCallback? onDelete;
  final Function(WorkoutExercise) onUpdate;

  const WorkoutExerciseEditor({
    super.key,
    this.workoutExercise,
    this.exercise,
    this.onDelete,
    required this.onUpdate,
  });

  @override
  State<WorkoutExerciseEditor> createState() => _WorkoutExerciseEditorState();
}

class _WorkoutExerciseEditorState extends State<WorkoutExerciseEditor> {
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _durationController;
  late TextEditingController _caloriesController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing values or empty
    _setsController = TextEditingController(
        text: widget.workoutExercise?.sets?.toString() ?? '');
    _repsController = TextEditingController(
        text: widget.workoutExercise?.reps?.toString() ?? '');
    _durationController = TextEditingController(
        text: widget.workoutExercise?.duration?.toString() ?? '');
    _caloriesController = TextEditingController(
        text: widget.workoutExercise?.calories?.toString() ?? '');
    _notesController =
        TextEditingController(text: widget.workoutExercise?.notes ?? '');
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateWorkoutExercise() {
    final exerciseName =
        widget.exercise?.name ?? widget.workoutExercise?.exerciseName ?? '';

    final workoutExercise = WorkoutExercise(
      id: widget.workoutExercise?.id ?? '',
      exerciseName: exerciseName,
      sets: int.tryParse(_setsController.text),
      reps: int.tryParse(_repsController.text),
      duration: int.tryParse(_durationController.text),
      calories: int.tryParse(_caloriesController.text),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    widget.onUpdate(workoutExercise);
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise ?? _getExerciseFromWorkoutExercise();
    final trackingMode = exercise?.trackingMode ?? TrackingMode.reps;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        _getCategoryColor(exercise?.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(exercise?.category),
                    color: _getCategoryColor(exercise?.category),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise?.name ??
                            widget.workoutExercise?.exerciseName ??
                            'Unknown Exercise',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        exercise?.categoryDisplayName ?? 'Unknown Category',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getCategoryColor(exercise?.category),
                            ),
                      ),
                    ],
                  ),
                ),
                if (widget.onDelete != null)
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Tracking inputs based on exercise type
            _buildTrackingInputs(trackingMode),

            const SizedBox(height: 12),

            // Calories input
            TextField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: 'Calories (Optional)',
                suffixText: 'kcal',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _updateWorkoutExercise(),
            ),

            const SizedBox(height: 12),

            // Notes input
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (_) => _updateWorkoutExercise(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingInputs(TrackingMode trackingMode) {
    switch (trackingMode) {
      case TrackingMode.reps:
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: _setsController,
                decoration: const InputDecoration(
                  labelText: 'Sets',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateWorkoutExercise(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _repsController,
                decoration: const InputDecoration(
                  labelText: 'Reps',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateWorkoutExercise(),
              ),
            ),
          ],
        );
      case TrackingMode.time:
        return TextField(
          controller: _durationController,
          decoration: const InputDecoration(
            labelText: 'Duration',
            suffixText: 'seconds',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => _updateWorkoutExercise(),
        );
      case TrackingMode.both:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _setsController,
                    decoration: const InputDecoration(
                      labelText: 'Sets',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _updateWorkoutExercise(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _updateWorkoutExercise(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (Optional)',
                suffixText: 'seconds',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _updateWorkoutExercise(),
            ),
          ],
        );
    }
  }

  Exercise? _getExerciseFromWorkoutExercise() {
    // This would need to be implemented based on how you want to fetch exercise details
    // For now, return null and rely on the exercise parameter
    return null;
  }

  IconData _getCategoryIcon(ExerciseCategory? category) {
    switch (category) {
      case ExerciseCategory.strength:
        return Icons.fitness_center;
      case ExerciseCategory.cardio:
        return Icons.directions_run;
      case ExerciseCategory.flexibility:
        return Icons.accessibility;
      case ExerciseCategory.yoga:
        return Icons.self_improvement;
      case ExerciseCategory.mixed:
        return Icons.sports_gymnastics;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getCategoryColor(ExerciseCategory? category) {
    switch (category) {
      case ExerciseCategory.strength:
        return Colors.red;
      case ExerciseCategory.cardio:
        return Colors.orange;
      case ExerciseCategory.flexibility:
        return Colors.purple;
      case ExerciseCategory.yoga:
        return Colors.green;
      case ExerciseCategory.mixed:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
