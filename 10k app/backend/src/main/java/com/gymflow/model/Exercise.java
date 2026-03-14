package com.gymflow.model;

import com.gymflow.model.enums.ExerciseType;
import com.gymflow.model.enums.MuscleGroup;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "exercise")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Exercise {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ExerciseType exerciseType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MuscleGroup muscleGroup;
}
