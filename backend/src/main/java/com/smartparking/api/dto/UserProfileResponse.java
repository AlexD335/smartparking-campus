package com.smartparking.api.dto;

public record UserProfileResponse(
        Long id,
        String fullName,
        String institutionalCode,
        String phone,
        String email,
        String vehicleType,
        String vehiclePlate,
        String vehicleColor
) {
}
