package com.smartparking.api.dto;

import jakarta.validation.constraints.NotNull;

import com.smartparking.api.model.AppUser.Role;

public record UpdateUserRoleRequest(
        @NotNull Role role
) {
}
