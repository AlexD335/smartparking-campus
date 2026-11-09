package com.smartparking.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UpdateUserProfileRequest(

        @NotBlank(message = "El nombre completo es obligatorio")
        @Size(max = 120)
        String fullName,

        @Size(max = 10)
        String documentType,

        @Size(max = 30)
        String documentNumber,

        @Size(max = 20)
        String phone,

        @Size(max = 30)
        String vehicleType,

        @Size(max = 15)
        String vehiclePlate,

        @Size(max = 30)
        String vehicleColor
) {
}
