package com.gymflow.service;

import com.gymflow.dto.request.WorkoutRequest;
import com.gymflow.dto.request.WorkoutSetRequest;
import com.gymflow.dto.response.ExerciseHistoryResponse;
import com.gymflow.dto.response.ExerciseHistoryResponse.*;
import com.gymflow.dto.response.ExerciseProgressResponse;
import com.gymflow.dto.response.ExerciseProgressResponse.DataPoint;
import com.gymflow.dto.response.WeeklyVolumeResponse;
import com.gymflow.dto.response.WeeklyVolumeResponse.WeekEntry;
import com.gymflow.dto.response.WorkoutResponse;
import com.gymflow.dto.response.WorkoutSetResponse;
import com.gymflow.dto.response.WorkoutStatsResponse;
import com.gymflow.model.*;
import com.gymflow.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WorkoutService {

    private final WorkoutRepository workoutRepo;
    private final WorkoutSetRepository workoutSetRepo;
    private final ExerciseRepository exerciseRepo;

    @Transactional
    public WorkoutResponse createWorkout(WorkoutRequest req) {
        Workout workout = Workout.builder()
            .workoutDate(req.getWorkoutDate())
            .notes(req.getNotes())
            .build();

        if (req.getSets() != null) {
            for (WorkoutSetRequest sr : req.getSets()) {
                Exercise exercise = exerciseRepo.findById(sr.getExerciseId())
                    .orElseThrow(() -> new RuntimeException("Exercise not found: " + sr.getExerciseId()));

                double estimatedOneRM = sr.getWeightKg() * (1 + sr.getReps() / 30.0);

                List<WorkoutSet> previousSets = workoutSetRepo.findByExerciseId(sr.getExerciseId());
                double maxPreviousOneRM = previousSets.stream()
                    .mapToDouble(WorkoutSet::getEstimatedOneRM)
                    .max()
                    .orElse(0.0);

                boolean isPR = estimatedOneRM > maxPreviousOneRM;

                WorkoutSet set = WorkoutSet.builder()
                    .workout(workout)
                    .exercise(exercise)
                    .setNumber(sr.getSetNumber())
                    .reps(sr.getReps())
                    .weightKg(sr.getWeightKg())
                    .durationSeconds(sr.getDurationSeconds())
                    .estimatedOneRM(estimatedOneRM)
                    .isPR(isPR)
                    .build();
                workout.getSets().add(set);
            }
        }

        workout = workoutRepo.save(workout);
        return toResponse(workout);
    }

    public List<WorkoutResponse> getWorkoutsByDate(LocalDate date) {
        return workoutRepo.findByWorkoutDate(date).stream()
            .map(this::toResponse).collect(Collectors.toList());
    }

    public List<WorkoutResponse> getWorkoutHistory(LocalDate from, LocalDate to) {
        return workoutRepo.findByWorkoutDateBetweenOrderByWorkoutDateDesc(from, to).stream()
            .map(this::toResponse).collect(Collectors.toList());
    }

    public ExerciseHistoryResponse getExerciseHistory(Long exerciseId) {
        Exercise exercise = exerciseRepo.findById(exerciseId)
            .orElseThrow(() -> new RuntimeException("Exercise not found: " + exerciseId));

        List<WorkoutSet> allSets = workoutSetRepo
            .findByExerciseIdOrderByWorkoutWorkoutDateDescSetNumberAsc(exerciseId);

        Map<LocalDate, List<WorkoutSet>> byDate = allSets.stream()
            .collect(Collectors.groupingBy(s -> s.getWorkout().getWorkoutDate(),
                LinkedHashMap::new, Collectors.toList()));

        List<SessionEntry> sessions = new ArrayList<>();
        for (var entry : byDate.entrySet()) {
            List<SetEntry> sets = entry.getValue().stream()
                .map(s -> SetEntry.builder()
                    .setNumber(s.getSetNumber())
                    .reps(s.getReps())
                    .weightKg(s.getWeightKg())
                    .estimatedOneRM(s.getEstimatedOneRM())
                    .isPR(s.isPR())
                    .build())
                .collect(Collectors.toList());
            double totalVolume = entry.getValue().stream()
                .mapToDouble(s -> s.getWeightKg() * s.getReps()).sum();
            sessions.add(SessionEntry.builder()
                .date(entry.getKey()).sets(sets).totalVolume(totalVolume).build());
        }

        WorkoutSet bestSet = allSets.stream()
            .max(Comparator.comparingDouble(WorkoutSet::getEstimatedOneRM))
            .orElse(null);

        return ExerciseHistoryResponse.builder()
            .exerciseId(exerciseId)
            .exerciseName(exercise.getName())
            .sessions(sessions)
            .allTimeBestOneRM(bestSet != null ? bestSet.getEstimatedOneRM() : 0)
            .allTimeBestWeight(bestSet != null ? bestSet.getWeightKg() : 0)
            .allTimeBestReps(bestSet != null ? bestSet.getReps() : 0)
            .build();
    }

    public Map<String, Object> getExerciseBestSet(Long exerciseId) {
        List<WorkoutSet> allSets = workoutSetRepo.findByExerciseId(exerciseId);

        WorkoutSet bestSet = allSets.stream()
            .max(Comparator.comparingDouble(WorkoutSet::getEstimatedOneRM))
            .orElse(null);

        if (bestSet == null) {
            return Map.of("exerciseId", exerciseId, "message", "No sets found");
        }

        return Map.of(
            "exerciseId", exerciseId,
            "bestOneRM", bestSet.getEstimatedOneRM(),
            "bestWeight", bestSet.getWeightKg(),
            "bestReps", bestSet.getReps(),
            "achievedDate", bestSet.getWorkout().getWorkoutDate().toString()
        );
    }

    @Transactional
    public WorkoutResponse updateWorkout(Long id, WorkoutRequest req) {
        Workout workout = workoutRepo.findById(id)
            .orElseThrow(() -> new RuntimeException("Workout not found: " + id));

        workout.setWorkoutDate(req.getWorkoutDate());
        workout.setNotes(req.getNotes());
        workout.getSets().clear();

        if (req.getSets() != null) {
            for (WorkoutSetRequest sr : req.getSets()) {
                Exercise exercise = exerciseRepo.findById(sr.getExerciseId())
                    .orElseThrow(() -> new RuntimeException("Exercise not found: " + sr.getExerciseId()));
                double estimatedOneRM = sr.getWeightKg() * (1 + sr.getReps() / 30.0);
                WorkoutSet set = WorkoutSet.builder()
                    .workout(workout).exercise(exercise)
                    .setNumber(sr.getSetNumber()).reps(sr.getReps())
                    .weightKg(sr.getWeightKg()).durationSeconds(sr.getDurationSeconds())
                    .estimatedOneRM(estimatedOneRM)
                    .build();
                workout.getSets().add(set);
            }
        }

        workout = workoutRepo.save(workout);
        return toResponse(workout);
    }

    @Transactional
    public void deleteWorkout(Long id) {
        workoutRepo.deleteById(id);
    }

    public List<Exercise> getAllExercises(String type, String muscleGroup) {
        if (type != null && muscleGroup != null) {
            return exerciseRepo.findByExerciseTypeAndMuscleGroup(
                com.gymflow.model.enums.ExerciseType.valueOf(type.toUpperCase()),
                com.gymflow.model.enums.MuscleGroup.valueOf(muscleGroup.toUpperCase()));
        } else if (type != null) {
            return exerciseRepo.findByExerciseType(
                com.gymflow.model.enums.ExerciseType.valueOf(type.toUpperCase()));
        } else if (muscleGroup != null) {
            return exerciseRepo.findByMuscleGroup(
                com.gymflow.model.enums.MuscleGroup.valueOf(muscleGroup.toUpperCase()));
        }
        return exerciseRepo.findAll();
    }

    public Exercise addExercise(Exercise exercise) {
        return exerciseRepo.save(exercise);
    }

    public ExerciseProgressResponse getExerciseProgress(Long exerciseId) {
        Exercise exercise = exerciseRepo.findById(exerciseId)
            .orElseThrow(() -> new RuntimeException("Exercise not found: " + exerciseId));

        List<WorkoutSet> allSets = workoutSetRepo
            .findByExerciseIdOrderByWorkoutWorkoutDateDescSetNumberAsc(exerciseId);

        // Per date: keep only the set with highest estimatedOneRM
        Map<LocalDate, WorkoutSet> bestPerDate = new LinkedHashMap<>();
        for (WorkoutSet s : allSets) {
            LocalDate date = s.getWorkout().getWorkoutDate();
            bestPerDate.merge(date, s, (existing, candidate) ->
                candidate.getEstimatedOneRM() > existing.getEstimatedOneRM() ? candidate : existing);
        }

        // Sort ASC by date
        List<DataPoint> dataPoints = bestPerDate.entrySet().stream()
            .sorted(Map.Entry.comparingByKey())
            .map(e -> DataPoint.builder()
                .date(e.getKey())
                .estimatedOneRM(e.getValue().getEstimatedOneRM())
                .weightKg(e.getValue().getWeightKg())
                .reps(e.getValue().getReps())
                .build())
            .collect(Collectors.toList());

        return ExerciseProgressResponse.builder()
            .exerciseId(exerciseId)
            .exerciseName(exercise.getName())
            .dataPoints(dataPoints)
            .build();
    }

    public WorkoutStatsResponse getWorkoutStats() {
        List<Workout> allWorkouts = workoutRepo.findAll();
        long totalWorkouts = allWorkouts.size();
        long totalSets = allWorkouts.stream().mapToLong(w -> w.getSets().size()).sum();
        double totalVolume = allWorkouts.stream()
            .flatMap(w -> w.getSets().stream())
            .mapToDouble(s -> s.getWeightKg() * s.getReps())
            .sum();

        // Get distinct workout dates sorted DESC
        List<LocalDate> sortedDatesDesc = allWorkouts.stream()
            .map(Workout::getWorkoutDate)
            .distinct()
            .sorted(Comparator.reverseOrder())
            .collect(Collectors.toList());

        // Current streak: consecutive days from today (allow yesterday as start)
        int currentStreak = 0;
        LocalDate today = LocalDate.now();
        LocalDate expected = sortedDatesDesc.isEmpty() ? null : sortedDatesDesc.get(0);
        if (expected != null && (expected.equals(today) || expected.equals(today.minusDays(1)))) {
            LocalDate cursor = expected;
            for (LocalDate d : sortedDatesDesc) {
                if (d.equals(cursor)) {
                    currentStreak++;
                    cursor = cursor.minusDays(1);
                } else {
                    break;
                }
            }
        }

        // Longest streak: iterate dates sorted ASC
        List<LocalDate> sortedDatesAsc = new ArrayList<>(sortedDatesDesc);
        Collections.reverse(sortedDatesAsc);
        int longestStreak = 0;
        int runStreak = 0;
        LocalDate prev = null;
        for (LocalDate d : sortedDatesAsc) {
            if (prev == null || d.equals(prev.plusDays(1))) {
                runStreak++;
            } else {
                runStreak = 1;
            }
            longestStreak = Math.max(longestStreak, runStreak);
            prev = d;
        }

        return WorkoutStatsResponse.builder()
            .totalWorkouts(totalWorkouts)
            .totalSets(totalSets)
            .totalVolume(totalVolume)
            .currentStreak(currentStreak)
            .longestStreak(longestStreak)
            .build();
    }

    public WeeklyVolumeResponse getWeeklyVolume(int weeks) {
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MMM d");
        List<WeekEntry> entries = new ArrayList<>();
        LocalDate today = LocalDate.now();

        for (int i = weeks - 1; i >= 0; i--) {
            LocalDate weekStart = today.minusWeeks(i)
                .with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            LocalDate weekEnd = weekStart.plusDays(6);

            List<Workout> weekWorkouts = workoutRepo
                .findByWorkoutDateBetweenOrderByWorkoutDateDesc(weekStart, weekEnd);

            double totalVolume = weekWorkouts.stream()
                .flatMap(w -> w.getSets().stream())
                .mapToDouble(s -> s.getWeightKg() * s.getReps())
                .sum();

            entries.add(WeekEntry.builder()
                .weekLabel(weekStart.format(fmt))
                .totalVolume(totalVolume)
                .build());
        }

        return WeeklyVolumeResponse.builder().weeks(entries).build();
    }

    private WorkoutResponse toResponse(Workout w) {
        List<WorkoutSetResponse> sets = w.getSets().stream()
            .map(s -> WorkoutSetResponse.builder()
                .id(s.getId())
                .exerciseId(s.getExercise().getId())
                .exerciseName(s.getExercise().getName())
                .muscleGroup(s.getExercise().getMuscleGroup().name())
                .setNumber(s.getSetNumber())
                .reps(s.getReps())
                .weightKg(s.getWeightKg())
                .durationSeconds(s.getDurationSeconds())
                .isPR(s.isPR())
                .estimatedOneRM(s.getEstimatedOneRM())
                .volume(s.getWeightKg() * s.getReps())
                .build())
            .collect(Collectors.toList());

        return WorkoutResponse.builder()
            .id(w.getId()).workoutDate(w.getWorkoutDate())
            .notes(w.getNotes()).sets(sets).build();
    }
}
