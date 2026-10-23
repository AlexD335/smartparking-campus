package com.smartparking.api.dto;

import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;
import java.time.LocalTime;

public record CreateReservationRequest(
        @NotNull Long userId,
        @NotNull Long parkingSpaceId,
        @NotNull LocalDate reservationDate,
        @NotNull LocalTime reservationTime
) {
}