package com.gymflow.controller;

import com.gymflow.model.Exercise;
import com.gymflow.service.WorkoutService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/exercises")
@RequiredArgsConstructor
public class ExerciseController {

    private final WorkoutService workoutService;

    @GetMapping
    public List<Exercise> getExercises(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String muscleGroup) {
        return workoutService.getAllExercises(type, muscleGroup);
    }

    @PostMapping
    public ResponseEntity<Exercise> addExercise(@RequestBody Exercise exercise) {
        return ResponseEntity.ok(workoutService.addExercise(exercise));
    }
}
