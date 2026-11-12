package com.smartparking.api.dto;

public record CreateParkingSpaceRequest(
        String code,
        String zone,
        String location
) {
}
