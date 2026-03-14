import 'package:flutter/material.dart';
import '../../data/models/workout.dart';
import '../../data/models/workout_set.dart';
import 'log_workout_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    // Group sets by exercise
    final Map<String, List<WorkoutSet>> byExercise = {};
    for (final s in workout.sets) {
      final name = s.exerciseName ?? 'Exercise ${s.exerciseId}';
      byExercise.putIfAbsent(name, () => []).add(s);
    }

    final totalVolume =
        workout.sets.fold<double>(0, (sum, s) => sum + s.volume);

    // Find best set (highest estimatedOneRM)
    WorkoutSet? bestSet;
    for (final s in workout.sets) {
      if (bestSet == null || s.estimatedOneRM > bestSet.estimatedOneRM) {
        bestSet = s;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.workoutDate),
      ),
      body: Column(
        children: [
          // Summary header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1A1A2E),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatChip(
                    label: 'Sets', value: '${workout.sets.length}'),
                _StatChip(
                    label: 'Volume',
                    value: '${totalVolume.toStringAsFixed(1)} kg'),
                _StatChip(
                    label: 'Exercises', value: '${byExercise.length}'),
              ],
            ),
          ),
          if (workout.notes != null && workout.notes!.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(workout.notes!,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 13)),
            ),
          // Sets by exercise
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: byExercise.entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.key,
                            style: const TextStyle(
                                color: Color(0xFF7C4DFF),
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        const SizedBox(height: 8),
                        // Header row
                        const Row(
                          children: [
                            SizedBox(
                                width: 40,
                                child: Text('Set',
                                    style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 12))),
                            SizedBox(
                                width: 80,
                                child: Text('Reps × Wt',
                                    style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 12))),
                            SizedBox(
                                width: 70,
                                child: Text('Est. 1RM',
                                    style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 12))),
                            Text('',
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12)),
                          ],
                        ),
                        const Divider(color: Colors.white12),
                        ...entry.value.map((s) {
                          final isBest = s == bestSet;
                          return Container(
                            decoration: isBest
                                ? BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFFFFD700),
                                        width: 1),
                                    borderRadius: BorderRadius.circular(6),
                                  )
                                : null,
                            padding: isBest
                                ? const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2)
                                : null,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: Text('${s.setNumber}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13)),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    '${s.reps ?? '-'} × ${s.weightKg?.toStringAsFixed(1) ?? '-'}kg',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13),
                                  ),
                                ),
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    s.estimatedOneRM > 0
                                        ? '${s.estimatedOneRM.toStringAsFixed(1)} kg'
                                        : '-',
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12),
                                  ),
                                ),
                                if (s.isPR)
                                  const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star,
                                          size: 14,
                                          color: Color(0xFFFFD700)),
                                      SizedBox(width: 2),
                                      Text('PR',
                                          style: TextStyle(
                                              color: Color(0xFFFFD700),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      LogWorkoutScreen(repeatSets: workout.sets))),
          icon: const Icon(Icons.repeat),
          label: const Text('Repeat This Workout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C4DFF),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
