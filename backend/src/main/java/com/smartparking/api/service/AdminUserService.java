package com.smartparking.api.service;

import com.smartparking.api.dto.AdminUpdateUserRequest;
import com.smartparking.api.dto.AdminUserResponse;
import com.smartparking.api.model.AppUser;
import com.smartparking.api.model.AppUser.Role;
import com.smartparking.api.repository.AppUserRepository;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class AdminUserService {

    private final AppUserRepository repository;

    public AdminUserService(AppUserRepository repository) {
        this.repository = repository;
    }

    @Transactional(readOnly = true)
    public List<AdminUserResponse> getAllUsers() {
        return repository.findAll()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public AdminUserResponse getUser(Long id) {
        return toResponse(findUser(id));
    }

    @Transactional
    public AdminUserResponse updateUser(
            Long id,
            AdminUpdateUserRequest request) {

        AppUser user = findUser(id);

        String email = request.email() == null
                ? user.getEmail()
                : request.email().trim().toLowerCase();

        if (email.isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "El correo es obligatorio");
        }

        repository.findByEmail(email)
                .filter(existing -> !existing.getId().equals(id))
                .ifPresent(existing -> {
                    throw new ResponseStatusException(
                            HttpStatus.CONFLICT,
                            "El correo ya está registrado");
                });

        String documentType = clean(request.documentType());
        String documentNumber = clean(request.documentNumber());

        if ((documentType == null) != (documentNumber == null)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Debes indicar el tipo y número de documento");
        }

        if (documentType != null) {
            documentType = documentType.toUpperCase();

            if (!List.of("CC", "TI", "CE", "PA", "PPT")
                    .contains(documentType)) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "Tipo de documento no válido");
            }
        }
        
        if (documentType != null) {
            documentNumber = documentNumber.toUpperCase();

            boolean documentExists = repository.existsByDocumentTypeAndDocumentNumberAndIdNot(
                    documentType,
                    documentNumber,
                    user.getId());

            if (documentExists) {
                throw new ResponseStatusException(
                        HttpStatus.CONFLICT,
                        "Este documento ya está registrado");
            }
        }

        user.setFullName(request.fullName().trim());
        user.setEmail(email);
        user.setDocumentType(documentType);
        user.setDocumentNumber(documentNumber);
        user.setPhone(clean(request.phone()));
        user.setVehicleType(clean(request.vehicleType()));
        user.setVehiclePlate(clean(request.vehiclePlate()));
        user.setVehicleColor(clean(request.vehicleColor()));

        return toResponse(repository.save(user));
    }
    
    @Transactional
    public AdminUserResponse updateRole(
            Long id,
            Role role,
            Long actingAdminId) {

        if (actingAdminId == null) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "No se pudo identificar al administrador autenticado");
        }

        // Bloquea los registros para serializar los cambios de roles.
        List<AppUser> users = repository.findAllForUpdate();

        // Comprueba nuevamente el rol del administrador después del bloqueo.
        AppUser actingAdmin = users.stream()
                .filter(user -> user.getId().equals(actingAdminId))
                .findFirst()
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.FORBIDDEN,
                        "Administrador no encontrado"));

        if (actingAdmin.getRole() != Role.ADMIN) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Tu rol de administrador ya no está activo");
        }

        AppUser targetUser = users.stream()
                .filter(user -> user.getId().equals(id))
                .findFirst()
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Usuario no encontrado"));

        if (targetUser.getRole() == role) {
            return toResponse(targetUser);
        }

        if (targetUser.getId().equals(actingAdminId)
                && role != Role.ADMIN) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "No puedes quitarte tu propio rol de administrador");
        }

        long adminCount = users.stream()
                .filter(user -> user.getRole() == Role.ADMIN)
                .count();

        if (targetUser.getRole() == Role.ADMIN
                && role != Role.ADMIN
                && adminCount <= 1) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "No se puede quitar el rol al último administrador");
        }

        targetUser.setRole(role);

        return toResponse(repository.save(targetUser));
    }

    private AppUser findUser(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Usuario no encontrado"));
    }

    private String clean(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }

        return value.trim();
    }

    private AdminUserResponse toResponse(AppUser user) {
        return new AdminUserResponse(
                user.getId(),
                user.getFullName(),
                user.getEmail(),
                user.getDocumentType(),
                user.getDocumentNumber(),
                user.getPhone(),
                user.getVehicleType(),
                user.getVehiclePlate(),
                user.getVehicleColor(),
                user.getRole().name()
        );
    }
}
