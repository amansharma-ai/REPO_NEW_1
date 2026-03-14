package com.gymflow.service;

import com.gymflow.dto.request.BodyWeightRequest;
import com.gymflow.dto.response.BodyWeightResponse;
import com.gymflow.model.BodyWeight;
import com.gymflow.repository.BodyWeightRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BodyWeightService {

    private final BodyWeightRepository bodyWeightRepo;

    @Transactional
    public BodyWeightResponse logWeight(BodyWeightRequest req) {
        BodyWeight entry = bodyWeightRepo.findByDate(req.getDate())
            .orElseGet(() -> BodyWeight.builder().date(req.getDate()).build());
        entry.setWeightKg(req.getWeightKg());
        entry = bodyWeightRepo.save(entry);
        return toResponse(entry);
    }

    public List<BodyWeightResponse> getHistory(int days) {
        LocalDate to = LocalDate.now();
        LocalDate from = to.minusDays(days);
        return bodyWeightRepo.findByDateBetweenOrderByDateAsc(from, to).stream()
            .map(this::toResponse)
            .collect(Collectors.toList());
    }

    public BodyWeightResponse getLatest() {
        return bodyWeightRepo.findTopByOrderByDateDesc()
            .map(this::toResponse)
            .orElse(null);
    }

    private BodyWeightResponse toResponse(BodyWeight bw) {
        return BodyWeightResponse.builder()
            .id(bw.getId())
            .date(bw.getDate())
            .weightKg(bw.getWeightKg())
            .build();
    }
}
