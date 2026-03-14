package com.gymflow.dto.response;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NutritionGoalResponse {
    private double goalCalories;
    private double goalProtein;
    private double goalCarbs;
    private double goalFat;
}
