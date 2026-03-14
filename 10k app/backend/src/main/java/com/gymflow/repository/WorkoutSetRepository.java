package com.gymflow.repository;

import com.gymflow.model.WorkoutSet;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface WorkoutSetRepository extends JpaRepository<WorkoutSet, Long> {
    List<WorkoutSet> findByExerciseIdOrderByWorkoutWorkoutDateDescSetNumberAsc(Long exerciseId);
    List<WorkoutSet> findByExerciseId(Long exerciseId);
}
