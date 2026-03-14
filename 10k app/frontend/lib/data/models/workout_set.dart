class WorkoutSet {
  final int? id;
  final int exerciseId;
  final String? exerciseName;
  final String? muscleGroup;
  final int setNumber;
  final int? reps;
  final double? weightKg;
  final int? durationSeconds;
  final bool isPR;
  final double estimatedOneRM;
  final double volume;

  const WorkoutSet({
    this.id,
    required this.exerciseId,
    this.exerciseName,
    this.muscleGroup,
    required this.setNumber,
    this.reps,
    this.weightKg,
    this.durationSeconds,
    this.isPR = false,
    this.estimatedOneRM = 0.0,
    this.volume = 0.0,
  });

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      id: json['id'] as int?,
      exerciseId: json['exerciseId'] as int,
      exerciseName: json['exerciseName'] as String?,
      muscleGroup: json['muscleGroup'] as String?,
      setNumber: json['setNumber'] as int,
      reps: json['reps'] as int?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      durationSeconds: json['durationSeconds'] as int?,
      isPR: json['isPR'] as bool? ?? false,
      estimatedOneRM: (json['estimatedOneRM'] as num?)?.toDouble() ?? 0.0,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'setNumber': setNumber,
      if (reps != null) 'reps': reps,
      if (weightKg != null) 'weightKg': weightKg,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
    };
  }

  WorkoutSet copyWith({
    int? id,
    int? exerciseId,
    String? exerciseName,
    String? muscleGroup,
    int? setNumber,
    int? reps,
    double? weightKg,
    int? durationSeconds,
    bool? isPR,
    double? estimatedOneRM,
    double? volume,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isPR: isPR ?? this.isPR,
      estimatedOneRM: estimatedOneRM ?? this.estimatedOneRM,
      volume: volume ?? this.volume,
    );
  }

  @override
  String toString() =>
      'WorkoutSet(exercise: $exerciseName, set: $setNumber, '
      'reps: $reps, weight: $weightKg kg, isPR: $isPR)';
}
