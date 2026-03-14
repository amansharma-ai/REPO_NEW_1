package com.gymflow.repository;

import com.gymflow.model.NutritionLog;
import com.gymflow.model.enums.MealType;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;

public interface NutritionLogRepository extends JpaRepository<NutritionLog, Long> {
    List<NutritionLog> findByLogDate(LocalDate logDate);
    List<NutritionLog> findByLogDateAndMealType(LocalDate logDate, MealType mealType);
    List<NutritionLog> findByLogDateBetween(LocalDate from, LocalDate to);
}
