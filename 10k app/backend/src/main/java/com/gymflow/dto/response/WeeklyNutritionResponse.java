package com.gymflow.dto.response;

import lombok.*;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WeeklyNutritionResponse {
    private LocalDate date;
    private double totalCalories;
    private double totalProtein;
    private double totalCarbs;
    private double totalFat;
}
