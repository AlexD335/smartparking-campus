package com.smartparking.api.dto;

public record AdminUserResponse(
        Long id,
        String fullName,
        String email,
        String documentType,
        String documentNumber,
        String phone,
        String vehicleType,
        String vehiclePlate,
        String vehicleColor,
        String role
) {
}
