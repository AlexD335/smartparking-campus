package com.smartparking.api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.Email;

public record AdminUpdateUserRequest(

        @NotBlank(message = "El nombre es obligatorio")
        @Size(max = 120, message = "El nombre no puede superar 120 caracteres")
        String fullName,

        @Email(message = "El correo electrónico no tiene un formato válido")
        @Size(max = 254, message = "El correo es demasiado largo")
        String email,

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
