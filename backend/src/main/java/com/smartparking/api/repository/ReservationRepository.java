package com.smartparking.api.repository;

import com.smartparking.api.model.Reservation;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

public interface ReservationRepository
                extends JpaRepository<Reservation, Long> {

        @EntityGraph(attributePaths = "parkingSpace")
        List<Reservation> findByUserId(Long userId);

        @EntityGraph(attributePaths = "parkingSpace")
        Optional<Reservation> findWithParkingSpaceById(Long id);

        boolean existsByParkingSpace_IdAndReservationDateAndStatusAndReservationTimeLessThanAndReservationEndTimeGreaterThan(
                        Long parkingSpaceId,
                        LocalDate reservationDate,
                        Reservation.Status status,
                        LocalTime requestedEnd,
                        LocalTime requestedStart);
}