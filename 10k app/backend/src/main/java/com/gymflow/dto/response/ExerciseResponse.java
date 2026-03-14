package com.gymflow.dto.response;

import com.gymflow.model.enums.ExerciseType;
import com.gymflow.model.enums.MuscleGroup;
import lombok.*;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ExerciseResponse {
    private Long id;
    private String name;
    private ExerciseType exerciseType;
    private MuscleGroup muscleGroup;
}
