import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/nutrition_ring.dart';
import '../../core/widgets/macro_progress_bar.dart';
import '../../core/widgets/loading_widget.dart';
import '../../providers/nutrition_providers.dart';
import '../../providers/challenge_providers.dart';
import '../../providers/workout_providers.dart';
import '../../providers/nav_providers.dart';
import '../nutrition/add_food_screen.dart';
import '../workout/log_workout_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final summaryAsync = ref.watch(dailySummaryProvider(today));
    final challengesAsync = ref.watch(todayChallengesProvider);
    final statsAsync = ref.watch(workoutStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF00C9A7), Color(0xFF00E5BF)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('G',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          const Text('GymFlow'),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20),
            onPressed: () =>
                ref.read(selectedTabProvider.notifier).state = 1,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient welcome banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C9A7), Color(0xFF0091FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, Champ! 💪',
                    style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMM d').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Streak Strip
            statsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (stats) => _buildStreakStrip(context, stats),
            ),
            const SizedBox(height: 16),

            // Calorie Ring Card
            summaryAsync.when(
              loading: () =>
                  const SizedBox(height: 200, child: LoadingWidget()),
              error: (e, _) => _buildCalorieCard(
                  context, 0, 2200, 0, 120, 0, 280, 0, 70),
              data: (summary) => _buildCalorieCard(
                context,
                summary.totalCalories,
                summary.goalCalories,
                summary.totalProtein,
                summary.goalProtein,
                summary.totalCarbs,
                summary.goalCarbs,
                summary.totalFat,
                summary.goalFat,
              ),
            ),
            const SizedBox(height: 20),

            // Today's Workout Summary
            Text('Today\'s Workout',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            _buildWorkoutSummary(context, ref, today),
            const SizedBox(height: 20),

            // Body Weight Card
            _buildBodyWeightCard(context, ref, today),
            const SizedBox(height: 20),

            // Today's Challenges Preview
            Text('Today\'s Challenges',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            challengesAsync.when(
              loading: () =>
                  const SizedBox(height: 100, child: LoadingWidget()),
              error: (e, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Start logging workouts to get challenges!',
                      style: const TextStyle(color: Colors.white54)),
                ),
              ),
              data: (challenges) {
                if (challenges.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events,
                              color: Colors.amber, size: 32),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                                'Log some workouts to unlock daily challenges!',
                                style: TextStyle(color: Colors.white70)),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: challenges
                      .take(3)
                      .map((c) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                c.completed
                                    ? Icons.check_circle
                                    : Icons.fitness_center,
                                color: c.completed
                                    ? Colors.green
                                    : const Color(0xFF00C9A7),
                              ),
                              title: Text(c.exerciseName ?? 'Exercise',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              subtitle: Text(c.reason ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 12)),
                              trailing: c.completed
                                  ? const Text('Done!',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600))
                                  : Text(c.summary,
                                      style: const TextStyle(
                                          color: Color(0xFF00C9A7),
                                          fontWeight: FontWeight.w600)),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 20),

            // Quick Actions
            Text('Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            Row(
              children: [
                _quickAction(
                  context,
                  Icons.restaurant,
                  'Log Food',
                  const Color(0xFFFF8A65),
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                AddFoodScreen(logDate: DateTime.now())));
                    ref.invalidate(dailySummaryProvider(today));
                  },
                ),
                const SizedBox(width: 12),
                _quickAction(
                  context,
                  Icons.fitness_center,
                  'Log Workout',
                  const Color(0xFF7C4DFF),
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LogWorkoutScreen()));
                    ref.invalidate(workoutsByDateProvider(today));
                    ref.invalidate(todayChallengesProvider);
                    ref.invalidate(workoutStatsProvider);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutSummary(
      BuildContext context, WidgetRef ref, String today) {
    final workoutsAsync = ref.watch(workoutsByDateProvider(today));
    return workoutsAsync.when(
      loading: () => const SizedBox(height: 60, child: LoadingWidget()),
      error: (_, __) => const SizedBox.shrink(),
      data: (workouts) {
        if (workouts.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.fitness_center,
                      color: Colors.white38, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('No workout logged today',
                        style: TextStyle(color: Colors.white54)),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LogWorkoutScreen())),
                    child: const Text('Log Workout →',
                        style: TextStyle(
                            color: Color(0xFF00C9A7),
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                ],
              ),
            ),
          );
        }

        final allSets = workouts.expand((w) => w.sets).toList();
        final totalSets = allSets.length;
        final exerciseNames =
            allSets.map((s) => s.exerciseName ?? 'Exercise').toSet().toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Color(0xFF00C9A7), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${exerciseNames.length} exercise${exerciseNames.length != 1 ? 's' : ''} · $totalSets set${totalSets != 1 ? 's' : ''}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                  ],
                ),
                if (exerciseNames.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: exerciseNames.take(2).map((name) {
                      return Chip(
                        label: Text(name,
                            style: const TextStyle(
                                color: Color(0xFF00C9A7), fontSize: 11)),
                        backgroundColor:
                            const Color(0xFF00C9A7).withValues(alpha: 0.12),
                        side: BorderSide(
                            color: const Color(0xFF00C9A7)
                                .withValues(alpha: 0.3)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBodyWeightCard(
      BuildContext context, WidgetRef ref, String today) {
    final latestAsync = ref.watch(bodyWeightLatestProvider);
    return latestAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (latest) {
        final weight = latest != null ? latest['weightKg'] as double? : null;
        final display =
            weight != null ? '${weight.toStringAsFixed(1)} kg' : '–';

        return Card(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.monitor_weight_outlined,
                    color: Color(0xFF42A5F5), size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Body Weight',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 12)),
                    Text(display,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: Color(0xFF42A5F5)),
                  tooltip: 'Log Weight',
                  onPressed: () =>
                      _showLogWeightDialog(context, ref, today),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogWeightDialog(
      BuildContext context, WidgetRef ref, String today) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Log Body Weight',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            labelStyle: TextStyle(color: Colors.white54),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color(0xFF42A5F5))),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              final kg = double.tryParse(ctrl.text);
              if (kg == null || kg <= 0) return;
              Navigator.pop(ctx);
              await ref
                  .read(bodyWeightRepositoryProvider)
                  .logWeight(date: today, weightKg: kg);
              ref.invalidate(bodyWeightLatestProvider);
              ref.invalidate(bodyWeightHistoryProvider);
            },
            child: const Text('Log',
                style: TextStyle(
                    color: Color(0xFF42A5F5),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakStrip(
      BuildContext context, Map<String, dynamic> stats) {
    final streak = (stats['currentStreak'] as num?)?.toInt() ?? 0;
    final total = (stats['totalWorkouts'] as num?)?.toInt() ?? 0;

    return Row(
      children: [
        _statChip(
          Icons.local_fire_department_rounded,
          '$streak day${streak != 1 ? 's' : ''}',
          'Streak',
          streak > 0
              ? const Color(0xFFFF8A65)
              : Colors.white38,
        ),
        const SizedBox(width: 12),
        _statChip(
          Icons.fitness_center_rounded,
          '$total',
          'Workouts',
          const Color(0xFF7C4DFF),
        ),
      ],
    );
  }

  Widget _statChip(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: color.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieCard(
      BuildContext ctx,
      double cal,
      double gCal,
      double pro,
      double gPro,
      double carbs,
      double gCarbs,
      double fat,
      double gFat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                NutritionRing(
                  consumed: cal,
                  goal: gCal,
                  color: const Color(0xFFFF8A65),
                  size: 140,
                  centerLabel: 'kcal',
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      MacroProgressBar(
                          label: 'Protein',
                          current: pro,
                          goal: gPro,
                          color: const Color(0xFF42A5F5)),
                      const SizedBox(height: 14),
                      MacroProgressBar(
                          label: 'Carbs',
                          current: carbs,
                          goal: gCarbs,
                          color: const Color(0xFF66BB6A)),
                      const SizedBox(height: 14),
                      MacroProgressBar(
                          label: 'Fat',
                          current: fat,
                          goal: gFat,
                          color: const Color(0xFFEC407A)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(
      BuildContext ctx, IconData icon, String label, Color color,
      {required Future<void> Function() onTap}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.05)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 10),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
