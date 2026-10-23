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
import java.util.List;

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
    public Reservation createReservation(
            CreateReservationRequest request) {

        ParkingSpace parkingSpace = parkingSpaceRepository
                .findById(request.parkingSpaceId())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Parking space not found"));

        if (!parkingSpace.isAvailable()) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Parking space is not available");
        }

        Reservation reservation = new Reservation();
        reservation.setUserId(request.userId());
        reservation.setParkingSpace(parkingSpace);
        reservation.setReservationDate(request.reservationDate());
        reservation.setReservationTime(request.reservationTime());
        reservation.setStatus(Reservation.Status.CONFIRMED);

        parkingSpace.setAvailable(false);
        parkingSpaceRepository.save(parkingSpace);

        return reservationRepository.save(reservation);
    }

    @Transactional(readOnly = true)
    public List<Reservation> getReservationsByUserId(Long userId) {
        return reservationRepository.findByUserId(userId);
    }


    @Transactional
    public Reservation cancelReservation(Long reservationId) {

        Reservation reservation = reservationRepository
                .findById(reservationId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Reservation not found"));

        if (reservation.getStatus() == Reservation.Status.CANCELLED) {
            return reservation;
        }

        ParkingSpace parkingSpace = reservation.getParkingSpace();
        parkingSpace.setAvailable(true);

        parkingSpaceRepository.save(parkingSpace);

        reservation.setStatus(Reservation.Status.CANCELLED);

        return reservationRepository.save(reservation);
    }
}