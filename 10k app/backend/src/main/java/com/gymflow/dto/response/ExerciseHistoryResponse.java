package com.gymflow.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import java.time.LocalDate;
import java.util.List;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ExerciseHistoryResponse {
    private Long exerciseId;
    private String exerciseName;
    private List<SessionEntry> sessions;
    private double allTimeBestOneRM;
    private double allTimeBestWeight;
    private int allTimeBestReps;

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class SessionEntry {
        private LocalDate date;
        private List<SetEntry> sets;
        private double totalVolume;
    }

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class SetEntry {
        private int setNumber;
        private int reps;
        private double weightKg;
        private double estimatedOneRM;
        @JsonProperty("isPR")
        private boolean isPR;
    }
}
