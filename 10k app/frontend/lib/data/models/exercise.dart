class Exercise {
  final int id;
  final String name;
  final String exerciseType;
  final String muscleGroup;

  const Exercise({
    required this.id,
    required this.name,
    required this.exerciseType,
    required this.muscleGroup,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int,
      name: json['name'] as String,
      exerciseType: json['exerciseType'] as String,
      muscleGroup: json['muscleGroup'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'exerciseType': exerciseType,
    'muscleGroup': muscleGroup,
  };
}
