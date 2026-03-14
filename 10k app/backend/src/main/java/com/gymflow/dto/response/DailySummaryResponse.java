package com.gymflow.dto.response;

import com.gymflow.model.enums.MealType;
import lombok.*;
import java.time.LocalDate;
import java.util.List;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class DailySummaryResponse {
    private LocalDate date;
    private double totalCalories;
    private double totalProtein;
    private double totalCarbs;
    private double totalFat;
    private double goalCalories;
    private double goalProtein;
    private double goalCarbs;
    private double goalFat;
    private List<MealSummaryResponse> meals;

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class MealSummaryResponse {
        private MealType mealType;
        private double calories;
        private double protein;
        private double carbs;
        private double fat;
        private List<LogEntry> items;
    }

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class LogEntry {
        private Long logId;
        private Long foodItemId;
        private String foodName;
        private double servings;
        private double calories;
        private double protein;
        private double carbs;
        private double fat;
    }
}
