package com.gymflow.controller;

import com.gymflow.dto.response.DailyChallengeResponse;
import com.gymflow.service.ChallengeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/challenges")
@RequiredArgsConstructor
public class ChallengeController {

    private final ChallengeService challengeService;

    @GetMapping("/today")
    public List<DailyChallengeResponse> getTodayChallenges() {
        return challengeService.getTodayChallenges();
    }

    @PostMapping("/generate")
    public List<DailyChallengeResponse> forceRegenerate() {
        return challengeService.forceRegenerate();
    }

    @PutMapping("/{id}/complete")
    public ResponseEntity<DailyChallengeResponse> markCompleted(@PathVariable Long id) {
        return ResponseEntity.ok(challengeService.markCompleted(id));
    }
}
