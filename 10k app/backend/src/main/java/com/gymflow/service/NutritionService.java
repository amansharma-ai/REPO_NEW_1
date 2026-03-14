package com.gymflow.service;

import com.gymflow.dto.request.CustomFoodItemRequest;
import com.gymflow.dto.request.NutritionGoalRequest;
import com.gymflow.dto.request.NutritionLogRequest;
import com.gymflow.dto.response.DailySummaryResponse;
import com.gymflow.dto.response.DailySummaryResponse.*;
import com.gymflow.dto.response.MessMenuResponse;
import com.gymflow.dto.response.NutritionGoalResponse;
import com.gymflow.dto.response.WeeklyNutritionResponse;
import com.gymflow.model.*;
import com.gymflow.model.enums.MealType;
import com.gymflow.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NutritionService {

    private final FoodItemRepository foodItemRepo;
    private final MessMenuRepository messMenuRepo;
    private final NutritionLogRepository nutritionLogRepo;
    private final NutritionGoalRepository nutritionGoalRepo;

    public List<MessMenuResponse> getMenuForDay(String day) {
        List<MessMenu> menus = messMenuRepo.findByDayOfWeekIgnoreCase(day);
        return menus.stream().map(this::toMenuResponse).collect(Collectors.toList());
    }

    public List<MessMenuResponse> getTodayMenu() {
        String today = LocalDate.now().getDayOfWeek().name();
        return getMenuForDay(today);
    }

    public NutritionLog logFood(NutritionLogRequest req) {
        FoodItem food = foodItemRepo.findById(req.getFoodItemId())
            .orElseThrow(() -> new RuntimeException("Food item not found: " + req.getFoodItemId()));
        NutritionLog log = NutritionLog.builder()
            .logDate(req.getLogDate())
            .mealType(req.getMealType())
            .foodItem(food)
            .servings(req.getServings())
            .build();
        return nutritionLogRepo.save(log);
    }

    public void deleteLog(Long id) {
        nutritionLogRepo.deleteById(id);
    }

    public DailySummaryResponse getDailySummary(LocalDate date) {
        List<NutritionLog> logs = nutritionLogRepo.findByLogDate(date);
        NutritionGoal goal = getOrCreateDefaultGoal();

        Map<MealType, List<NutritionLog>> byMeal = logs.stream()
            .collect(Collectors.groupingBy(NutritionLog::getMealType));

        double totalCal = 0, totalP = 0, totalC = 0, totalF = 0;
        List<MealSummaryResponse> meals = new ArrayList<>();

        for (MealType type : MealType.values()) {
            List<NutritionLog> mealLogs = byMeal.getOrDefault(type, List.of());
            double mc = 0, mp = 0, mca = 0, mf = 0;
            List<LogEntry> entries = new ArrayList<>();
            for (NutritionLog log : mealLogs) {
                FoodItem fi = log.getFoodItem();
                double s = log.getServings();
                double c = fi.getCalories() * s;
                double p = fi.getProteinG() * s;
                double ca = fi.getCarbsG() * s;
                double f = fi.getFatG() * s;
                mc += c; mp += p; mca += ca; mf += f;
                entries.add(LogEntry.builder()
                    .logId(log.getId()).foodItemId(fi.getId()).foodName(fi.getName())
                    .servings(s).calories(c).protein(p).carbs(ca).fat(f).build());
            }
            totalCal += mc; totalP += mp; totalC += mca; totalF += mf;
            meals.add(MealSummaryResponse.builder()
                .mealType(type).calories(mc).protein(mp).carbs(mca).fat(mf).items(entries).build());
        }

        return DailySummaryResponse.builder()
            .date(date).totalCalories(totalCal).totalProtein(totalP)
            .totalCarbs(totalC).totalFat(totalF)
            .goalCalories(goal.getGoalCalories()).goalProtein(goal.getGoalProtein())
            .goalCarbs(goal.getGoalCarbs()).goalFat(goal.getGoalFat())
            .meals(meals).build();
    }

    public NutritionGoalResponse getGoal() {
        NutritionGoal goal = getOrCreateDefaultGoal();
        return NutritionGoalResponse.builder()
            .goalCalories(goal.getGoalCalories())
            .goalProtein(goal.getGoalProtein())
            .goalCarbs(goal.getGoalCarbs())
            .goalFat(goal.getGoalFat())
            .build();
    }

    @Transactional
    public NutritionGoalResponse updateGoal(NutritionGoalRequest req) {
        NutritionGoal goal = nutritionGoalRepo.findFirstBy()
            .orElseGet(() -> NutritionGoal.builder()
                .goalCalories(2200).goalProtein(120).goalCarbs(280).goalFat(70).build());
        goal.setGoalCalories(req.getGoalCalories());
        goal.setGoalProtein(req.getGoalProtein());
        goal.setGoalCarbs(req.getGoalCarbs());
        goal.setGoalFat(req.getGoalFat());
        goal = nutritionGoalRepo.save(goal);
        return NutritionGoalResponse.builder()
            .goalCalories(goal.getGoalCalories())
            .goalProtein(goal.getGoalProtein())
            .goalCarbs(goal.getGoalCarbs())
            .goalFat(goal.getGoalFat())
            .build();
    }

    public List<WeeklyNutritionResponse> getWeeklyHistory(int days) {
        LocalDate today = LocalDate.now();
        LocalDate from = today.minusDays(days - 1);

        List<NutritionLog> allLogs = nutritionLogRepo.findByLogDateBetween(from, today);
        Map<LocalDate, List<NutritionLog>> logsByDate = allLogs.stream()
            .collect(Collectors.groupingBy(NutritionLog::getLogDate));

        List<WeeklyNutritionResponse> result = new ArrayList<>();
        for (int i = 0; i < days; i++) {
            LocalDate date = from.plusDays(i);
            List<NutritionLog> dateLogs = logsByDate.getOrDefault(date, List.of());
            double cal = 0, prot = 0, carbs = 0, fat = 0;
            for (NutritionLog log : dateLogs) {
                FoodItem fi = log.getFoodItem();
                double s = log.getServings();
                cal   += fi.getCalories() * s;
                prot  += fi.getProteinG() * s;
                carbs += fi.getCarbsG()   * s;
                fat   += fi.getFatG()     * s;
            }
            result.add(WeeklyNutritionResponse.builder()
                .date(date)
                .totalCalories(cal)
                .totalProtein(prot)
                .totalCarbs(carbs)
                .totalFat(fat)
                .build());
        }
        return result;
    }

    public FoodItem addCustomFood(CustomFoodItemRequest req) {
        FoodItem food = FoodItem.builder()
            .name(req.getName()).calories(req.getCalories())
            .proteinG(req.getProteinG()).carbsG(req.getCarbsG()).fatG(req.getFatG())
            .servingSize(req.getServingSize()).isCustom(true).build();
        return foodItemRepo.save(food);
    }

    public List<FoodItem> searchFoods(String query) {
        return foodItemRepo.findByNameContainingIgnoreCase(query);
    }

    public List<FoodItem> getFoodsByCategory(String category) {
        return foodItemRepo.findByFoodCategoryIgnoreCase(category);
    }

    private NutritionGoal getOrCreateDefaultGoal() {
        return nutritionGoalRepo.findFirstBy()
            .orElseGet(() -> nutritionGoalRepo.save(
                NutritionGoal.builder()
                    .goalCalories(2200).goalProtein(120).goalCarbs(280).goalFat(70)
                    .build()));
    }

    private MessMenuResponse toMenuResponse(MessMenu menu) {
        List<MessMenuResponse.FoodItemResponse> items = menu.getItems().stream()
            .map(fi -> MessMenuResponse.FoodItemResponse.builder()
                .id(fi.getId()).name(fi.getName()).calories(fi.getCalories())
                .proteinG(fi.getProteinG()).carbsG(fi.getCarbsG()).fatG(fi.getFatG())
                .servingSize(fi.getServingSize()).build())
            .collect(Collectors.toList());
        return MessMenuResponse.builder()
            .dayOfWeek(menu.getDayOfWeek()).mealType(menu.getMealType()).items(items).build();
    }
}
