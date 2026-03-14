package com.gymflow.dto.response;

import com.gymflow.model.enums.MealType;
import lombok.*;
import java.util.List;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MessMenuResponse {
    private String dayOfWeek;
    private MealType mealType;
    private List<FoodItemResponse> items;

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class FoodItemResponse {
        private Long id;
        private String name;
        private double calories;
        private double proteinG;
        private double carbsG;
        private double fatG;
        private String servingSize;
    }
}
