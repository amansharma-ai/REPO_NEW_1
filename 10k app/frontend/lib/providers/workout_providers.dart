import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/workout_repo.dart';
import '../data/repositories/body_weight_repo.dart';
import '../data/models/workout.dart';

final workoutRepositoryProvider = Provider((ref) => WorkoutRepository());

final workoutsByDateProvider = FutureProvider.family<List<Workout>, String>((ref, date) {
  return ref.watch(workoutRepositoryProvider).getWorkoutsByDate(date);
});

final exerciseHistoryProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, id) {
  return ref.watch(workoutRepositoryProvider).getExerciseHistory(id);
});

final exerciseBestSetProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, id) {
  return ref.watch(workoutRepositoryProvider).getExerciseBestSet(id);
});

final bodyWeightRepositoryProvider = Provider((ref) => BodyWeightRepository());

final exerciseProgressProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, id) =>
        ref.watch(workoutRepositoryProvider).getExerciseProgress(id));

final workoutStatsProvider = FutureProvider<Map<String, dynamic>>(
    (ref) => ref.watch(workoutRepositoryProvider).getWorkoutStats());

final weeklyVolumeProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, weeks) =>
        ref.watch(workoutRepositoryProvider).getWeeklyVolume(weeks: weeks));

final bodyWeightHistoryProvider = FutureProvider<List<dynamic>>(
    (ref) => ref.watch(bodyWeightRepositoryProvider).getHistory(days: 30));

final bodyWeightLatestProvider = FutureProvider<Map<String, dynamic>?>(
    (ref) => ref.watch(bodyWeightRepositoryProvider).getLatest());
