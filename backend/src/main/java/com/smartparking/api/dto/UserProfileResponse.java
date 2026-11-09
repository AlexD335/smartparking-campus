package com.smartparking.api.dto;

public record UserProfileResponse(
        Long id,
        String fullName,
        String documentType,
        String documentNumber,
        String phone,
        String email,
        String vehicleType,
        String vehiclePlate,
        String vehicleColor
) {
}
