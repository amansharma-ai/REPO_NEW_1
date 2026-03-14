package com.gymflow.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "nutrition_goal")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NutritionGoal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private double goalCalories;

    @Column(nullable = false)
    private double goalProtein;

    @Column(nullable = false)
    private double goalCarbs;

    @Column(nullable = false)
    private double goalFat;
}
