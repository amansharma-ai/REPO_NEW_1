package com.gymflow.repository;

import com.gymflow.model.BodyWeight;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface BodyWeightRepository extends JpaRepository<BodyWeight, Long> {
    List<BodyWeight> findByDateBetweenOrderByDateAsc(LocalDate from, LocalDate to);
    Optional<BodyWeight> findTopByOrderByDateDesc();
    Optional<BodyWeight> findByDate(LocalDate date);
}
