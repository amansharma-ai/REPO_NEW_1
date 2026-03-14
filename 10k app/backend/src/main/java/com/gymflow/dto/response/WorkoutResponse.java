package com.gymflow.dto.response;

import lombok.*;
import java.time.LocalDate;
import java.util.List;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class WorkoutResponse {
    private Long id;
    private LocalDate workoutDate;
    private String notes;
    private List<WorkoutSetResponse> sets;
}
