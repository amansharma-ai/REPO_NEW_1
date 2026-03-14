import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/nutrition_ring.dart';
import '../../core/widgets/macro_progress_bar.dart';
import '../../core/widgets/loading_widget.dart';
import '../../providers/nutrition_providers.dart';
import '../../data/models/weekly_nutrition.dart';
import 'mess_menu_screen.dart';
import 'add_food_screen.dart';
import 'nutrition_goals_screen.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedNutritionDateProvider);
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final isToday =
        DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateStr;
    final summaryAsync = ref.watch(dailySummaryProvider(dateStr));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => ref
                  .read(selectedNutritionDateProvider.notifier)
                  .state = selectedDate.subtract(const Duration(days: 1)),
            ),
            GestureDetector(
              onTap: () => ref
                  .read(selectedNutritionDateProvider.notifier)
                  .state = DateTime.now(),
              child: Text(
                isToday ? 'Today' : DateFormat('MMM d').format(selectedDate),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right,
                  color: isToday ? Colors.white24 : null),
              onPressed: isToday
                  ? null
                  : () => ref
                      .read(selectedNutritionDateProvider.notifier)
                      .state = selectedDate.add(const Duration(days: 1)),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NutritionGoalsScreen())),
          ),
          TextButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MessMenuScreen())),
            icon: const Icon(Icons.menu_book, size: 18),
            label: const Text('Menu'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddFoodScreen(logDate: selectedDate)));
          ref.invalidate(dailySummaryProvider(dateStr));
        },
        backgroundColor: const Color(0xFF00C9A7),
        icon: const Icon(Icons.add),
        label: const Text('Log Food'),
      ),
      body: summaryAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => const Center(
            child: Text('Could not load summary',
                style: TextStyle(color: Colors.white54))),
        data: (summary) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      NutritionRing(
                        consumed: summary.totalCalories,
                        goal: summary.goalCalories,
                        color: const Color(0xFFFF8A65),
                        size: 120,
                        centerLabel: 'kcal',
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            MacroProgressBar(
                                label: 'Protein',
                                current: summary.totalProtein,
                                goal: summary.goalProtein,
                                color: const Color(0xFF42A5F5)),
                            const SizedBox(height: 12),
                            MacroProgressBar(
                                label: 'Carbs',
                                current: summary.totalCarbs,
                                goal: summary.goalCarbs,
                                color: const Color(0xFF66BB6A)),
                            const SizedBox(height: 12),
                            MacroProgressBar(
                                label: 'Fat',
                                current: summary.totalFat,
                                goal: summary.goalFat,
                                color: const Color(0xFFEC407A)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Meals breakdown
              ...summary.meals.map((meal) => _buildMealCard(
                  context, ref, meal.mealType, meal.calories, meal.items,
                  dateStr)),

              const SizedBox(height: 20),

              // Weekly calorie chart
              const _WeeklyCalorieChart(),

              const SizedBox(height: 20),

              // 7-Day Macro Trend Chart
              const _MacroTrendChart(),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealCard(BuildContext ctx, WidgetRef ref, String mealType,
      double calories, List items, String dateStr) {
    final icons = {
      'BREAKFAST': Icons.wb_sunny_rounded,
      'LUNCH': Icons.restaurant_rounded,
      'SNACK': Icons.cookie_rounded,
      'DINNER': Icons.nightlight_round,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(icons[mealType] ?? Icons.restaurant,
            color: const Color(0xFF00C9A7)),
        title: Text(mealType[0] + mealType.substring(1).toLowerCase(),
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        subtitle: Text('${calories.toInt()} kcal',
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        children: [
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No food logged',
                  style: TextStyle(color: Colors.white38)),
            )
          else
            ...items.map((item) => Dismissible(
                  key: Key('log-${item.logId}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red.withOpacity(0.2),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  onDismissed: (_) async {
                    await ref
                        .read(nutritionRepositoryProvider)
                        .deleteLog(item.logId);
                    ref.invalidate(dailySummaryProvider(dateStr));
                  },
                  child: ListTile(
                    dense: true,
                    title: Text(item.foodName,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14)),
                    subtitle: Text(
                        'P: ${item.protein.toInt()}g  C: ${item.carbs.toInt()}g  F: ${item.fat.toInt()}g',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                    trailing: Text('${item.calories.toInt()} kcal',
                        style: const TextStyle(
                            color: Color(0xFFFF8A65),
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                )),
        ],
      ),
    );
  }
}

class _MacroTrendChart extends ConsumerWidget {
  const _MacroTrendChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklyNutritionProvider(7));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '7-Day Macro Trends',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
        const SizedBox(height: 12),
        weeklyAsync.when(
          loading: () => const SizedBox(height: 180, child: LoadingWidget()),
          error: (_, __) => const SizedBox.shrink(),
          data: (weekly) => _buildMacroTrendChart(weekly),
        ),
      ],
    );
  }

  Widget _buildMacroTrendChart(List<WeeklyNutrition> weekly) {
    if (weekly.isEmpty) {
      return Card(
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('No macro data yet',
                style: TextStyle(color: Colors.white38)),
          ),
        ),
      );
    }

    final proteinSpots = <FlSpot>[];
    final carbsSpots = <FlSpot>[];
    final fatSpots = <FlSpot>[];

    for (int i = 0; i < weekly.length; i++) {
      final d = weekly[i];
      proteinSpots.add(FlSpot(i.toDouble(), d.totalProtein));
      carbsSpots.add(FlSpot(i.toDouble(), d.totalCarbs));
      fatSpots.add(FlSpot(i.toDouble(), d.totalFat));
    }

    final allValues = [
      ...weekly.map((e) => e.totalProtein),
      ...weekly.map((e) => e.totalCarbs),
      ...weekly.map((e) => e.totalFat),
    ];
    final maxY = allValues.isEmpty ? 200.0
        : allValues.reduce((a, b) => a > b ? a : b) * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _legendDot(const Color(0xFF42A5F5), 'Protein'),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFF66BB6A), 'Carbs'),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFFEC407A), 'Fat'),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY > 0 ? maxY : 200,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        const FlLine(color: Colors.white12, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= weekly.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              DateFormat('E').format(weekly[idx].date),
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: proteinSpots,
                      isCurved: true,
                      color: const Color(0xFF42A5F5),
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: carbsSpots,
                      isCurved: true,
                      color: const Color(0xFF66BB6A),
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: fatSpots,
                      isCurved: true,
                      color: const Color(0xFFEC407A),
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(children: [
      Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label,
          style: const TextStyle(color: Colors.white54, fontSize: 11)),
    ]);
  }
}

class _WeeklyCalorieChart extends ConsumerWidget {
  const _WeeklyCalorieChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklyNutritionProvider(7));

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '7-Day Calories',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: weeklyAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Center(
                    child: Text('No data',
                        style: TextStyle(color: Colors.white38))),
                data: (data) {
                  if (data.isEmpty) {
                    return const Center(
                        child: Text('No data yet',
                            style: TextStyle(color: Colors.white38)));
                  }
                  final maxCal = data
                      .map((e) => e.totalCalories)
                      .reduce((a, b) => a > b ? a : b);
                  return BarChart(
                    BarChartData(
                      maxY: maxCal > 0 ? maxCal * 1.2 : 2500,
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= data.length) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  DateFormat('E').format(data[idx].date),
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(data.length, (i) {
                        final item = data[i];
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: item.totalCalories,
                              width: 18,
                              borderRadius: BorderRadius.circular(4),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF8A65),
                                  Color(0xFFFF6B35),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ],
                        );
                      }),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final item = data[group.x.toInt()];
                            return BarTooltipItem(
                              '${DateFormat('MMM d').format(item.date)}\n${item.totalCalories.toInt()} kcal',
                              const TextStyle(
                                  color: Colors.white, fontSize: 11),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
