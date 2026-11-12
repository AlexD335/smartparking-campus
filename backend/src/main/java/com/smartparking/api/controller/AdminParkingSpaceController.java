package com.smartparking.api.controller;

import com.smartparking.api.dto.CreateParkingSpaceRequest;
import com.smartparking.api.model.ParkingSpace;
import com.smartparking.api.repository.ParkingSpaceRepository;
import com.smartparking.api.repository.ReservationRepository;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/plazas")
public class AdminParkingSpaceController {

    private final ParkingSpaceRepository parkingSpaceRepository;
    private final ReservationRepository reservationRepository;

    public AdminParkingSpaceController(
            ParkingSpaceRepository parkingSpaceRepository,
            ReservationRepository reservationRepository) {
        this.parkingSpaceRepository = parkingSpaceRepository;
        this.reservationRepository = reservationRepository;
    }

    @PostMapping
    public ResponseEntity<?> createParkingSpace(
            @RequestBody CreateParkingSpaceRequest request) {

        if (request.code() == null || request.code().isBlank()
                || request.zone() == null || request.zone().isBlank()
                || request.location() == null || request.location().isBlank()) {
            return ResponseEntity.badRequest()
                    .body("Todos los campos son obligatorios.");
        }

        String code = request.code().trim().toUpperCase();
        String zone = request.zone().trim();
        String location = request.location().trim();

        if (code.length() > 20 || zone.length() > 50
                || location.length() > 150) {
            return ResponseEntity.badRequest()
                    .body("Uno o más campos superan la longitud permitida.");
        }

        if (parkingSpaceRepository.existsByCodeIgnoreCase(code)) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body("Ya existe una plaza con ese código.");
        }

        ParkingSpace space = new ParkingSpace();
        space.setCode(code);
        space.setZone(zone);
        space.setLocation(location);
        space.setAvailable(true);

        ParkingSpace saved = parkingSpaceRepository.save(space);

        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteParkingSpace(@PathVariable Long id) {
        var optionalSpace = parkingSpaceRepository.findById(id);
        if (optionalSpace.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        if (reservationRepository.existsByParkingSpace_Id(id)) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body("No se puede eliminar la plaza porque tiene reservas asociadas.");
        }

        parkingSpaceRepository.delete(optionalSpace.get());
        return ResponseEntity.noContent().build();
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
