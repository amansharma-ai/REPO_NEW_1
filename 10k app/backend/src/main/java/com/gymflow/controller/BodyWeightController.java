package com.gymflow.controller;

import com.gymflow.dto.request.BodyWeightRequest;
import com.gymflow.dto.response.BodyWeightResponse;
import com.gymflow.service.BodyWeightService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/body-weight")
@RequiredArgsConstructor
public class BodyWeightController {

    private final BodyWeightService bodyWeightService;

    @PostMapping
    public ResponseEntity<BodyWeightResponse> logWeight(@Valid @RequestBody BodyWeightRequest request) {
        return ResponseEntity.ok(bodyWeightService.logWeight(request));
    }

    @GetMapping("/history")
    public List<BodyWeightResponse> getHistory(@RequestParam(defaultValue = "30") int days) {
        return bodyWeightService.getHistory(days);
    }

    @GetMapping("/latest")
    public ResponseEntity<BodyWeightResponse> getLatest() {
        BodyWeightResponse latest = bodyWeightService.getLatest();
        if (latest == null) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(latest);
    }
}
