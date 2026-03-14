package com.gymflow.repository;

import com.gymflow.model.FoodItem;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface FoodItemRepository extends JpaRepository<FoodItem, Long> {
    List<FoodItem> findByNameContainingIgnoreCase(String name);
    List<FoodItem> findByIsCustomTrue();
    List<FoodItem> findByFoodCategoryIgnoreCase(String category);
}
