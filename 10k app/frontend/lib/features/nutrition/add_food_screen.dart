import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/nutrition_providers.dart';
import '../../data/models/food_item.dart';
import 'custom_food_form_screen.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  final DateTime logDate;

  const AddFoodScreen({super.key, required this.logDate});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  final _searchController = TextEditingController();
  final _servingsController = TextEditingController(text: '1');
  String _selectedMeal = 'LUNCH';
  String _query = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = _query.length >= 2
        ? ref.watch(foodSearchProvider(_query))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CustomFoodFormScreen())),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Custom'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Meal selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'BREAKFAST', label: Text('Bkf')),
                ButtonSegment(value: 'LUNCH', label: Text('Lunch')),
                ButtonSegment(value: 'SNACK', label: Text('Snack')),
                ButtonSegment(value: 'DINNER', label: Text('Dinner')),
              ],
              selected: {_selectedMeal},
              onSelectionChanged: (s) => setState(() => _selectedMeal = s.first),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.selected) ? Colors.white : Colors.white54),
                backgroundColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? const Color(0xFF00C9A7).withOpacity(0.3)
                        : Colors.transparent),
              ),
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search food (e.g. paneer, dal)...',
                prefixIcon: Icon(Icons.search, color: Colors.white38),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          // Servings row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                const Text('Servings:', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _servingsController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          // Results
          Expanded(
            child: searchResults == null
                ? _buildCategoryBrowser()
                : searchResults.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Search error',
                        style: TextStyle(color: Colors.white54))),
                    data: (foods) {
                      if (foods.isEmpty) {
                        return const Center(child: Text('No results found',
                            style: TextStyle(color: Colors.white54)));
                      }
                      return ListView.builder(
                        itemCount: foods.length,
                        itemBuilder: (ctx, i) => _foodTile(foods[i]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static const _categoryChips = [
    (null, 'All'),
    ('BREAKFAST', 'Mess Breakfast'),
    ('LUNCH', 'Mess Lunch'),
    ('SNACK', 'Mess Snack'),
    ('DINNER', 'Mess Dinner'),
    ('GYM', 'Gym Foods'),
  ];

  Widget _buildCategoryBrowser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category filter chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: _categoryChips.map((chip) {
              final selected = _selectedCategory == chip.$1;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(chip.$2,
                      style: TextStyle(
                          fontSize: 12,
                          color: selected ? Colors.white : Colors.white54)),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = chip.$1),
                  selectedColor: const Color(0xFF00C9A7).withOpacity(0.3),
                  backgroundColor: Colors.transparent,
                  side: BorderSide(
                      color: selected
                          ? const Color(0xFF00C9A7)
                          : Colors.white24),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: _selectedCategory == null
              ? const Center(
                  child: Text(
                      'Type 2+ chars to search, or pick a category',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                      textAlign: TextAlign.center))
              : ref.watch(foodByCategoryProvider(_selectedCategory!)).when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => const Center(
                      child: Text('Error loading foods',
                          style: TextStyle(color: Colors.white54))),
                  data: (foods) {
                    if (foods.isEmpty) {
                      return const Center(
                          child: Text('No foods in this category',
                              style: TextStyle(color: Colors.white54)));
                    }
                    return ListView.builder(
                      itemCount: foods.length,
                      itemBuilder: (ctx, i) => _foodTile(foods[i]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _foodTile(FoodItem food) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(food.name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        subtitle: Text(
            '${food.calories.toInt()} kcal  |  P: ${food.proteinG.toInt()}g  C: ${food.carbsG.toInt()}g  F: ${food.fatG.toInt()}g',
            style: const TextStyle(color: Colors.white38, fontSize: 11)),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Color(0xFF00C9A7)),
          onPressed: () => _logFood(food),
        ),
      ),
    );
  }

  Future<void> _logFood(FoodItem food) async {
    final servings = double.tryParse(_servingsController.text) ?? 1.0;
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.logDate);
    try {
      await ref.read(nutritionRepositoryProvider).logFood(
        logDate: dateStr,
        mealType: _selectedMeal,
        foodItemId: food.id,
        servings: servings,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${food.name} ×${servings.toStringAsFixed(1)} logged!'),
            backgroundColor: const Color(0xFF00C9A7),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
