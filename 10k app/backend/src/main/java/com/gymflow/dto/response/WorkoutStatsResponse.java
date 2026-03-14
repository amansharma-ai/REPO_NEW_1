package com.gymflow.dto.response;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WorkoutStatsResponse {
    private long totalWorkouts;
    private long totalSets;
    private double totalVolume;
    private int currentStreak;
    private int longestStreak;
}
