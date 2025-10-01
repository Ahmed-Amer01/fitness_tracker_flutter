import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../providers/auth_provider.dart';
import '../models/nutrition_model.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNutritions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNutritions() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final nutritionProvider =
        Provider.of<NutritionProvider>(context, listen: false);

    if (authProvider.token != null) {
      await nutritionProvider.fetchNutritions(token: authProvider.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nutrition',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showCreateNutritionDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: '🍎 Fruit'),
            Tab(text: '🥬 Vegetable'),
            Tab(text: '🥩 Meat'),
            Tab(text: '🥛 Dairy'),
            Tab(text: '🌾 Grain'),
            Tab(text: '🥤 Beverage'),
            Tab(text: '🍽️ Other'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search nutrition...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                Provider.of<NutritionProvider>(context,
                                        listen: false)
                                    .searchNutritions('');
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      Provider.of<NutritionProvider>(context, listen: false)
                          .searchNutritions(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showFilterDialog(context),
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filter by calories',
                ),
              ],
            ),
          ),
          // Nutrition list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNutritionsList(NutritionCategory.other, showAll: true),
                _buildNutritionsList(NutritionCategory.fruit),
                _buildNutritionsList(NutritionCategory.vegetable),
                _buildNutritionsList(NutritionCategory.meat),
                _buildNutritionsList(NutritionCategory.dairy),
                _buildNutritionsList(NutritionCategory.grain),
                _buildNutritionsList(NutritionCategory.beverage),
                _buildNutritionsList(NutritionCategory.other),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateNutritionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNutritionsList(NutritionCategory category,
      {bool showAll = false}) {
    return Consumer2<NutritionProvider, AuthProvider>(
      builder: (context, nutritionProvider, authProvider, child) {
        if (nutritionProvider.isLoading &&
            nutritionProvider.nutritions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (nutritionProvider.error != null &&
            nutritionProvider.nutritions.isEmpty) {
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
                  'Error loading nutrition data',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  nutritionProvider.error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadNutritions,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<Nutrition> nutritions = showAll
            ? nutritionProvider.filteredNutritions
            : nutritionProvider.getNutritionsByCategory(category);

        if (nutritions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  showAll ? '🍽️' : _getCategoryEmoji(category),
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(height: 16),
                Text(
                  'No nutrition items found',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first nutrition item to get started',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadNutritions,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: nutritions.length,
            itemBuilder: (context, index) {
              final nutrition = nutritions[index];
              return _buildNutritionCard(
                  context, nutrition, nutritionProvider, authProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildNutritionCard(BuildContext context, Nutrition nutrition,
      NutritionProvider nutritionProvider, AuthProvider authProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showNutritionDetails(context, nutrition),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    nutrition.categoryEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nutrition.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          nutrition.categoryDisplayName,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: _getCategoryColor(nutrition.category),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleNutritionAction(context,
                        value, nutrition, nutritionProvider, authProvider),
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
              const SizedBox(height: 12),
              // Nutrition info
              Row(
                children: [
                  if (nutrition.caloriesPer100g != null)
                    _buildNutritionChip(
                      context,
                      'Calories',
                      '${nutrition.caloriesPer100g!.toStringAsFixed(0)} kcal',
                      Colors.orange,
                    ),
                  if (nutrition.proteinPer100g != null) ...[
                    const SizedBox(width: 8),
                    _buildNutritionChip(
                      context,
                      'Protein',
                      '${nutrition.proteinPer100g!.toStringAsFixed(1)}g',
                      Colors.red,
                    ),
                  ],
                  if (nutrition.carbsPer100g != null) ...[
                    const SizedBox(width: 8),
                    _buildNutritionChip(
                      context,
                      'Carbs',
                      '${nutrition.carbsPer100g!.toStringAsFixed(1)}g',
                      Colors.blue,
                    ),
                  ],
                  if (nutrition.fatsPer100g != null) ...[
                    const SizedBox(width: 8),
                    _buildNutritionChip(
                      context,
                      'Fats',
                      '${nutrition.fatsPer100g!.toStringAsFixed(1)}g',
                      Colors.purple,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionChip(
      BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _showNutritionDetails(BuildContext context, Nutrition nutrition) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(nutrition.categoryEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(child: Text(nutrition.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category: ${nutrition.categoryDisplayName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Nutrition per 100g:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (nutrition.caloriesPer100g != null)
              _buildNutritionDetailRow(context, 'Calories',
                  '${nutrition.caloriesPer100g!.toStringAsFixed(1)} kcal'),
            if (nutrition.proteinPer100g != null)
              _buildNutritionDetailRow(context, 'Protein',
                  '${nutrition.proteinPer100g!.toStringAsFixed(1)}g'),
            if (nutrition.carbsPer100g != null)
              _buildNutritionDetailRow(context, 'Carbohydrates',
                  '${nutrition.carbsPer100g!.toStringAsFixed(1)}g'),
            if (nutrition.fatsPer100g != null)
              _buildNutritionDetailRow(context, 'Fats',
                  '${nutrition.fatsPer100g!.toStringAsFixed(1)}g'),
            if (nutrition.fiberPer100g != null)
              _buildNutritionDetailRow(context, 'Fiber',
                  '${nutrition.fiberPer100g!.toStringAsFixed(1)}g'),
            if (nutrition.sugarPer100g != null)
              _buildNutritionDetailRow(context, 'Sugar',
                  '${nutrition.sugarPer100g!.toStringAsFixed(1)}g'),
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

  Widget _buildNutritionDetailRow(
      BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final nutritionProvider =
        Provider.of<NutritionProvider>(context, listen: false);
    final minCaloriesController = TextEditingController();
    final maxCaloriesController = TextEditingController();

    // Set current filter values
    if (nutritionProvider.minCalories != null) {
      minCaloriesController.text = nutritionProvider.minCalories.toString();
    }
    if (nutritionProvider.maxCalories != null) {
      maxCaloriesController.text = nutritionProvider.maxCalories.toString();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Calories'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minCaloriesController,
              decoration: const InputDecoration(
                labelText: 'Minimum Calories',
                border: OutlineInputBorder(),
                suffixText: 'kcal',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: maxCaloriesController,
              decoration: const InputDecoration(
                labelText: 'Maximum Calories',
                border: OutlineInputBorder(),
                suffixText: 'kcal',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              nutritionProvider.clearFilters();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              final minCalories = int.tryParse(minCaloriesController.text);
              final maxCalories = int.tryParse(maxCaloriesController.text);
              nutritionProvider.filterByCalories(
                  min: minCalories, max: maxCalories);
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showCreateNutritionDialog(BuildContext context) {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatsController = TextEditingController();
    final fiberController = TextEditingController();
    final sugarController = TextEditingController();
    NutritionCategory selectedCategory = NutritionCategory.other;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Nutrition Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Food Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<NutritionCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: NutritionCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Text(_getCategoryEmoji(category)),
                          const SizedBox(width: 8),
                          Text(_getCategoryDisplayName(category)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Nutrition per 100g:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: caloriesController,
                  decoration: const InputDecoration(
                    labelText: 'Calories',
                    border: OutlineInputBorder(),
                    suffixText: 'kcal',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: proteinController,
                  decoration: const InputDecoration(
                    labelText: 'Protein',
                    border: OutlineInputBorder(),
                    suffixText: 'g',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: carbsController,
                  decoration: const InputDecoration(
                    labelText: 'Carbohydrates',
                    border: OutlineInputBorder(),
                    suffixText: 'g',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: fatsController,
                  decoration: const InputDecoration(
                    labelText: 'Fats',
                    border: OutlineInputBorder(),
                    suffixText: 'g',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: fiberController,
                  decoration: const InputDecoration(
                    labelText: 'Fiber (Optional)',
                    border: OutlineInputBorder(),
                    suffixText: 'g',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: sugarController,
                  decoration: const InputDecoration(
                    labelText: 'Sugar (Optional)',
                    border: OutlineInputBorder(),
                    suffixText: 'g',
                  ),
                  keyboardType: TextInputType.number,
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
              onPressed: () => _createNutrition(
                context,
                nameController.text,
                selectedCategory,
                caloriesController.text,
                proteinController.text,
                carbsController.text,
                fatsController.text,
                fiberController.text,
                sugarController.text,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createNutrition(
      BuildContext context,
      String name,
      NutritionCategory category,
      String calories,
      String protein,
      String carbs,
      String fats,
      String fiber,
      String sugar) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a food name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final nutritionProvider =
        Provider.of<NutritionProvider>(context, listen: false);

    if (authProvider.token == null) return;

    final success = await nutritionProvider.createNutrition(
      CreateNutritionDto(
        name: name.trim(),
        category: category,
        caloriesPer100g: double.tryParse(calories),
        proteinPer100g: double.tryParse(protein),
        carbsPer100g: double.tryParse(carbs),
        fatsPer100g: double.tryParse(fats),
        fiberPer100g: double.tryParse(fiber),
        sugarPer100g: double.tryParse(sugar),
      ),
      token: authProvider.token,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nutrition item added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(nutritionProvider.error ?? 'Failed to add nutrition item'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleNutritionAction(
      BuildContext context,
      String action,
      Nutrition nutrition,
      NutritionProvider nutritionProvider,
      AuthProvider authProvider) {
    switch (action) {
      case 'view':
        _showNutritionDetails(context, nutrition);
        break;
      case 'edit':
        _showEditNutritionDialog(
            context, nutrition, nutritionProvider, authProvider);
        break;
      case 'delete':
        _showDeleteConfirmation(
            context, nutrition, nutritionProvider, authProvider);
        break;
    }
  }

  void _showEditNutritionDialog(BuildContext context, Nutrition nutrition,
      NutritionProvider nutritionProvider, AuthProvider authProvider) {
    final nameController = TextEditingController(text: nutrition.name);
    final caloriesController = TextEditingController(
        text: nutrition.caloriesPer100g?.toString() ?? '');
    final proteinController =
        TextEditingController(text: nutrition.proteinPer100g?.toString() ?? '');
    final carbsController =
        TextEditingController(text: nutrition.carbsPer100g?.toString() ?? '');
    final fatsController =
        TextEditingController(text: nutrition.fatsPer100g?.toString() ?? '');
    final fiberController =
        TextEditingController(text: nutrition.fiberPer100g?.toString() ?? '');
    final sugarController =
        TextEditingController(text: nutrition.sugarPer100g?.toString() ?? '');
    NutritionCategory selectedCategory = nutrition.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Nutrition Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Food Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<NutritionCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: NutritionCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Text(_getCategoryEmoji(category)),
                          const SizedBox(width: 8),
                          Text(_getCategoryDisplayName(category)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Nutrition per 100g:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: caloriesController,
                  decoration: const InputDecoration(
                    labelText: 'Calories',
                    border: OutlineInputBorder(),
                    suffixText: 'kcal',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: proteinController,
                  decoration: const InputDecoration(
                    labelText: 'Protein',
                    border: OutlineInputBorder(),
                    suffixText: 'g',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: carbsController,
                  decoration: const InputDecoration(
                    labelText: 'Carbohydrates',
                    border: OutlineInputBorder(),
                    suffixText: 'g',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: fatsController,
                  decoration: const InputDecoration(
                    labelText: 'Fats',
                    border: OutlineInputBorder(),
                    suffixText: 'g',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: fiberController,
                  decoration: const InputDecoration(
                    labelText: 'Fiber (Optional)',
                    border: OutlineInputBorder(),
                    suffixText: 'g',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: sugarController,
                  decoration: const InputDecoration(
                    labelText: 'Sugar (Optional)',
                    border: OutlineInputBorder(),
                    suffixText: 'g',
                  ),
                  keyboardType: TextInputType.number,
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
              onPressed: () => _updateNutrition(
                context,
                nutrition,
                nameController.text,
                selectedCategory,
                caloriesController.text,
                proteinController.text,
                carbsController.text,
                fatsController.text,
                fiberController.text,
                sugarController.text,
                nutritionProvider,
                authProvider,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Nutrition nutrition,
      NutritionProvider nutritionProvider, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Nutrition Item'),
        content: Text('Are you sure you want to delete "${nutrition.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              if (authProvider.token == null) return;

              final success = await nutritionProvider
                  .deleteNutrition(nutrition.id, token: authProvider.token);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nutrition item deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(nutritionProvider.error ??
                        'Failed to delete nutrition item'),
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

  String _getCategoryEmoji(NutritionCategory category) {
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

  String _getCategoryDisplayName(NutritionCategory category) {
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

  Color _getCategoryColor(NutritionCategory category) {
    switch (category) {
      case NutritionCategory.fruit:
        return Colors.red;
      case NutritionCategory.vegetable:
        return Colors.green;
      case NutritionCategory.meat:
        return Colors.brown;
      case NutritionCategory.dairy:
        return Colors.blue;
      case NutritionCategory.grain:
        return Colors.orange;
      case NutritionCategory.beverage:
        return Colors.cyan;
      case NutritionCategory.other:
        return Colors.grey;
    }
  }

  Future<void> _updateNutrition(
      BuildContext context,
      Nutrition nutrition,
      String name,
      NutritionCategory category,
      String calories,
      String protein,
      String carbs,
      String fats,
      String fiber,
      String sugar,
      NutritionProvider nutritionProvider,
      AuthProvider authProvider) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a food name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop();

    if (authProvider.token == null) return;

    final success = await nutritionProvider.updateNutrition(
      nutrition.id,
      UpdateNutritionDto(
        name: name.trim(),
        category: category,
        caloriesPer100g: double.tryParse(calories),
        proteinPer100g: double.tryParse(protein),
        carbsPer100g: double.tryParse(carbs),
        fatsPer100g: double.tryParse(fats),
        fiberPer100g: fiber.isNotEmpty ? double.tryParse(fiber) : null,
        sugarPer100g: sugar.isNotEmpty ? double.tryParse(sugar) : null,
      ),
      token: authProvider.token,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nutrition item updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              nutritionProvider.error ?? 'Failed to update nutrition item'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
