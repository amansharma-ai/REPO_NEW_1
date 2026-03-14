package com.gymflow.repository;

import com.gymflow.model.Workout;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;

public interface WorkoutRepository extends JpaRepository<Workout, Long> {
    List<Workout> findByWorkoutDate(LocalDate workoutDate);
    List<Workout> findByWorkoutDateBetweenOrderByWorkoutDateDesc(LocalDate from, LocalDate to);
}
