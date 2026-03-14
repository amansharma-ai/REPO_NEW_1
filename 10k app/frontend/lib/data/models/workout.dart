import 'workout_set.dart';

class Workout {
  final int? id;
  final String workoutDate;
  final String? notes;
  final List<WorkoutSet> sets;

  const Workout({
    this.id,
    required this.workoutDate,
    this.notes,
    required this.sets,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as int?,
      workoutDate: json['workoutDate'] as String,
      notes: json['notes'] as String?,
      sets: (json['sets'] as List<dynamic>?)
              ?.map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'workoutDate': workoutDate,
    'notes': notes,
    'sets': sets.map((s) => s.toJson()).toList(),
  };
}
