import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/exercise_repo.dart';
import '../data/models/exercise.dart';

final exerciseRepositoryProvider = Provider((ref) => ExerciseRepository());

final allExercisesProvider = FutureProvider<List<Exercise>>((ref) {
  return ref.watch(exerciseRepositoryProvider).getExercises();
});

final exercisesByMuscleGroupProvider = FutureProvider.family<List<Exercise>, String>((ref, group) {
  return ref.watch(exerciseRepositoryProvider).getExercises(muscleGroup: group);
});
