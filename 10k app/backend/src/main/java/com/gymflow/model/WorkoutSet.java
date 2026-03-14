package com.gymflow.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "workout_set")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class WorkoutSet {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "workout_id", nullable = false)
    private Workout workout;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "exercise_id", nullable = false)
    private Exercise exercise;

    private int setNumber;
    private int reps;
    private double weightKg;
    private Integer durationSeconds;
    private boolean isPR;
    private double estimatedOneRM;
}
