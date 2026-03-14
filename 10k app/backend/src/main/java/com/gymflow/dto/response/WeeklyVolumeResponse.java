package com.gymflow.dto.response;

import lombok.*;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WeeklyVolumeResponse {
    private List<WeekEntry> weeks;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class WeekEntry {
        private String weekLabel;
        private double totalVolume;
    }
}
