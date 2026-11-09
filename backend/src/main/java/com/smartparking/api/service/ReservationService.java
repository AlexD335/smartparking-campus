package com.smartparking.api.service;

import com.smartparking.api.dto.CreateReservationRequest;
import com.smartparking.api.model.ParkingSpace;
import com.smartparking.api.model.Reservation;
import com.smartparking.api.repository.ParkingSpaceRepository;
import com.smartparking.api.repository.ReservationRepository;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.List;
import java.time.LocalDate;
import java.util.stream.Collectors;

@Service
public class ReservationService {

        private final ReservationRepository reservationRepository;
        private final ParkingSpaceRepository parkingSpaceRepository;

        public ReservationService(
                        ReservationRepository reservationRepository,
                        ParkingSpaceRepository parkingSpaceRepository) {
                this.reservationRepository = reservationRepository;
                this.parkingSpaceRepository = parkingSpaceRepository;
        }

        @Transactional
        public Reservation createReservation(CreateReservationRequest request) {

                LocalTime startTime = request.reservationTime();
                LocalTime endTime = request.reservationEndTime();

                validateTimeRange(startTime, endTime);

                // Validar que la reserva esté en el futuro.
                LocalDateTime reservationDateTime = LocalDateTime.of(
                                request.reservationDate(),
                                startTime);

                LocalDateTime now = LocalDateTime.now(
                                ZoneId.of("America/Bogota"));

                if (reservationDateTime.isBefore(now)) {
                        throw new ResponseStatusException(
                                        HttpStatus.BAD_REQUEST,
                                        "La fecha y hora de la reserva deben estar en el futuro");
                }

                // Bloquear la plaza para evitar reservas simultáneas.
                ParkingSpace parkingSpace = parkingSpaceRepository
                                .findByIdForUpdate(request.parkingSpaceId())
                                .orElseThrow(() -> new ResponseStatusException(
                                                HttpStatus.NOT_FOUND,
                                                "No se encontró la plaza"));

                if (!parkingSpace.isAvailable()) {
                        throw new ResponseStatusException(
                                        HttpStatus.CONFLICT,
                                        "La plaza está deshabilitada para reservas");
                }

                // Comprobar si existe una reserva confirmada que se solape.
                boolean overlappingReservation = reservationRepository
                                .existsByParkingSpace_IdAndReservationDateAndStatusAndReservationTimeLessThanAndReservationEndTimeGreaterThan(
                                                request.parkingSpaceId(),
                                                request.reservationDate(),
                                                Reservation.Status.CONFIRMED,
                                                endTime,
                                                startTime);

                if (overlappingReservation) {
                        throw new ResponseStatusException(
                                        HttpStatus.CONFLICT,
                                        "La plaza ya está reservada durante ese intervalo");
                }

                // Crear la reserva.
                Reservation reservation = new Reservation();
                reservation.setUserId(request.userId());
                reservation.setParkingSpace(parkingSpace);
                reservation.setReservationDate(request.reservationDate());
                reservation.setReservationTime(startTime);
                reservation.setReservationEndTime(endTime);
                reservation.setStatus(Reservation.Status.CONFIRMED);

                Reservation savedReservation = reservationRepository.save(reservation);

                return reservationRepository
                                .findWithParkingSpaceById(savedReservation.getId())
                                .orElseThrow(() -> new ResponseStatusException(
                                                HttpStatus.NOT_FOUND,
                                                "No se encontró la reserva"));
        }

        @Transactional(readOnly = true)
        public List<Reservation> getAllReservations() {
                return reservationRepository.findAll();
        }

        @Transactional(readOnly = true)
        public List<Reservation> getReservationsByUserId(Long userId) {
                return reservationRepository.findByUserId(userId);
        }

        @Transactional
        public Reservation cancelReservation(Long reservationId) {

                Reservation reservation = reservationRepository
                                .findWithParkingSpaceById(reservationId)
                                .orElseThrow(() -> new ResponseStatusException(
                                                HttpStatus.NOT_FOUND,
                                                "No se encontró la reserva"));

                if (reservation.getStatus() == Reservation.Status.CANCELLED) {
                        return reservation;
                }

                // Solo se cancela la reserva.
                // La disponibilidad se calcula a partir de los intervalos.
                reservation.setStatus(Reservation.Status.CANCELLED);

                return reservationRepository.save(reservation);
        }

        @Transactional(readOnly = true)
        public List<ParkingSpace> getAvailableParkingSpaces(
                        LocalDate date,
                        LocalTime startTime,
                        LocalTime endTime) {

                validateTimeRange(startTime, endTime);

                return parkingSpaceRepository.findAll()
                                .stream()
                                .filter(ParkingSpace::isAvailable)
                                .filter(parkingSpace -> !reservationRepository
                                                .existsByParkingSpace_IdAndReservationDateAndStatusAndReservationTimeLessThanAndReservationEndTimeGreaterThan(
                                                                parkingSpace.getId(),
                                                                date,
                                                                Reservation.Status.CONFIRMED,
                                                                endTime,
                                                                startTime))
                                .collect(Collectors.toList());
        }

        private void validateTimeRange(LocalTime startTime, LocalTime endTime) {
                if (startTime == null || endTime == null || !endTime.isAfter(startTime)) {
                        throw new ResponseStatusException(
                                        HttpStatus.BAD_REQUEST,
                                        "La hora de finalización debe ser posterior a la hora de inicio");
                }

                if (Duration.between(startTime, endTime).compareTo(Duration.ofHours(1)) < 0) {
                        throw new ResponseStatusException(
                                        HttpStatus.BAD_REQUEST,
                                        "La duración mínima de una reserva es de una hora");
                }

                if (endTime.isAfter(LocalTime.of(23, 59))) {
                        throw new ResponseStatusException(
                                        HttpStatus.BAD_REQUEST,
                                        "La reserva debe finalizar antes de la medianoche");
                }
        }

}