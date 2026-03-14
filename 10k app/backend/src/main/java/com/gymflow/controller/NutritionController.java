package com.gymflow.controller;

import com.gymflow.dto.request.CustomFoodItemRequest;
import com.gymflow.dto.request.NutritionGoalRequest;
import com.gymflow.dto.request.NutritionLogRequest;
import com.gymflow.dto.response.DailySummaryResponse;
import com.gymflow.dto.response.MessMenuResponse;
import com.gymflow.dto.response.NutritionGoalResponse;
import com.gymflow.dto.response.WeeklyNutritionResponse;
import com.gymflow.model.FoodItem;
import com.gymflow.model.NutritionLog;
import com.gymflow.service.NutritionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/nutrition")
@RequiredArgsConstructor
public class NutritionController {

    private final NutritionService nutritionService;

    @GetMapping("/menu")
    public List<MessMenuResponse> getMenu(@RequestParam String day) {
        return nutritionService.getMenuForDay(day);
    }

    @GetMapping("/menu/today")
    public List<MessMenuResponse> getTodayMenu() {
        return nutritionService.getTodayMenu();
    }

    @PostMapping("/log")
    public ResponseEntity<NutritionLog> logFood(@Valid @RequestBody NutritionLogRequest request) {
        return ResponseEntity.ok(nutritionService.logFood(request));
    }

    @DeleteMapping("/log/{id}")
    public ResponseEntity<Void> deleteLog(@PathVariable Long id) {
        nutritionService.deleteLog(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/summary")
    public DailySummaryResponse getDailySummary(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return nutritionService.getDailySummary(date);
    }

    @PostMapping("/food/custom")
    public ResponseEntity<FoodItem> addCustomFood(@Valid @RequestBody CustomFoodItemRequest request) {
        return ResponseEntity.ok(nutritionService.addCustomFood(request));
    }

    @GetMapping("/food/search")
    public List<FoodItem> searchFoods(@RequestParam String q) {
        return nutritionService.searchFoods(q);
    }

    @GetMapping("/goals")
    public NutritionGoalResponse getGoal() {
        return nutritionService.getGoal();
    }

    @PutMapping("/goals")
    public ResponseEntity<NutritionGoalResponse> updateGoal(@Valid @RequestBody NutritionGoalRequest request) {
        return ResponseEntity.ok(nutritionService.updateGoal(request));
    }

    @GetMapping("/history/weekly")
    public List<WeeklyNutritionResponse> getWeeklyHistory(
            @RequestParam(defaultValue = "7") int days) {
        return nutritionService.getWeeklyHistory(days);
    }

    @GetMapping("/food/browse")
    public List<FoodItem> browseByCategory(@RequestParam String category) {
        return nutritionService.getFoodsByCategory(category);
    }
}
