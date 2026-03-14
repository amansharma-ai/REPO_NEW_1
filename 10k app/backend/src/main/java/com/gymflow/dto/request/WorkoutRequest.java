package com.gymflow.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import java.time.LocalDate;
import java.util.List;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class WorkoutRequest {
    @NotNull
    private LocalDate workoutDate;
    private String notes;
    @Valid
    private List<WorkoutSetRequest> sets;
}
