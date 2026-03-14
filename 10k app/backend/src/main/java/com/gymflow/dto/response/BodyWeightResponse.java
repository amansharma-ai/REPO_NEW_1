package com.gymflow.dto.response;

import lombok.*;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BodyWeightResponse {
    private Long id;
    private LocalDate date;
    private double weightKg;
}
