package com.smartparking.api.service;

import com.smartparking.api.dto.UpdateUserProfileRequest;
import com.smartparking.api.dto.UserProfileResponse;
import com.smartparking.api.model.AppUser;
import com.smartparking.api.repository.AppUserRepository;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class UserProfileService {

    private final AppUserRepository appUserRepository;

    public UserProfileService(AppUserRepository appUserRepository) {
        this.appUserRepository = appUserRepository;
    }

    @Transactional(readOnly = true)
    public UserProfileResponse getProfile(String email) {
        AppUser user = findUser(email);
        return toResponse(user);
    }

    @Transactional
    public UserProfileResponse updateProfile(
            String email,
            UpdateUserProfileRequest request) {

        AppUser user = findUser(email);

        user.setFullName(request.fullName().trim());
        user.setInstitutionalCode(clean(request.institutionalCode()));
        user.setPhone(clean(request.phone()));
        user.setVehicleType(clean(request.vehicleType()));
        user.setVehiclePlate(clean(request.vehiclePlate()));
        user.setVehicleColor(clean(request.vehicleColor()));

        AppUser savedUser = appUserRepository.save(user);

        return toResponse(savedUser);
    }

    private AppUser findUser(String email) {
        return appUserRepository.findByEmail(email)
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

    private UserProfileResponse toResponse(AppUser user) {
        return new UserProfileResponse(
                user.getId(),
                user.getFullName(),
                user.getInstitutionalCode(),
                user.getPhone(),
                user.getEmail(),
                user.getVehicleType(),
                user.getVehiclePlate(),
                user.getVehicleColor()
        );
    }
}