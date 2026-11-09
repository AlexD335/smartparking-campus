package com.smartparking.api.repository;

import com.smartparking.api.model.ParkingSpace;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface ParkingSpaceRepository
                extends JpaRepository<ParkingSpace, Long> {

        @Lock(LockModeType.PESSIMISTIC_WRITE)
        @Query("SELECT p FROM ParkingSpace p WHERE p.id = :id")
        Optional<ParkingSpace> findByIdForUpdate(@Param("id") Long id);
}
