import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/auth_provider.dart';
import '../models/exercise_model.dart';

class ExerciseSelector extends StatefulWidget {
  final List<String> selectedExercises;
  final Function(List<String>) onSelectionChanged;
  final String? hintText;

  const ExerciseSelector({
    super.key,
    required this.selectedExercises,
    required this.onSelectionChanged,
    this.hintText,
  });

  @override
  State<ExerciseSelector> createState() => _ExerciseSelectorState();
}

class _ExerciseSelectorState extends State<ExerciseSelector> {
  final TextEditingController _searchController = TextEditingController();
  ExerciseCategory? _selectedCategory;
  List<Exercise> _filteredExercises = [];
  List<Exercise> _allExercises = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    final exerciseProvider =
        Provider.of<ExerciseProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.token != null) {
      await exerciseProvider.fetchExercises(token: authProvider.token);
      setState(() {
        _allExercises = exerciseProvider.exercises;
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredExercises = _allExercises.where((exercise) {
        // Search filter
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          if (!exercise.name.toLowerCase().contains(query) &&
              (exercise.description?.toLowerCase().contains(query) != true)) {
            return false;
          }
        }

        // Category filter
        if (_selectedCategory != null &&
            exercise.category != _selectedCategory!) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Search exercises...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _applyFilters();
                    },
                    icon: const Icon(Icons.clear),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) => _applyFilters(),
        ),
        const SizedBox(height: 16),

        // Category filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedCategory == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? null : _selectedCategory;
                    _applyFilters();
                  });
                },
              ),
              const SizedBox(width: 8),
              ...ExerciseCategory.values.map((category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.displayName),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                          _applyFilters();
                        });
                      },
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Selected exercises count
        if (widget.selectedExercises.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${widget.selectedExercises.length} exercise${widget.selectedExercises.length == 1 ? '' : 's'} selected',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Exercises list
        Expanded(
          child: _filteredExercises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No exercises found',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your search or category filter',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _filteredExercises[index];
                    final isSelected =
                        widget.selectedExercises.contains(exercise.name);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isSelected
                            ? BorderSide(
                                color: Theme.of(context).primaryColor, width: 2)
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        onTap: () => _toggleExerciseSelection(exercise.name),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(exercise.category)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getCategoryIcon(exercise.category),
                                  color: _getCategoryColor(exercise.category),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      exercise.categoryDisplayName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: _getCategoryColor(
                                                exercise.category),
                                          ),
                                    ),
                                    if (exercise.description != null &&
                                        exercise.description!.isNotEmpty)
                                      Text(
                                        exercise.description!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _toggleExerciseSelection(String exerciseName) {
    setState(() {
      if (widget.selectedExercises.contains(exerciseName)) {
        widget.selectedExercises.remove(exerciseName);
      } else {
        widget.selectedExercises.add(exerciseName);
      }
    });
    widget.onSelectionChanged(widget.selectedExercises);
  }

  IconData _getCategoryIcon(ExerciseCategory category) {
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
    }
  }

  Color _getCategoryColor(ExerciseCategory category) {
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
    }
  }
}

extension ExerciseCategoryExtension on ExerciseCategory {
  String get displayName {
    switch (this) {
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
}
