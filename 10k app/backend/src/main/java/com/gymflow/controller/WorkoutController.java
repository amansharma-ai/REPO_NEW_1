package com.gymflow.controller;

import com.gymflow.dto.request.WorkoutRequest;
import com.gymflow.dto.response.ExerciseHistoryResponse;
import com.gymflow.dto.response.ExerciseProgressResponse;
import com.gymflow.dto.response.WeeklyVolumeResponse;
import com.gymflow.dto.response.WorkoutResponse;
import com.gymflow.dto.response.WorkoutStatsResponse;
import com.gymflow.service.WorkoutService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/workouts")
@RequiredArgsConstructor
public class WorkoutController {

    private final WorkoutService workoutService;

    @PostMapping
    public ResponseEntity<WorkoutResponse> createWorkout(@Valid @RequestBody WorkoutRequest request) {
        return ResponseEntity.ok(workoutService.createWorkout(request));
    }

    @GetMapping
    public List<WorkoutResponse> getWorkouts(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return workoutService.getWorkoutsByDate(date);
    }

    @GetMapping("/history")
    public List<WorkoutResponse> getHistory(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return workoutService.getWorkoutHistory(from, to);
    }

    @GetMapping("/exercises/{id}/history")
    public ExerciseHistoryResponse getExerciseHistory(@PathVariable Long id) {
        return workoutService.getExerciseHistory(id);
    }

    @GetMapping("/exercises/{id}/best")
    public ResponseEntity<java.util.Map<String, Object>> getExerciseBestSet(@PathVariable Long id) {
        return ResponseEntity.ok(workoutService.getExerciseBestSet(id));
    }

    @GetMapping("/exercises/{id}/progress")
    public ResponseEntity<ExerciseProgressResponse> getExerciseProgress(@PathVariable Long id) {
        return ResponseEntity.ok(workoutService.getExerciseProgress(id));
    }

    @GetMapping("/stats")
    public ResponseEntity<WorkoutStatsResponse> getWorkoutStats() {
        return ResponseEntity.ok(workoutService.getWorkoutStats());
    }

    @GetMapping("/volume/weekly")
    public ResponseEntity<WeeklyVolumeResponse> getWeeklyVolume(
            @RequestParam(defaultValue = "8") int weeks) {
        return ResponseEntity.ok(workoutService.getWeeklyVolume(weeks));
    }

    @PutMapping("/{id}")
    public ResponseEntity<WorkoutResponse> updateWorkout(
            @PathVariable Long id, @Valid @RequestBody WorkoutRequest request) {
        return ResponseEntity.ok(workoutService.updateWorkout(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteWorkout(@PathVariable Long id) {
        workoutService.deleteWorkout(id);
        return ResponseEntity.noContent().build();
    }
}
