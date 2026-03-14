package com.gymflow.repository;

import com.gymflow.model.Exercise;
import com.gymflow.model.enums.ExerciseType;
import com.gymflow.model.enums.MuscleGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ExerciseRepository extends JpaRepository<Exercise, Long> {
    List<Exercise> findByExerciseType(ExerciseType exerciseType);
    List<Exercise> findByMuscleGroup(MuscleGroup muscleGroup);
    List<Exercise> findByExerciseTypeAndMuscleGroup(ExerciseType exerciseType, MuscleGroup muscleGroup);
}
