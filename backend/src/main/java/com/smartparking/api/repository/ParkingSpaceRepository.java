
package com.smartparking.api.repository;

import com.smartparking.api.model.ParkingSpace;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ParkingSpaceRepository
        extends JpaRepository<ParkingSpace, Long> {
}
