package com.gymflow.service;

import com.gymflow.dto.request.UserProfileRequest;
import com.gymflow.dto.response.UserProfileResponse;
import com.gymflow.model.NutritionGoal;
import com.gymflow.model.UserProfile;
import com.gymflow.model.enums.ActivityLevel;
import com.gymflow.model.enums.FitnessGoal;
import com.gymflow.model.enums.Gender;
import com.gymflow.repository.NutritionGoalRepository;
import com.gymflow.repository.UserProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserProfileService {

    private final UserProfileRepository userProfileRepo;
    private final NutritionGoalRepository nutritionGoalRepo;

    public UserProfileResponse getProfile() {
        return toResponse(getOrCreate());
    }

    @Transactional
    public UserProfileResponse updateProfile(UserProfileRequest req) {
        UserProfile profile = userProfileRepo.findFirstBy().orElseGet(UserProfile::new);
        profile.setHeightCm(req.getHeightCm());
        profile.setWeightKg(req.getWeightKg());
        profile.setAge(req.getAge());
        profile.setGender(req.getGender());
        profile.setActivityLevel(req.getActivityLevel());
        profile.setFitnessGoal(req.getFitnessGoal());
        profile = userProfileRepo.save(profile);

        UserProfileResponse resp = toResponse(profile);

        // Sync NutritionGoal with calculated values
        NutritionGoal goal = nutritionGoalRepo.findFirstBy()
                .orElseGet(() -> NutritionGoal.builder()
                        .goalCalories(2200).goalProtein(120).goalCarbs(280).goalFat(70).build());
        goal.setGoalCalories(resp.getGoalCalories());
        goal.setGoalProtein(resp.getGoalProtein());
        goal.setGoalCarbs(resp.getGoalCarbs());
        goal.setGoalFat(resp.getGoalFat());
        nutritionGoalRepo.save(goal);

        return resp;
    }

    private UserProfile getOrCreate() {
        return userProfileRepo.findFirstBy().orElseGet(() -> {
            UserProfile def = UserProfile.builder()
                    .heightCm(170).weightKg(70).age(22)
                    .gender(Gender.MALE)
                    .activityLevel(ActivityLevel.MODERATE)
                    .fitnessGoal(FitnessGoal.MAINTAIN)
                    .build();
            return userProfileRepo.save(def);
        });
    }

    private UserProfileResponse toResponse(UserProfile p) {
        double bmr = 10 * p.getWeightKg() + 6.25 * p.getHeightCm() - 5 * p.getAge()
                + (p.getGender() == Gender.MALE ? 5 : -161);

        double actMult = switch (p.getActivityLevel()) {
            case SEDENTARY  -> 1.2;
            case LIGHT      -> 1.375;
            case MODERATE   -> 1.55;
            case ACTIVE     -> 1.725;
            case VERY_ACTIVE -> 1.9;
        };

        double goalMult = switch (p.getFitnessGoal()) {
            case MAINTAIN    -> 1.0;
            case CUT         -> 0.80;
            case BULK        -> 1.15;
            case BODY_RECOMP -> 1.0;
        };

        double tdee = bmr * actMult;
        double goalCalories = tdee * goalMult;

        double proteinFactor = switch (p.getFitnessGoal()) {
            case CUT, BODY_RECOMP -> 2.2;
            case BULK             -> 1.8;
            case MAINTAIN         -> 2.0;
        };

        double protein = p.getWeightKg() * proteinFactor;
        double fat = goalCalories * 0.25 / 9;
        double carbs = (goalCalories - protein * 4 - fat * 9) / 4;

        return UserProfileResponse.builder()
                .heightCm(p.getHeightCm())
                .weightKg(p.getWeightKg())
                .age(p.getAge())
                .gender(p.getGender())
                .activityLevel(p.getActivityLevel())
                .fitnessGoal(p.getFitnessGoal())
                .bmr(Math.round(bmr * 10.0) / 10.0)
                .tdee(Math.round(tdee * 10.0) / 10.0)
                .goalCalories(Math.round(goalCalories * 10.0) / 10.0)
                .goalProtein(Math.round(protein * 10.0) / 10.0)
                .goalCarbs(Math.round(carbs * 10.0) / 10.0)
                .goalFat(Math.round(fat * 10.0) / 10.0)
                .build();
    }
}
