package com.smartparking.api.controller;

import com.smartparking.api.model.Reservation;
import com.smartparking.api.service.ReservationService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/reservas")
public class AdminReservationController {

    private final ReservationService reservationService;

    public AdminReservationController(
            ReservationService reservationService) {
        this.reservationService = reservationService;
    }

    @GetMapping
    public List<Reservation> getAllReservations() {
        return reservationService.getAllReservations();
    }

    @PatchMapping("/{reservationId}/cancelar")
    public ResponseEntity<Reservation> cancelReservation(
            @PathVariable Long reservationId) {

        Reservation reservation =
                reservationService.cancelReservation(reservationId);

        return ResponseEntity.ok(reservation);
    }
}
