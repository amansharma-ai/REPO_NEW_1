package com.gymflow.dto.response;

import com.gymflow.model.enums.ChallengeType;
import lombok.*;
import java.time.LocalDate;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class DailyChallengeResponse {
    private Long id;
    private LocalDate challengeDate;
    private Long exerciseId;
    private String exerciseName;
    private String muscleGroup;
    private ChallengeType challengeType;
    private double suggestedWeight;
    private int suggestedReps;
    private int suggestedSets;
    private String reason;
    private boolean completed;
}
