import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../providers/auth_provider.dart';
import '../models/workout_model.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkouts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkouts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final workoutProvider =
        Provider.of<WorkoutProvider>(context, listen: false);

    if (authProvider.token != null) {
      await workoutProvider.fetchWorkouts(token: authProvider.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workouts',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(context),
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: () => _showCreateWorkoutDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer2<WorkoutProvider, AuthProvider>(
        builder: (context, workoutProvider, authProvider, child) {
          if (workoutProvider.isLoading && workoutProvider.workouts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (workoutProvider.error != null &&
              workoutProvider.workouts.isEmpty) {
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
                    'Error loading workouts',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    workoutProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadWorkouts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search workouts...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              workoutProvider.searchWorkouts('');
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    workoutProvider.searchWorkouts(value);
                  },
                ),
              ),
              // Workouts list
              Expanded(
                child: workoutProvider.filteredWorkouts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No workouts found',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first workout to get started',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadWorkouts,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: workoutProvider.filteredWorkouts.length,
                          itemBuilder: (context, index) {
                            final workout =
                                workoutProvider.filteredWorkouts[index];
                            return _buildWorkoutCard(context, workout,
                                workoutProvider, authProvider);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateWorkoutDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout workout,
      WorkoutProvider workoutProvider, AuthProvider authProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showWorkoutDetails(context, workout),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workout.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  if (workout.isShared)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Text(
                        'Shared',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              if (workout.description != null &&
                  workout.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  workout.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${workout.workoutExercises.length} exercises',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleWorkoutAction(
                        context, value, workout, workoutProvider, authProvider),
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
            ],
          ),
        ),
      ),
    );
  }

  void _showWorkoutDetails(BuildContext context, Workout workout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(workout.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (workout.description != null &&
                workout.description!.isNotEmpty) ...[
              Text(
                workout.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Exercises (${workout.workoutExercises.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (workout.workoutExercises.isEmpty)
              const Text('No exercises added yet')
            else
              ...workout.workoutExercises.map((exercise) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.fitness_center, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(exercise.exerciseName)),
                        if (exercise.sets != null ||
                            exercise.reps != null ||
                            exercise.duration != null)
                          Text(
                            '${exercise.sets ?? ''} ${exercise.reps ?? ''} ${exercise.duration ?? ''}'
                                .trim(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  )),
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

  void _showFilterDialog(BuildContext context) {
    final workoutProvider =
        Provider.of<WorkoutProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Workouts'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<bool?>(
                  title: const Text('All'),
                  value: null,
                  groupValue: workoutProvider.sharedFilter,
                  onChanged: (value) {
                    setState(() {
                      workoutProvider.filterByShared(value);
                    });
                  },
                ),
                RadioListTile<bool?>(
                  title: const Text('My Workouts'),
                  value: false,
                  groupValue: workoutProvider.sharedFilter,
                  onChanged: (value) {
                    setState(() {
                      workoutProvider.filterByShared(value);
                    });
                  },
                ),
                RadioListTile<bool?>(
                  title: const Text('Shared Workouts'),
                  value: true,
                  groupValue: workoutProvider.sharedFilter,
                  onChanged: (value) {
                    setState(() {
                      workoutProvider.filterByShared(value);
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              workoutProvider.clearFilters();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showCreateWorkoutDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isShared = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Workout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name',
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
              CheckboxListTile(
                title: const Text('Share with community'),
                value: isShared,
                onChanged: (value) {
                  setState(() {
                    isShared = value ?? false;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _createWorkout(context, nameController.text,
                  descriptionController.text, isShared),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createWorkout(BuildContext context, String name,
      String description, bool isShared) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a workout name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final workoutProvider =
        Provider.of<WorkoutProvider>(context, listen: false);

    if (authProvider.token == null) return;

    final success = await workoutProvider.createWorkout(
      CreateWorkoutDto(
        name: name.trim(),
        description: description.trim().isEmpty ? null : description.trim(),
        isShared: isShared,
      ),
      token: authProvider.token,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(workoutProvider.error ?? 'Failed to create workout'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleWorkoutAction(
      BuildContext context,
      String action,
      Workout workout,
      WorkoutProvider workoutProvider,
      AuthProvider authProvider) {
    switch (action) {
      case 'view':
        _showWorkoutDetails(context, workout);
        break;
      case 'edit':
        // TODO: Implement edit functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit functionality coming soon!')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(
            context, workout, workoutProvider, authProvider);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Workout workout,
      WorkoutProvider workoutProvider, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text('Are you sure you want to delete "${workout.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              if (authProvider.token == null) return;

              final success = await workoutProvider.deleteWorkout(workout.id,
                  token: authProvider.token);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Workout deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        workoutProvider.error ?? 'Failed to delete workout'),
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
}
