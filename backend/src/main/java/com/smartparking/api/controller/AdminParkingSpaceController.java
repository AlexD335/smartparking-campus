package com.smartparking.api.controller;

import com.smartparking.api.model.ParkingSpace;
import com.smartparking.api.repository.ParkingSpaceRepository;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/plazas")
public class AdminParkingSpaceController {

    private final ParkingSpaceRepository parkingSpaceRepository;

    public AdminParkingSpaceController(
            ParkingSpaceRepository parkingSpaceRepository) {
        this.parkingSpaceRepository = parkingSpaceRepository;
    }

    @PatchMapping("/{id}/disponibilidad")
    public ResponseEntity<ParkingSpace> updateAvailability(
            @PathVariable Long id,
            @RequestParam boolean available) {

        return parkingSpaceRepository.findById(id)
                .map(space -> {
                    space.setAvailable(available);
                    ParkingSpace updated =
                            parkingSpaceRepository.save(space);
                    return ResponseEntity.ok(updated);
                })
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
