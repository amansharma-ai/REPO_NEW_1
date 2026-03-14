package com.gymflow.dto.response;

import lombok.*;
import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExerciseProgressResponse {
    private Long exerciseId;
    private String exerciseName;
    private List<DataPoint> dataPoints;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DataPoint {
        private LocalDate date;
        private double estimatedOneRM;
        private double weightKg;
        private int reps;
    }
}
