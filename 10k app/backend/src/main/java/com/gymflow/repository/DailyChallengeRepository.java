package com.gymflow.repository;

import com.gymflow.model.DailyChallenge;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;

public interface DailyChallengeRepository extends JpaRepository<DailyChallenge, Long> {
    List<DailyChallenge> findByChallengeDate(LocalDate challengeDate);
    void deleteByChallengeDate(LocalDate challengeDate);
}
