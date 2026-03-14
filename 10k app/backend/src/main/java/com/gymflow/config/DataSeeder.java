package com.gymflow.config;

import com.gymflow.model.*;
import com.gymflow.model.enums.*;
import com.gymflow.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.*;

@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final FoodItemRepository foodItemRepo;
    private final ExerciseRepository exerciseRepo;
    private final MessMenuRepository messMenuRepo;

    @Override
    public void run(String... args) {
        seedExercises();
        seedFoodItems();
        // Day-based mess menu seeding replaced by category-tagged food items
    }

    private void seedExercises() {
        if (exerciseRepo.count() > 0) return;
        List<Exercise> exercises = List.of(
            // CHEST
            ex("Bench Press", ExerciseType.WEIGHT, MuscleGroup.CHEST),
            ex("Incline Dumbbell Press", ExerciseType.WEIGHT, MuscleGroup.CHEST),
            ex("Cable Fly", ExerciseType.WEIGHT, MuscleGroup.CHEST),
            ex("Decline Bench Press", ExerciseType.WEIGHT, MuscleGroup.CHEST),
            ex("Chest Dip", ExerciseType.BODYWEIGHT, MuscleGroup.CHEST),
            ex("Push-up", ExerciseType.BODYWEIGHT, MuscleGroup.CHEST),
            // BACK
            ex("Deadlift", ExerciseType.WEIGHT, MuscleGroup.BACK),
            ex("Barbell Row", ExerciseType.WEIGHT, MuscleGroup.BACK),
            ex("Lat Pulldown", ExerciseType.WEIGHT, MuscleGroup.BACK),
            ex("Seated Cable Row", ExerciseType.WEIGHT, MuscleGroup.BACK),
            ex("T-Bar Row", ExerciseType.WEIGHT, MuscleGroup.BACK),
            ex("Single-Arm Dumbbell Row", ExerciseType.WEIGHT, MuscleGroup.BACK),
            ex("Weighted Pull-up", ExerciseType.WEIGHT, MuscleGroup.BACK),
            ex("Pull-up", ExerciseType.BODYWEIGHT, MuscleGroup.BACK),
            // SHOULDERS
            ex("Overhead Press", ExerciseType.WEIGHT, MuscleGroup.SHOULDERS),
            ex("Lateral Raise", ExerciseType.WEIGHT, MuscleGroup.SHOULDERS),
            ex("Face Pull", ExerciseType.WEIGHT, MuscleGroup.SHOULDERS),
            ex("Arnold Press", ExerciseType.WEIGHT, MuscleGroup.SHOULDERS),
            ex("Rear Delt Fly", ExerciseType.WEIGHT, MuscleGroup.SHOULDERS),
            ex("Upright Row", ExerciseType.WEIGHT, MuscleGroup.SHOULDERS),
            // BICEPS
            ex("Barbell Curl", ExerciseType.WEIGHT, MuscleGroup.BICEPS),
            ex("Dumbbell Curl", ExerciseType.WEIGHT, MuscleGroup.BICEPS),
            ex("Hammer Curl", ExerciseType.WEIGHT, MuscleGroup.BICEPS),
            ex("Preacher Curl", ExerciseType.WEIGHT, MuscleGroup.BICEPS),
            ex("Cable Curl", ExerciseType.WEIGHT, MuscleGroup.BICEPS),
            // TRICEPS
            ex("Tricep Pushdown", ExerciseType.WEIGHT, MuscleGroup.TRICEPS),
            ex("Skull Crusher", ExerciseType.WEIGHT, MuscleGroup.TRICEPS),
            ex("Overhead Tricep Extension", ExerciseType.WEIGHT, MuscleGroup.TRICEPS),
            ex("Close-Grip Bench Press", ExerciseType.WEIGHT, MuscleGroup.TRICEPS),
            ex("Dip", ExerciseType.BODYWEIGHT, MuscleGroup.TRICEPS),
            // LEGS
            ex("Squat", ExerciseType.WEIGHT, MuscleGroup.LEGS),
            ex("Leg Press", ExerciseType.WEIGHT, MuscleGroup.LEGS),
            ex("Romanian Deadlift", ExerciseType.WEIGHT, MuscleGroup.LEGS),
            ex("Leg Curl", ExerciseType.WEIGHT, MuscleGroup.LEGS),
            ex("Calf Raise", ExerciseType.WEIGHT, MuscleGroup.LEGS),
            ex("Hack Squat", ExerciseType.WEIGHT, MuscleGroup.LEGS),
            ex("Bulgarian Split Squat", ExerciseType.WEIGHT, MuscleGroup.LEGS),
            ex("Leg Extension", ExerciseType.WEIGHT, MuscleGroup.LEGS),
            ex("Hip Thrust", ExerciseType.WEIGHT, MuscleGroup.LEGS),
            ex("Sumo Deadlift", ExerciseType.WEIGHT, MuscleGroup.LEGS),
            ex("Lunge", ExerciseType.BODYWEIGHT, MuscleGroup.LEGS),
            ex("Box Jump", ExerciseType.BODYWEIGHT, MuscleGroup.LEGS),
            // CORE
            ex("Plank", ExerciseType.BODYWEIGHT, MuscleGroup.CORE),
            ex("Crunch", ExerciseType.BODYWEIGHT, MuscleGroup.CORE),
            ex("Russian Twist", ExerciseType.BODYWEIGHT, MuscleGroup.CORE),
            ex("Hanging Leg Raise", ExerciseType.BODYWEIGHT, MuscleGroup.CORE),
            ex("Ab Wheel Rollout", ExerciseType.BODYWEIGHT, MuscleGroup.CORE),
            // FULL_BODY
            ex("Burpee", ExerciseType.BODYWEIGHT, MuscleGroup.FULL_BODY),
            ex("Clean and Press", ExerciseType.WEIGHT, MuscleGroup.FULL_BODY),
            ex("Kettlebell Swing", ExerciseType.WEIGHT, MuscleGroup.FULL_BODY),
            ex("Mountain Climber", ExerciseType.BODYWEIGHT, MuscleGroup.FULL_BODY),
            ex("Thruster", ExerciseType.WEIGHT, MuscleGroup.FULL_BODY)
        );
        exerciseRepo.saveAll(exercises);
    }

    private Exercise ex(String name, ExerciseType type, MuscleGroup group) {
        return Exercise.builder().name(name).exerciseType(type).muscleGroup(group).build();
    }

    private void seedFoodItems() {
        if (foodItemRepo.count() > 0) return;

        List<FoodItem> foods = new ArrayList<>();

        // ── BREAKFAST ──────────────────────────────────────────────────────
        foods.addAll(List.of(
            food("Poha",                250, 4,  45, 6,    "1 plate",     "BREAKFAST"),
            food("Besan Ka Chilla",     150, 8,  18, 5,    "1 chilla",    "BREAKFAST"),
            food("Aloo Paratha",        300, 7,  40, 13,   "1 paratha",   "BREAKFAST"),
            food("Dal Parantha",        280, 9,  38, 11,   "1 paratha",   "BREAKFAST"),
            food("Plain Paratha",       230, 5,  35, 8,    "1 paratha",   "BREAKFAST"),
            food("Mix Stuffed Parantha",320, 8,  42, 14,   "1 paratha",   "BREAKFAST"),
            food("Luchi",               200, 4,  28, 9,    "2 pieces",    "BREAKFAST"),
            food("Aloo Bhaji",          150, 3,  22, 6,    "1 bowl",      "BREAKFAST"),
            food("Dalia",               180, 6,  32, 3,    "1 bowl",      "BREAKFAST"),
            food("Idli (2 pcs)",        150, 4,  30, 1,    "2 pieces",    "BREAKFAST"),
            food("Dosa",                170, 4,  28, 5,    "1 dosa",      "BREAKFAST"),
            food("Masala Dosa",         250, 6,  35, 10,   "1 dosa",      "BREAKFAST"),
            food("Upma",                200, 5,  32, 6,    "1 bowl",      "BREAKFAST"),
            food("Chole Bhature",       520, 14, 68, 22,   "1 plate",     "BREAKFAST"),
            food("Moong Dal Cheela",    160, 8,  20, 5,    "1 cheela",    "BREAKFAST"),
            food("Boiled Egg",          78,  6,  1,  5,    "1 egg",       "BREAKFAST"),
            food("Omelette (2 eggs)",   180, 13, 2,  14,   "1 omelette",  "BREAKFAST"),
            food("Egg Bhurji",          200, 14, 4,  14,   "1 plate",     "BREAKFAST"),
            food("Bread & Butter",      180, 4,  25, 7,    "2 slices",    "BREAKFAST"),
            food("Curd / Yogurt",       80,  4,  6,  4,    "1 bowl",      "BREAKFAST"),
            food("Milk Tea",            80,  2,  12, 2,    "1 cup",       "BREAKFAST"),
            food("Milk",                120, 8,  12, 5,    "1 glass (250 ml)", "BREAKFAST"),
            food("Banana",              105, 1,  27, 0,    "1 medium",    "BREAKFAST"),
            food("Dal Kachori",         220, 6,  28, 10,   "1 kachori",   "BREAKFAST")
        ));

        // ── LUNCH ──────────────────────────────────────────────────────────
        foods.addAll(List.of(
            food("Rice (Steamed)",      200, 4,  45, 0.5,  "1 bowl",      "LUNCH"),
            food("Jeera Rice",          220, 4,  46, 2,    "1 bowl",      "LUNCH"),
            food("Veg Pulao",           230, 5,  42, 5,    "1 bowl",      "LUNCH"),
            food("Veg Biryani",         350, 9,  62, 8,    "1 plate",     "LUNCH"),
            food("Chicken Biryani",     400, 22, 50, 12,   "1 plate",     "LUNCH"),
            food("Egg Biryani",         350, 14, 48, 10,   "1 plate",     "LUNCH"),
            food("Chapati",             120, 3,  20, 3,    "1 chapati",   "LUNCH"),
            food("Roti",                100, 3,  18, 2,    "1 roti",      "LUNCH"),
            food("Dal Fry",             150, 9,  20, 4,    "1 bowl",      "LUNCH"),
            food("Dal Tadka",           170, 10, 22, 5,    "1 bowl",      "LUNCH"),
            food("Dal Makhani",         280, 14, 30, 10,   "1 bowl",      "LUNCH"),
            food("Yellow Dal",          160, 9,  22, 4,    "1 bowl",      "LUNCH"),
            food("Sabut Masoor Dal",    180, 12, 24, 4,    "1 bowl",      "LUNCH"),
            food("Malka Masoor Dal",    170, 10, 24, 4,    "1 bowl",      "LUNCH"),
            food("Lobiya Dal",          190, 11, 28, 4,    "1 bowl",      "LUNCH"),
            food("Toor Dal",            170, 10, 24, 4,    "1 bowl",      "LUNCH"),
            food("G-Moong Dal",         160, 10, 22, 4,    "1 bowl",      "LUNCH"),
            food("Maha Chana Dal",      200, 12, 28, 5,    "1 bowl",      "LUNCH"),
            food("Dhaba Dal",           200, 11, 26, 6,    "1 bowl",      "LUNCH"),
            food("Mothi Ki Dal",        180, 11, 26, 4,    "1 bowl",      "LUNCH"),
            food("Rajma Curry",         210, 12, 30, 5,    "1 bowl",      "LUNCH"),
            food("Chole",               220, 11, 28, 7,    "1 bowl",      "LUNCH"),
            food("White Chana",         220, 12, 30, 6,    "1 bowl",      "LUNCH"),
            food("Black Chana",         210, 12, 32, 5,    "1 bowl",      "LUNCH"),
            food("Nutri Matar",         200, 15, 18, 8,    "1 bowl",      "LUNCH"),
            food("Kadhi Pakora",        220, 8,  22, 12,   "1 bowl",      "LUNCH"),
            food("Paneer Butter Masala",320, 15, 12, 24,   "1 bowl",      "LUNCH"),
            food("Shahi Paneer",        290, 14, 10, 22,   "1 bowl",      "LUNCH"),
            food("Palak Paneer",        250, 14, 8,  18,   "1 bowl",      "LUNCH"),
            food("Paneer Lababdar",     330, 16, 12, 24,   "1 bowl",      "LUNCH"),
            food("Paneer Kadal",        290, 14, 12, 20,   "1 bowl",      "LUNCH"),
            food("Paneer Mathi Malai",  340, 15, 10, 28,   "1 bowl",      "LUNCH"),
            food("Mushroom Masala",     180, 6,  12, 12,   "1 bowl",      "LUNCH"),
            food("Aloo Gobi",           160, 4,  22, 7,    "1 bowl",      "LUNCH"),
            food("Mix Veg Curry",       140, 4,  18, 6,    "1 bowl",      "LUNCH"),
            food("Bhindi Masala",       120, 3,  14, 6,    "1 bowl",      "LUNCH"),
            food("Baingan Bharta",      130, 3,  12, 8,    "1 bowl",      "LUNCH"),
            food("Gobhi Matar",         160, 5,  20, 8,    "1 bowl",      "LUNCH"),
            food("Lauki Kootu",         120, 4,  16, 5,    "1 bowl",      "LUNCH"),
            food("Hara Kaddu Peas",     130, 4,  18, 5,    "1 bowl",      "LUNCH"),
            food("Aloo Capsicum",       150, 3,  22, 6,    "1 bowl",      "LUNCH"),
            food("Tam Aloo",            160, 3,  24, 6,    "1 bowl",      "LUNCH"),
            food("Khate Aloo",          160, 3,  26, 6,    "1 bowl",      "LUNCH"),
            food("Sev Tamatar",         140, 4,  18, 7,    "1 bowl",      "LUNCH"),
            food("Aloo Amritsari Badi", 200, 6,  28, 8,    "1 bowl",      "LUNCH"),
            food("Aloo Roast Masala",   180, 3,  26, 7,    "1 bowl",      "LUNCH"),
            food("Chicken Curry",       280, 25, 8,  16,   "1 bowl",      "LUNCH"),
            food("Butter Chicken",      340, 24, 10, 22,   "1 bowl",      "LUNCH"),
            food("Chatinad Chicken",    300, 28, 8,  18,   "1 bowl",      "LUNCH"),
            food("Egg Curry",           200, 14, 8,  13,   "1 bowl",      "LUNCH"),
            food("Fish Curry",          250, 22, 6,  15,   "1 bowl",      "LUNCH"),
            food("Raita",               70,  3,  5,  4,    "1 bowl",      "LUNCH"),
            food("Mix Raita",           75,  3,  6,  4,    "1 bowl",      "LUNCH"),
            food("Boondi Raita",        90,  3,  9,  4,    "1 bowl",      "LUNCH"),
            food("Green Salad",         30,  1,  6,  0,    "1 plate",     "LUNCH"),
            food("Kachumber Salad",     35,  1,  7,  0,    "1 plate",     "LUNCH"),
            food("Chana Peanut Salad",  180, 9,  22, 7,    "1 bowl",      "LUNCH"),
            food("Papad",               50,  3,  7,  1,    "1 piece",     "LUNCH"),
            food("Pickle",              10,  0,  2,  0,    "1 tsp",       "LUNCH")
        ));

        // ── SNACK ──────────────────────────────────────────────────────────
        foods.addAll(List.of(
            food("Samosa",              260, 4,  28, 15,   "1 piece",     "SNACK"),
            food("Pakora",              180, 4,  18, 10,   "5 pieces",    "SNACK"),
            food("Mix Pakora",          180, 4,  18, 10,   "5 pieces",    "SNACK"),
            food("Bread Pakora",        200, 5,  22, 10,   "1 piece",     "SNACK"),
            food("Aloo Tikki",          180, 3,  24, 8,    "2 pieces",    "SNACK"),
            food("Aloo Bonda",          190, 4,  26, 8,    "2 pieces",    "SNACK"),
            food("Vada Pav",            290, 6,  38, 13,   "1 piece",     "SNACK"),
            food("Puri (2 pcs)",        240, 4,  30, 12,   "2 pieces",    "SNACK"),
            food("Maggi Noodles",       310, 7,  42, 13,   "1 packet",    "SNACK"),
            food("Macaroni in White Sauce", 280, 8, 38, 11, "1 bowl",     "SNACK"),
            food("Namak Parai",         150, 3,  20, 7,    "1 serving",   "SNACK"),
            food("Muffin",              200, 4,  32, 7,    "1 muffin",    "SNACK"),
            food("Fruit Chaat",         120, 2,  28, 1,    "1 bowl",      "SNACK"),
            food("Sprout Chaat",        140, 8,  22, 2,    "1 bowl",      "SNACK"),
            food("Lassi (Sweet)",       180, 6,  28, 5,    "1 glass",     "SNACK"),
            food("Buttermilk",          40,  2,  4,  1,    "1 glass",     "SNACK"),
            food("Fresh Lime Water",    30,  0,  8,  0,    "1 glass",     "SNACK"),
            food("Snack Tea",           80,  2,  12, 2,    "1 cup",       "SNACK"),
            food("Black Coffee",        5,   0,  1,  0,    "1 cup",       "SNACK")
        ));

        // ── DINNER ─────────────────────────────────────────────────────────
        foods.addAll(List.of(
            food("Soya Chunk Curry",    200, 18, 14, 8,    "1 bowl",      "DINNER"),
            food("Gulab Jamun",         180, 3,  28, 7,    "2 pieces",    "DINNER"),
            food("Kheer",               200, 5,  32, 6,    "1 bowl",      "DINNER"),
            food("Rice Kheer",          220, 5,  36, 7,    "1 bowl",      "DINNER"),
            food("Halwa",               250, 3,  35, 12,   "1 bowl",      "DINNER"),
            food("Besan Ka Halwa",      300, 6,  38, 14,   "1 bowl",      "DINNER")
        ));

        // ── GYM ────────────────────────────────────────────────────────────
        foods.addAll(List.of(
            food("Peanut Butter",       188, 8,  6,  16,   "2 tbsp",      "GYM"),
            food("Oats",                150, 5,  27, 3,    "½ cup dry",   "GYM"),
            food("Chicken Breast (Grilled)", 165, 31, 0, 3.6, "100g",     "GYM"),
            food("Paneer (Raw)",        265, 18, 4,  20,   "100g",        "GYM"),
            food("Tofu",                70,  8,  2,  4,    "100g",        "GYM"),
            food("Egg White",           52,  11, 1,  0,    "3 egg whites","GYM"),
            food("Whey Protein",        120, 25, 3,  1.5,  "1 scoop (30g)","GYM"),
            food("Greek Yogurt",        130, 17, 9,  0.5,  "170g",        "GYM"),
            food("Almonds",             170, 6,  6,  15,   "28g",         "GYM"),
            food("Walnuts",             185, 4,  4,  18,   "28g",         "GYM"),
            food("Gym Banana",          105, 1,  27, 0,    "1 medium",    "GYM"),
            food("Sweet Potato",        103, 2.3, 24, 0.1, "1 medium",    "GYM"),
            food("Brown Rice",          215, 5,  45, 1.8,  "1 cup cooked","GYM"),
            food("Quinoa",              220, 8,  39, 3.5,  "1 cup cooked","GYM"),
            food("Chickpeas (Boiled)",  270, 15, 45, 4,    "1 cup",       "GYM"),
            food("Tuna (Canned)",       130, 28, 0,  1,    "100g",        "GYM"),
            food("Salmon",              208, 20, 0,  13,   "100g",        "GYM"),
            food("Milk (Full Fat)",     120, 8,  12, 5,    "1 glass (250 ml)", "GYM"),
            food("Paneer Tikka",        280, 18, 6,  20,   "6 pieces",    "GYM"),
            food("Protein Shake",       150, 25, 8,  2,    "1 shake",     "GYM"),
            food("Peanut Butter Toast", 250, 10, 28, 12,   "2 slices",    "GYM")
        ));

        foodItemRepo.saveAll(foods);
    }

    private FoodItem food(String name, double cal, double protein, double carbs, double fat,
                          String serving, String category) {
        return FoodItem.builder()
            .name(name).calories(cal).proteinG(protein).carbsG(carbs).fatG(fat)
            .servingSize(serving).isCustom(false).foodCategory(category).build();
    }

    @SuppressWarnings("unused")
    private void seedMessMenus(List<FoodItem> foods) {
        // No-op: replaced by category-tagged food items
    }
}
