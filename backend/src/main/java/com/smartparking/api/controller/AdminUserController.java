package com.smartparking.api.controller;

import com.smartparking.api.dto.AdminUpdateUserRequest;
import com.smartparking.api.dto.AdminUserResponse;
import com.smartparking.api.dto.UpdateUserRoleRequest;
import com.smartparking.api.service.AdminUserService;

import jakarta.validation.Valid;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/usuarios")
public class AdminUserController {

    private final AdminUserService service;

    public AdminUserController(AdminUserService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<List<AdminUserResponse>> getAllUsers() {
        return ResponseEntity.ok(service.getAllUsers());
    }

    @GetMapping("/{id}")
    public ResponseEntity<AdminUserResponse> getUser(
            @PathVariable Long id) {

        return ResponseEntity.ok(service.getUser(id));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<AdminUserResponse> updateUser(
            @PathVariable Long id,
            @Valid @RequestBody AdminUpdateUserRequest request) {

        return ResponseEntity.ok(service.updateUser(id, request));
    }

    @PatchMapping("/{id}/rol")
    public ResponseEntity<AdminUserResponse> updateRole(
            @PathVariable Long id,
            @Valid @RequestBody UpdateUserRoleRequest request,
            @AuthenticationPrincipal Jwt jwt) {

        Number userIdClaim = jwt.getClaim("userId");
        Long actingAdminId = userIdClaim == null
                ? null
                : userIdClaim.longValue();

        return ResponseEntity.ok(
                service.updateRole(id, request.role(), actingAdminId));
    }
}
