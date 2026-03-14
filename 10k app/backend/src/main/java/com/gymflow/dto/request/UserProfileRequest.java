package com.gymflow.dto.request;

import com.gymflow.model.enums.ActivityLevel;
import com.gymflow.model.enums.FitnessGoal;
import com.gymflow.model.enums.Gender;
import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class UserProfileRequest {
    @Positive
    private double heightCm;

    @Positive
    private double weightKg;

    @Min(10) @Max(100)
    private int age;

    @NotNull
    private Gender gender;

    @NotNull
    private ActivityLevel activityLevel;

    @NotNull
    private FitnessGoal fitnessGoal;
}
