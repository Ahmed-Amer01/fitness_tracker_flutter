import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/auth_provider.dart';
import '../models/exercise_model.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExercises();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final exerciseProvider =
        Provider.of<ExerciseProvider>(context, listen: false);

    if (authProvider.token != null) {
      await exerciseProvider.fetchExercises(token: authProvider.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Exercises',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showCreateExerciseDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Strength'),
            Tab(text: 'Cardio'),
            Tab(text: 'Flexibility'),
            Tab(text: 'Yoga'),
            Tab(text: 'Mixed'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<ExerciseProvider>(context, listen: false)
                              .searchExercises('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                Provider.of<ExerciseProvider>(context, listen: false)
                    .searchExercises(value);
              },
            ),
          ),
          // Exercises list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExercisesList(ExerciseCategory.mixed, showAll: true),
                _buildExercisesList(ExerciseCategory.strength),
                _buildExercisesList(ExerciseCategory.cardio),
                _buildExercisesList(ExerciseCategory.flexibility),
                _buildExercisesList(ExerciseCategory.yoga),
                _buildExercisesList(ExerciseCategory.mixed),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateExerciseDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExercisesList(ExerciseCategory category,
      {bool showAll = false}) {
    return Consumer2<ExerciseProvider, AuthProvider>(
      builder: (context, exerciseProvider, authProvider, child) {
        if (exerciseProvider.isLoading && exerciseProvider.exercises.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (exerciseProvider.error != null &&
            exerciseProvider.exercises.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading exercises',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  exerciseProvider.error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadExercises,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<Exercise> exercises = showAll
            ? exerciseProvider.filteredExercises
            : exerciseProvider.getExercisesByCategory(category);

        if (exercises.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getCategoryIcon(category),
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
                  'Create your first exercise to get started',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadExercises,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return _buildExerciseCard(
                  context, exercise, exerciseProvider, authProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise,
      ExerciseProvider exerciseProvider, AuthProvider authProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showExerciseDetails(context, exercise),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          _getCategoryColor(exercise.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(exercise.category),
                      color: _getCategoryColor(exercise.category),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          exercise.categoryDisplayName,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: _getCategoryColor(exercise.category),
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleExerciseAction(context, value,
                        exercise, exerciseProvider, authProvider),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (exercise.description != null &&
                  exercise.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  exercise.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      exercise.trackingModeDisplayName,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (exercise.hasWeights)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Text(
                        'Weights',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExerciseDetails(BuildContext context, Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getCategoryIcon(exercise.category),
              color: _getCategoryColor(exercise.category),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(exercise.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category: ${exercise.categoryDisplayName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tracking Mode: ${exercise.trackingModeDisplayName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Equipment: ${exercise.hasWeights ? "Weights Required" : "Bodyweight"}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (exercise.description != null &&
                exercise.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Description:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                exercise.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCreateExerciseDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    ExerciseCategory selectedCategory = ExerciseCategory.mixed;
    TrackingMode selectedTrackingMode = TrackingMode.reps;
    bool hasWeights = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Exercise'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Exercise Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ExerciseCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: ExerciseCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TrackingMode>(
                  value: selectedTrackingMode,
                  decoration: const InputDecoration(
                    labelText: 'Tracking Mode',
                    border: OutlineInputBorder(),
                  ),
                  items: TrackingMode.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTrackingMode = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Requires weights'),
                  value: hasWeights,
                  onChanged: (value) {
                    setState(() {
                      hasWeights = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _createExercise(
                  context,
                  nameController.text,
                  descriptionController.text,
                  selectedCategory,
                  selectedTrackingMode,
                  hasWeights),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createExercise(
      BuildContext context,
      String name,
      String description,
      ExerciseCategory category,
      TrackingMode trackingMode,
      bool hasWeights) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an exercise name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final exerciseProvider =
        Provider.of<ExerciseProvider>(context, listen: false);

    if (authProvider.token == null) return;

    final success = await exerciseProvider.createExercise(
      CreateExerciseDto(
        name: name.trim(),
        description: description.trim().isEmpty ? null : description.trim(),
        category: category,
        trackingMode: trackingMode,
        hasWeights: hasWeights,
      ),
      token: authProvider.token,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercise created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exerciseProvider.error ?? 'Failed to create exercise'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleExerciseAction(
      BuildContext context,
      String action,
      Exercise exercise,
      ExerciseProvider exerciseProvider,
      AuthProvider authProvider) {
    switch (action) {
      case 'view':
        _showExerciseDetails(context, exercise);
        break;
      case 'edit':
        // TODO: Implement edit functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit functionality coming soon!')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(
            context, exercise, exerciseProvider, authProvider);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Exercise exercise,
      ExerciseProvider exerciseProvider, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: Text('Are you sure you want to delete "${exercise.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              if (authProvider.token == null) return;

              final success = await exerciseProvider.deleteExercise(exercise.id,
                  token: authProvider.token);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exercise deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        exerciseProvider.error ?? 'Failed to delete exercise'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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

extension TrackingModeExtension on TrackingMode {
  String get displayName {
    switch (this) {
      case TrackingMode.reps:
        return 'Reps';
      case TrackingMode.time:
        return 'Time';
      case TrackingMode.both:
        return 'Both';
    }
  }
}
