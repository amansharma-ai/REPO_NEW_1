package com.gymflow.dto.response;

import com.gymflow.model.enums.ActivityLevel;
import com.gymflow.model.enums.FitnessGoal;
import com.gymflow.model.enums.Gender;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserProfileResponse {
    private double heightCm;
    private double weightKg;
    private double age;
    private Gender gender;
    private ActivityLevel activityLevel;
    private FitnessGoal fitnessGoal;
    private double bmr;
    private double tdee;
    private double goalCalories;
    private double goalProtein;
    private double goalCarbs;
    private double goalFat;
}
