package com.smartparking.api.controller;

import com.smartparking.api.dto.CreateReservationRequest;
import com.smartparking.api.model.Reservation;
import com.smartparking.api.service.ReservationService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PatchMapping;

import java.util.List;

@RestController
@RequestMapping("/api/reservas")
public class ReservationController {

    private final ReservationService reservationService;

    public ReservationController(ReservationService reservationService) {
        this.reservationService = reservationService;
    }

    @PostMapping
    public ResponseEntity<Reservation> createReservation(
            @Valid @RequestBody CreateReservationRequest request) {

        Reservation reservation =
                reservationService.createReservation(request);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(reservation);
    }

    @GetMapping("/usuario/{userId}")
    public List<Reservation> getReservationsByUserId(
            @PathVariable Long userId) {
        return reservationService.getReservationsByUserId(userId);
    }

    @PatchMapping("/{reservationId}/cancelar")
    public ResponseEntity<Reservation> cancelReservation(
            @PathVariable Long reservationId) {

        Reservation reservation = reservationService.cancelReservation(reservationId);

        return ResponseEntity.ok(reservation);
    }
}