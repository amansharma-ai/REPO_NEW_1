package com.gymflow.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.*;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class WorkoutSetRequest {
    @NotNull
    private Long exerciseId;
    @Positive
    private int setNumber;
    @Positive
    private int reps;
    private double weightKg;
    private Integer durationSeconds;
}
