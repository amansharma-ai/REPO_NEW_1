package com.gymflow.dto.request;

import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class NutritionGoalRequest {

    @Positive
    private double goalCalories;

    @Positive
    private double goalProtein;

    @Positive
    private double goalCarbs;

    @Positive
    private double goalFat;
}
