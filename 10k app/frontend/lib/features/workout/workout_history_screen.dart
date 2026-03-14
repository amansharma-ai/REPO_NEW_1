import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/loading_widget.dart';
import '../../providers/workout_providers.dart';
import 'log_workout_screen.dart';
import 'workout_detail_screen.dart';

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() =>
      _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  late String _from;
  late String _to;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _to = DateFormat('yyyy-MM-dd').format(now);
    _from = DateFormat('yyyy-MM-dd')
        .format(now.subtract(const Duration(days: 30)));
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(workoutRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: FutureBuilder(
        future: repo.getWorkoutHistory(_from, _to),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snap.hasError) {
            return Center(
                child: Text('Error: ${snap.error}',
                    style: const TextStyle(color: Colors.white54)));
          }
          final workouts = snap.data ?? [];
          if (workouts.isEmpty) {
            return const Center(
                child: Text('No workouts in the last 30 days',
                    style: TextStyle(color: Colors.white54)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workouts.length,
            itemBuilder: (ctx, i) {
              final w = workouts[i];
              final Map<String, List> byExercise = {};
              for (final s in w.sets) {
                final name = s.exerciseName ?? 'Exercise';
                byExercise.putIfAbsent(name, () => []).add(s);
              }

              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => WorkoutDetailScreen(workout: w))),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(w.workoutDate,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF7C4DFF))),
                            Row(
                              children: [
                                Text('${w.sets.length} sets',
                                    style: const TextStyle(
                                        color: Colors.white38)),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.repeat,
                                      size: 20, color: Color(0xFF00C9A7)),
                                  tooltip: 'Repeat workout',
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => LogWorkoutScreen(
                                              repeatSets: w.sets))),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (w.notes != null) ...[
                          const SizedBox(height: 4),
                          Text(w.notes!,
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12)),
                        ],
                        const SizedBox(height: 10),
                        ...byExercise.entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(e.key,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13))),
                                  Text('${e.value.length} sets',
                                      style: const TextStyle(
                                          color: Colors.white38, fontSize: 12)),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
