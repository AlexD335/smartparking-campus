package com.smartparking.api.controller;

import com.smartparking.api.dto.CreateReservationRequest;
import com.smartparking.api.model.Reservation;
import com.smartparking.api.service.ReservationService;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.server.ResponseStatusException;

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
            @Valid @RequestBody CreateReservationRequest request,
            @AuthenticationPrincipal Jwt jwt) {

        Long authenticatedUserId = getAuthenticatedUserId(jwt);

        if (!authenticatedUserId.equals(request.userId())) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "No puedes crear reservas para otro usuario");
        }

        Reservation reservation =
                reservationService.createReservation(request);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(reservation);
    }

    @GetMapping("/usuario/{userId}")
    public List<Reservation> getReservationsByUserId(
            @PathVariable Long userId,
            @AuthenticationPrincipal Jwt jwt) {

        Long authenticatedUserId = getAuthenticatedUserId(jwt);

        if (!authenticatedUserId.equals(userId)) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "No puedes consultar las reservas de otro usuario");
        }

        return reservationService.getReservationsByUserId(
                authenticatedUserId);
    }

    @PatchMapping("/{reservationId}/cancelar")
    public ResponseEntity<Reservation> cancelReservation(
            @PathVariable Long reservationId,
            @AuthenticationPrincipal Jwt jwt) {

        Long authenticatedUserId = getAuthenticatedUserId(jwt);

        boolean belongsToUser = reservationService
                .getReservationsByUserId(authenticatedUserId)
                .stream()
                .anyMatch(reservation ->
                        reservation.getId().equals(reservationId));

        if (!belongsToUser) {
            throw new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "No se encontró la reserva para este usuario");
        }

        Reservation reservation =
                reservationService.cancelReservation(reservationId);

        return ResponseEntity.ok(reservation);
    }

    private Long getAuthenticatedUserId(Jwt jwt) {
        if (jwt == null) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Se requiere autenticación");
        }

        Object claim = jwt.getClaim("userId");

        if (claim instanceof Number number) {
            return number.longValue();
        }

        throw new ResponseStatusException(
                HttpStatus.UNAUTHORIZED,
                "El token no contiene un identificador de usuario válido");
    }
}
