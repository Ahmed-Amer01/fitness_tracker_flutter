import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../models/goal_model.dart';
import '../providers/goal_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  bool showForm = false;
  Goal? editingGoal;
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _deadlineController = TextEditingController();
  GoalStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = '';
    _targetWeightController.text = '';
    _currentWeightController.text = '';
    _deadlineController.text = DateTime.now().toIso8601String().split('T')[0];
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _targetWeightController.dispose();
    _currentWeightController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  void _initControllers(Goal? goal) {
    if (goal == null) {
      _descriptionController.text = '';
      _targetWeightController.text = '';
      _currentWeightController.text = '';
      _deadlineController.text = DateTime.now().toIso8601String().split('T')[0];
      _selectedStatus = GoalStatus.notStarted;
    } else {
      _descriptionController.text = goal.description;
      _targetWeightController.text = goal.targetWeight.toString();
      _currentWeightController.text = goal.currentWeight.toString();
      _deadlineController.text = goal.deadline;
      _selectedStatus = goal.status;
    }
  }

  Goal _readGoalFromControllers({String? id}) {
    return Goal(
      id: id,
      description: _descriptionController.text.trim(),
      targetWeight: double.tryParse(_targetWeightController.text) ?? 0.0,
      currentWeight: double.tryParse(_currentWeightController.text) ?? 0.0,
      deadline: _deadlineController.text,
      status: _selectedStatus ?? GoalStatus.notStarted,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Color _getStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.inProgress:
        return Colors.blue[500]!;
      case GoalStatus.achieved:
        return Colors.green[500]!;
      case GoalStatus.abandoned:
        return Colors.red[500]!;
      default:
        return Colors.grey[500]!;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _deadlineController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Goals',
            isDashboard: false,
            showActions: true,
          ),
          body: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // static Header
                      Text(
                        'Track your Goals Every Day',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Motivational Tip
                      _buildMotivationalTip(),
                      const SizedBox(height: 24),

                      // Status Counters
                      _buildStatusCounters(provider),
                      const SizedBox(height: 24),

                      // Add Goal Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Goals',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                showForm = !showForm;
                                editingGoal = null;
                                _initControllers(null);
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: Text(showForm ? 'Close Form' : 'Add Goal +'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue900,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (showForm)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Add Goal',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _descriptionController,
                                    decoration: const InputDecoration(
                                      labelText: 'Description',
                                      prefixIcon: Icon(Icons.description),
                                      border: OutlineInputBorder(),
                                    ),
                                    maxLines: 3,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Description is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _targetWeightController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*$')),
                                          ],
                                          decoration: const InputDecoration(
                                            labelText: 'Target Weight (kg)',
                                            prefixIcon:
                                                Icon(Icons.fitness_center),
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Target weight is required';
                                            }
                                            if (double.tryParse(value) == null) {
                                              return 'Enter a valid number';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _currentWeightController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*$')),
                                          ],
                                          decoration: const InputDecoration(
                                            labelText: 'Current Weight (kg)',
                                            prefixIcon: Icon(Icons.balance),
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Current weight is required';
                                            }
                                            if (double.tryParse(value) == null) {
                                              return 'Enter a valid number';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _deadlineController,
                                    decoration: const InputDecoration(
                                      labelText: 'Deadline',
                                      prefixIcon: Icon(Icons.date_range),
                                      border: OutlineInputBorder(),
                                    ),
                                    readOnly: true,
                                    onTap: () => _selectDate(context),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Deadline is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<GoalStatus>(
                                    initialValue:
                                        editingGoal?.status ?? GoalStatus.notStarted,
                                    decoration: const InputDecoration(
                                      labelText: 'Status',
                                      prefixIcon: Icon(Icons.flag),
                                      border: OutlineInputBorder(),
                                    ),
                                    items: GoalStatus.values.map((status) {
                                      return DropdownMenuItem(
                                        value: status,
                                        child: Text(status.statusDisplay),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedStatus = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!.validate()) {
                                            final goal = _readGoalFromControllers(
                                              id: editingGoal?.id,
                                            );
                                            await provider.saveGoal(goal);
                                            setState(() {
                                              showForm = false;
                                              editingGoal = null;
                                            });
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.blue900,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16, horizontal: 32),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          editingGoal != null
                                              ? 'Update Goal'
                                              : 'Save Goal',
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            showForm = false;
                                            editingGoal = null;
                                          });
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16, horizontal: 32),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Goals',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        'Description',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Target',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Current',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Deadline',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Status',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Actions',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: provider.goals.isEmpty
                                      ? [
                                          const DataRow(
                                            cells: [
                                              DataCell(
                                                Text('No goals found'),
                                              ),
                                              DataCell(SizedBox()),
                                              DataCell(SizedBox()),
                                              DataCell(SizedBox()),
                                              DataCell(SizedBox()),
                                              DataCell(SizedBox()),
                                            ],
                                          ),
                                        ]
                                      : provider.goals.map((goal) {
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  goal.description,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '${goal.targetWeight.toStringAsFixed(1)} kg',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '${goal.currentWeight.toStringAsFixed(1)} kg',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  goal.deadline,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  goal.status.statusDisplay,
                                                  style: TextStyle(
                                                    color:
                                                        _getStatusColor(goal.status),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          editingGoal = goal;
                                                          showForm = true;
                                                          _initControllers(goal);
                                                        });
                                                        Scrollable.ensureVisible(
                                                          context,
                                                          duration: const Duration(
                                                              milliseconds: 300),
                                                          curve: Curves.easeInOut,
                                                        );
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () async {
                                                        final confirmed =
                                                            await showDialog<bool>(
                                                          context: context,
                                                          builder:
                                                              (BuildContext context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                'Delete Goal',
                                                                style: TextStyle(
                                                                  fontSize: 24,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                  color: AppColors
                                                                      .primaryDark,
                                                                ),
                                                              ),
                                                              content: const Text(
                                                                'Are you sure you want to delete this goal? This action cannot be undone.',
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(false),
                                                                  child: const Text(
                                                                    'Cancel',
                                                                    style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(true),
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    foregroundColor:
                                                                        Colors.red,
                                                                  ),
                                                                  child: const Text(
                                                                    'Delete',
                                                                    style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Colors.red,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );

                                                        if (confirmed == true) {
                                                          await provider
                                                              .deleteGoal(goal.id!);
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildMotivationalTip() {
    const tips = [
      'Consistency beats intensity!',
      'Small steps lead to big results!',
      'Your health is your wealth!',
      'Celebrate every victory, no matter how small!',
    ];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(DateTime.now().second),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.blue900.withAlpha(50)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tips[DateTime.now().second % tips.length],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCounters(GoalProvider provider) {
    final statusCounts = provider.getStatusCounts();
    const statuses = [
      {
        'title': 'Not Started',
        'key': 'NOT_STARTED',
        'color': Colors.grey,
      },
      {
        'title': 'In Progress',
        'key': 'IN_PROGRESS',
        'color': Colors.blue,
      },
      {
        'title': 'Achieved',
        'key': 'ACHIEVED',
        'color': Colors.green,
      },
      {
        'title': 'Abandoned',
        'key': 'ABANDONED',
        'color': Colors.red,
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: statuses.map((status) {
        final count = statusCounts[status['key'] as String] ?? 0;
        final color = (status['color'] as MaterialColor)[500]!;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            color: color.withAlpha(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                status['title'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}