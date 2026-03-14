package com.gymflow.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;
import java.time.LocalDate;

@Data
public class BodyWeightRequest {
    @NotNull
    private LocalDate date;

    @Positive
    private double weightKg;
}
