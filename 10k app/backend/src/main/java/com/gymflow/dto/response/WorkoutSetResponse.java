package com.gymflow.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class WorkoutSetResponse {
    private Long id;
    private Long exerciseId;
    private String exerciseName;
    private String muscleGroup;
    private int setNumber;
    private int reps;
    private double weightKg;
    private Integer durationSeconds;
    @JsonProperty("isPR")
    private boolean isPR;
    private double estimatedOneRM;
    private double volume;
}
