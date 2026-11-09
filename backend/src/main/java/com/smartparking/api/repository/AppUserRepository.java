package com.smartparking.api.repository;

import com.smartparking.api.model.AppUser;

import jakarta.persistence.LockModeType;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface AppUserRepository extends JpaRepository<AppUser, Long> {

    Optional<AppUser> findByEmail(String email);

    boolean existsByEmail(String email);

    boolean existsByDocumentTypeAndDocumentNumber(
            String documentType,
            String documentNumber);

    boolean existsByDocumentTypeAndDocumentNumberAndIdNot(
            String documentType,
            String documentNumber,
            Long id);

    // Bloquea todos los usuarios para serializar los cambios de roles.
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT u FROM AppUser u ORDER BY u.id")
    List<AppUser> findAllForUpdate();
}
