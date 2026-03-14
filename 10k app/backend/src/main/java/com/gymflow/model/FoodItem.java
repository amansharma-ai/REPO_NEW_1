package com.gymflow.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "food_item")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class FoodItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    private double calories;
    private double proteinG;
    private double carbsG;
    private double fatG;

    @Column(length = 50)
    private String servingSize;

    @Builder.Default
    private boolean isCustom = false;

    @Column(length = 30)
    private String foodCategory;
}
