package com.gymflow.model;

import com.gymflow.model.enums.ChallengeType;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "daily_challenge")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class DailyChallenge {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private LocalDate challengeDate;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "exercise_id", nullable = false)
    private Exercise exercise;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ChallengeType challengeType;

    private double suggestedWeight;
    private int suggestedReps;
    private int suggestedSets;

    private String reason;

    @Builder.Default
    private boolean completed = false;
}
