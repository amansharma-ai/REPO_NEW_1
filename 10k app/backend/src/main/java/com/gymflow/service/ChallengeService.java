package com.gymflow.service;

import com.gymflow.dto.response.DailyChallengeResponse;
import com.gymflow.model.*;
import com.gymflow.model.enums.ChallengeType;
import com.gymflow.model.enums.ExerciseType;
import com.gymflow.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChallengeService {

    private final DailyChallengeRepository challengeRepo;
    private final WorkoutSetRepository workoutSetRepo;
    private final ExerciseRepository exerciseRepo;

    public List<DailyChallengeResponse> getTodayChallenges() {
        LocalDate today = LocalDate.now();
        List<DailyChallenge> existing = challengeRepo.findByChallengeDate(today);
        if (existing.isEmpty()) {
            existing = generateChallenges(today);
        }
        return existing.stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public List<DailyChallengeResponse> forceRegenerate() {
        LocalDate today = LocalDate.now();
        challengeRepo.deleteByChallengeDate(today);
        List<DailyChallenge> challenges = generateChallenges(today);
        return challenges.stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public DailyChallengeResponse markCompleted(Long id) {
        DailyChallenge challenge = challengeRepo.findById(id)
            .orElseThrow(() -> new RuntimeException("Challenge not found: " + id));
        challenge.setCompleted(true);
        challengeRepo.save(challenge);
        return toResponse(challenge);
    }

    private List<DailyChallenge> generateChallenges(LocalDate date) {
        List<Exercise> allExercises = exerciseRepo.findAll();
        List<DailyChallenge> challenges = new ArrayList<>();

        // Pick exercises that have workout history (up to 5 challenges)
        List<Exercise> exercisesWithHistory = new ArrayList<>();
        Map<Long, List<WorkoutSet>> historyMap = new HashMap<>();

        for (Exercise ex : allExercises) {
            List<WorkoutSet> sets = workoutSetRepo
                .findByExerciseIdOrderByWorkoutWorkoutDateDescSetNumberAsc(ex.getId());
            if (!sets.isEmpty()) {
                exercisesWithHistory.add(ex);
                historyMap.put(ex.getId(), sets);
            }
        }

        // If no history, generate starter challenges for common exercises
        if (exercisesWithHistory.isEmpty()) {
            List<Exercise> starters = allExercises.stream()
                .filter(e -> e.getExerciseType() == ExerciseType.WEIGHT)
                .limit(3)
                .collect(Collectors.toList());
            for (Exercise ex : starters) {
                challenges.add(DailyChallenge.builder()
                    .challengeDate(date).exercise(ex)
                    .challengeType(ChallengeType.MORE_REPS)
                    .suggestedWeight(20).suggestedReps(10).suggestedSets(3)
                    .reason("Start your journey! Try " + ex.getName() + " today.")
                    .completed(false).build());
            }
            return challengeRepo.saveAll(challenges);
        }

        // Shuffle and pick up to 5
        Collections.shuffle(exercisesWithHistory);
        int count = Math.min(5, exercisesWithHistory.size());

        for (int i = 0; i < count; i++) {
            Exercise ex = exercisesWithHistory.get(i);
            List<WorkoutSet> allSets = historyMap.get(ex.getId());
            DailyChallenge challenge = analyzeAndCreateChallenge(date, ex, allSets);
            challenges.add(challenge);
        }

        return challengeRepo.saveAll(challenges);
    }

    private DailyChallenge analyzeAndCreateChallenge(LocalDate date, Exercise exercise, List<WorkoutSet> allSets) {
        // Group sets by workout date (last 5 sessions)
        Map<LocalDate, List<WorkoutSet>> byDate = allSets.stream()
            .collect(Collectors.groupingBy(s -> s.getWorkout().getWorkoutDate(),
                LinkedHashMap::new, Collectors.toList()));

        List<Map.Entry<LocalDate, List<WorkoutSet>>> sessions = new ArrayList<>(byDate.entrySet());
        int sessionCount = Math.min(5, sessions.size());
        sessions = sessions.subList(0, sessionCount);

        // Extract metrics from each session
        List<Double> maxWeights = new ArrayList<>();
        List<Integer> maxReps = new ArrayList<>();
        List<Integer> totalSets = new ArrayList<>();
        List<Double> volumes = new ArrayList<>();

        for (var entry : sessions) {
            double mw = entry.getValue().stream().mapToDouble(WorkoutSet::getWeightKg).max().orElse(0);
            int mr = entry.getValue().stream().mapToInt(WorkoutSet::getReps).max().orElse(0);
            int ts = entry.getValue().size();
            double vol = entry.getValue().stream().mapToDouble(s -> s.getWeightKg() * s.getReps()).sum();
            maxWeights.add(mw);
            maxReps.add(mr);
            totalSets.add(ts);
            volumes.add(vol);
        }

        double lastWeight = maxWeights.isEmpty() ? 0 : maxWeights.get(0);
        int lastReps = maxReps.isEmpty() ? 0 : maxReps.get(0);
        int lastSets = totalSets.isEmpty() ? 0 : totalSets.get(0);

        // Detect patterns
        boolean plateau = isPlateaued(maxWeights, maxReps);
        int plateauLength = getPlateauLength(maxWeights, maxReps);
        boolean overtraining = isOvertraining(volumes);

        ChallengeType type;
        double sugWeight = lastWeight;
        int sugReps = lastReps;
        int sugSets = lastSets;
        String reason;

        if (overtraining) {
            // DELOAD: reduce weight by 15%, reduce sets by 1
            type = ChallengeType.DELOAD;
            sugWeight = Math.round(lastWeight * 0.85 * 2) / 2.0;
            sugSets = Math.max(2, lastSets - 1);
            reason = "Volume has been dropping. Take a deload day — reduce weight to " +
                     sugWeight + "kg and do " + sugSets + " sets.";
        } else if (plateau && plateauLength >= 5) {
            // Long plateau: deload 10%
            type = ChallengeType.DELOAD;
            sugWeight = Math.round(lastWeight * 0.90 * 2) / 2.0;
            reason = "Stuck for " + plateauLength + " sessions. Deload to " + sugWeight +
                     "kg to reset and come back stronger.";
        } else if (plateau && lastReps < 8) {
            // Plateau with low reps: add reps
            type = ChallengeType.MORE_REPS;
            sugReps = lastReps + 2;
            reason = "Plateaued at " + lastReps + " reps. Push for " + sugReps +
                     " reps at " + lastWeight + "kg.";
        } else if (plateau && lastSets < 5) {
            // Plateau with low sets: add set
            type = ChallengeType.MORE_SETS;
            sugSets = lastSets + 1;
            reason = "Same weight and reps for " + plateauLength + " sessions. Add an extra set (" +
                     sugSets + " total) to increase volume.";
        } else if (plateau) {
            // Plateau: try more weight
            type = ChallengeType.MORE_WEIGHT;
            sugWeight = lastWeight + 2.5;
            reason = "Time to break the plateau! Try " + sugWeight + "kg (up from " +
                     lastWeight + "kg).";
        } else if (lastReps >= 12) {
            // Normal progression: strong reps, increase weight
            type = ChallengeType.MORE_WEIGHT;
            sugWeight = lastWeight + 2.5;
            sugReps = 8;
            reason = "You hit " + lastReps + " reps! Time to go heavier — " +
                     sugWeight + "kg for 8 reps.";
        } else {
            // Normal: add 1 rep
            type = ChallengeType.MORE_REPS;
            sugReps = lastReps + 1;
            reason = "Keep pushing! Aim for " + sugReps + " reps at " +
                     lastWeight + "kg.";
        }

        return DailyChallenge.builder()
            .challengeDate(date).exercise(exercise).challengeType(type)
            .suggestedWeight(sugWeight).suggestedReps(sugReps).suggestedSets(sugSets)
            .reason(reason).completed(false).build();
    }

    private boolean isPlateaued(List<Double> weights, List<Integer> reps) {
        if (weights.size() < 3) return false;
        double w0 = weights.get(0);
        int r0 = reps.get(0);
        int streak = 0;
        for (int i = 1; i < weights.size(); i++) {
            if (Math.abs(weights.get(i) - w0) < 0.1 && reps.get(i) == r0) {
                streak++;
            }
        }
        return streak >= 2; // Same for 3+ sessions
    }

    private int getPlateauLength(List<Double> weights, List<Integer> reps) {
        if (weights.isEmpty()) return 0;
        double w0 = weights.get(0);
        int r0 = reps.get(0);
        int length = 1;
        for (int i = 1; i < weights.size(); i++) {
            if (Math.abs(weights.get(i) - w0) < 0.1 && reps.get(i) == r0) {
                length++;
            } else break;
        }
        return length;
    }

    private boolean isOvertraining(List<Double> volumes) {
        if (volumes.size() < 3) return false;
        int drops = 0;
        for (int i = 1; i < volumes.size(); i++) {
            if (volumes.get(i - 1) < volumes.get(i)) drops++;
        }
        return drops >= 2;
    }

    private DailyChallengeResponse toResponse(DailyChallenge c) {
        return DailyChallengeResponse.builder()
            .id(c.getId()).challengeDate(c.getChallengeDate())
            .exerciseId(c.getExercise().getId())
            .exerciseName(c.getExercise().getName())
            .muscleGroup(c.getExercise().getMuscleGroup().name())
            .challengeType(c.getChallengeType())
            .suggestedWeight(c.getSuggestedWeight())
            .suggestedReps(c.getSuggestedReps())
            .suggestedSets(c.getSuggestedSets())
            .reason(c.getReason()).completed(c.isCompleted())
            .build();
    }
}
