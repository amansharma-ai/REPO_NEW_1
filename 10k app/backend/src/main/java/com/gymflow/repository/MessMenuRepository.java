package com.gymflow.repository;

import com.gymflow.model.MessMenu;
import com.gymflow.model.enums.MealType;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface MessMenuRepository extends JpaRepository<MessMenu, Long> {
    List<MessMenu> findByDayOfWeekIgnoreCase(String dayOfWeek);
    List<MessMenu> findByDayOfWeekIgnoreCaseAndMealType(String dayOfWeek, MealType mealType);
}
