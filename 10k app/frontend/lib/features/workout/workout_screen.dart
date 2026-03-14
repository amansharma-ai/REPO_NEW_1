import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../providers/workout_providers.dart';
import 'log_workout_screen.dart';
import 'workout_history_screen.dart';
import 'workout_detail_screen.dart';
import 'exercise_library_screen.dart';
import 'progress_screen.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final workoutsAsync = ref.watch(workoutsByDateProvider(today));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Progress',
            color: const Color(0xFF00C9A7),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProgressScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.library_books_outlined),
            tooltip: 'Exercise Library',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const ExerciseLibraryScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const WorkoutHistoryScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const LogWorkoutScreen()));
          ref.invalidate(workoutsByDateProvider(today));
        },
        backgroundColor: const Color(0xFF7C4DFF),
        icon: const Icon(Icons.add),
        label: const Text('Log Workout'),
      ),
      body: workoutsAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: Colors.white54))),
        data: (workouts) {
          if (workouts.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.fitness_center,
              title: 'No workouts today',
              subtitle: 'Hit the gym and log your sets!',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workouts.length,
            itemBuilder: (ctx, i) {
              final w = workouts[i];
              final Map<String, List> byExercise = {};
              for (final s in w.sets) {
                final name = s.exerciseName ?? 'Exercise ${s.exerciseId}';
                byExercise.putIfAbsent(name, () => []).add(s);
              }

              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => WorkoutDetailScreen(workout: w))),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151528),
                    borderRadius: BorderRadius.circular(20),
                    border: Border(
                      left: const BorderSide(
                          color: Color(0xFF7C4DFF), width: 3),
                      top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.07)),
                      right: BorderSide(
                          color: Colors.white.withValues(alpha: 0.07)),
                      bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.07)),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Workout #${i + 1}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            if (w.notes != null && w.notes!.isNotEmpty)
                              Flexible(
                                  child: Text(w.notes!,
                                      style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 12),
                                      overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...byExercise.entries.map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        margin: const EdgeInsets.only(right: 6),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF7C4DFF),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Text(entry.key,
                                          style: const TextStyle(
                                              color: Color(0xFF7C4DFF),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    children: entry.value
                                        .map<Widget>((s) => Chip(
                                              label: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '${s.weightKg?.toStringAsFixed(1) ?? '-'}kg x ${s.reps ?? '-'}',
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white),
                                                  ),
                                                  if (s.isPR) ...[
                                                    const SizedBox(width: 4),
                                                    const Icon(Icons.star,
                                                        size: 12,
                                                        color: Color(
                                                            0xFFFFD700)),
                                                  ],
                                                ],
                                              ),
                                              backgroundColor: s.isPR
                                                  ? const Color(0xFF3A3010)
                                                  : const Color(0xFF1E1E35),
                                              side: s.isPR
                                                  ? const BorderSide(
                                                      color: Color(0xFFFFD700),
                                                      width: 1)
                                                  : BorderSide(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.07)),
                                              padding: EdgeInsets.zero,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ))
                                        .toList(),
                                  ),
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
