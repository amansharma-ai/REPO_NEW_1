package com.gymflow.dto.request;

import com.gymflow.model.enums.MealType;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.*;
import java.time.LocalDate;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class NutritionLogRequest {
    @NotNull
    private LocalDate logDate;
    @NotNull
    private MealType mealType;
    @NotNull
    private Long foodItemId;
    @Positive
    @Builder.Default
    private double servings = 1.0;
}
