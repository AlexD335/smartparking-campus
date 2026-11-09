package com.smartparking.api.controller;

import com.smartparking.api.model.ParkingSpace;
import com.smartparking.api.repository.ParkingSpaceRepository;
import com.smartparking.api.service.ReservationService;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@RestController
@RequestMapping("/api/plazas")
public class ParkingSpaceController {

    private final ParkingSpaceRepository parkingSpaceRepository;
    private final ReservationService reservationService;

    public ParkingSpaceController(
            ParkingSpaceRepository parkingSpaceRepository,
            ReservationService reservationService) {
        this.parkingSpaceRepository = parkingSpaceRepository;
        this.reservationService = reservationService;
    }

    @GetMapping
    public List<ParkingSpace> getAllParkingSpaces() {
        return parkingSpaceRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ParkingSpace> getParkingSpaceById(
            @PathVariable Long id) {
        return parkingSpaceRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/disponibles")
    public List<ParkingSpace> getAvailableParkingSpaces(
            @RequestParam
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate fecha,

            @RequestParam
            @DateTimeFormat(iso = DateTimeFormat.ISO.TIME)
            LocalTime horaInicio,

            @RequestParam
            @DateTimeFormat(iso = DateTimeFormat.ISO.TIME)
            LocalTime horaFin) {

        return reservationService.getAvailableParkingSpaces(
                fecha,
                horaInicio,
                horaFin);
    }
}