import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/loading_widget.dart';
import '../../providers/nutrition_providers.dart';

class MessMenuScreen extends ConsumerWidget {
  const MessMenuScreen({super.key});

  static const _categories = ['BREAKFAST', 'LUNCH', 'SNACK', 'DINNER'];
  static const _labels = ['Breakfast', 'Lunch', 'Snack', 'Dinner'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Food Browser'),
          bottom: TabBar(
            indicatorColor: const Color(0xFF00C9A7),
            labelColor: const Color(0xFF00C9A7),
            unselectedLabelColor: Colors.white54,
            tabs: _labels.map((l) => Tab(text: l)).toList(),
          ),
        ),
        body: TabBarView(
          children: _categories
              .map((cat) => _CategoryFoodList(category: cat))
              .toList(),
        ),
      ),
    );
  }
}

class _CategoryFoodList extends ConsumerWidget {
  final String category;
  const _CategoryFoodList({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodsAsync = ref.watch(foodByCategoryProvider(category));

    return foodsAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => Center(
          child: Text('Error loading foods',
              style: const TextStyle(color: Colors.white54))),
      data: (foods) {
        if (foods.isEmpty) {
          return const Center(
              child: Text('No foods available',
                  style: TextStyle(color: Colors.white54)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: foods.length,
          itemBuilder: (ctx, i) {
            final food = foods[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(food.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                          if (food.servingSize != null)
                            Text(food.servingSize!,
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${food.calories.toInt()} kcal',
                            style: const TextStyle(
                                color: Color(0xFFFF8A65), fontSize: 13)),
                        Text(
                            'P:${food.proteinG.toInt()} C:${food.carbsG.toInt()} F:${food.fatG.toInt()}',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
