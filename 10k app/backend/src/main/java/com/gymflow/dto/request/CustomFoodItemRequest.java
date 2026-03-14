package com.gymflow.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import lombok.*;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class CustomFoodItemRequest {
    @NotBlank
    private String name;
    @Positive
    private double calories;
    private double proteinG;
    private double carbsG;
    private double fatG;
    private String servingSize;
}
