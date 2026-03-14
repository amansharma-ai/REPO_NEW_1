class DailyChallenge {
  final int? id;
  final String challengeDate;
  final int exerciseId;
  final String? exerciseName;
  final String? muscleGroup;
  final String challengeType;
  final double? suggestedWeight;
  final int? suggestedReps;
  final int? suggestedSets;
  final String? reason;
  final bool completed;

  const DailyChallenge({
    this.id,
    required this.challengeDate,
    required this.exerciseId,
    this.exerciseName,
    this.muscleGroup,
    required this.challengeType,
    this.suggestedWeight,
    this.suggestedReps,
    this.suggestedSets,
    this.reason,
    this.completed = false,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] as int?,
      challengeDate: json['challengeDate'] as String,
      exerciseId: json['exerciseId'] as int,
      exerciseName: json['exerciseName'] as String?,
      muscleGroup: json['muscleGroup'] as String?,
      challengeType: json['challengeType'] as String,
      suggestedWeight: (json['suggestedWeight'] as num?)?.toDouble(),
      suggestedReps: json['suggestedReps'] as int?,
      suggestedSets: json['suggestedSets'] as int?,
      reason: json['reason'] as String?,
      completed: json['completed'] as bool? ?? false,
    );
  }

  DailyChallenge copyWith({
    int? id,
    String? challengeDate,
    int? exerciseId,
    String? exerciseName,
    String? muscleGroup,
    String? challengeType,
    double? suggestedWeight,
    int? suggestedReps,
    int? suggestedSets,
    String? reason,
    bool? completed,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      challengeDate: challengeDate ?? this.challengeDate,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      challengeType: challengeType ?? this.challengeType,
      suggestedWeight: suggestedWeight ?? this.suggestedWeight,
      suggestedReps: suggestedReps ?? this.suggestedReps,
      suggestedSets: suggestedSets ?? this.suggestedSets,
      reason: reason ?? this.reason,
      completed: completed ?? this.completed,
    );
  }

  /// Human-readable summary of the challenge target.
  String get summary {
    final parts = <String>[];
    if (suggestedSets != null) parts.add('$suggestedSets sets');
    if (suggestedReps != null) parts.add('$suggestedReps reps');
    if (suggestedWeight != null) parts.add('${suggestedWeight}kg');
    return parts.join(' x ');
  }

  @override
  String toString() =>
      'DailyChallenge(id: $id, exercise: $exerciseName, '
      'type: $challengeType, completed: $completed)';
}
