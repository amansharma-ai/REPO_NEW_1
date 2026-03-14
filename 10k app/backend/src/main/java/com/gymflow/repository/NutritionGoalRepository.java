package com.gymflow.repository;

import com.gymflow.model.NutritionGoal;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface NutritionGoalRepository extends JpaRepository<NutritionGoal, Long> {
    Optional<NutritionGoal> findFirstBy();
}
