package com.gymflow.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "body_weight")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BodyWeight {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private LocalDate date;

    @Column(nullable = false)
    private double weightKg;
}
