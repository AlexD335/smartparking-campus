package com.smartparking.api.exception;

import org.hibernate.exception.ConstraintViolationException;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class GlobalExceptionHandlerTest {

    private final GlobalExceptionHandler handler =
            new GlobalExceptionHandler();

    @Test
    void shouldReturnConflictWhenEmailIsDuplicated() {
        ConstraintViolationException violation =
                new ConstraintViolationException(
                        "Duplicate email",
                        null,
                        "uk4vj92ux8a2eehds1mdvmks473"
                );

        DataIntegrityViolationException exception =
                new DataIntegrityViolationException(
                        "Database constraint violation",
                        violation
                );

        ResponseEntity<Map<String, String>> response =
                handler.handleDataIntegrityViolation(exception);

        assertEquals(HttpStatus.CONFLICT, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("CONFLICT", response.getBody().get("error"));
        assertEquals(
                "El correo electrónico ya está registrado",
                response.getBody().get("message")
        );
    }

    @Test
    void shouldReturnConflictWhenDocumentIsDuplicated() {
        ConstraintViolationException violation =
                new ConstraintViolationException(
                        "Duplicate document",
                        null,
                        "uk_app_users_document"
                );

        DataIntegrityViolationException exception =
                new DataIntegrityViolationException(
                        "Database constraint violation",
                        violation
                );

        ResponseEntity<Map<String, String>> response =
                handler.handleDataIntegrityViolation(exception);

        assertEquals(HttpStatus.CONFLICT, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("CONFLICT", response.getBody().get("error"));
        assertEquals(
                "El documento ya está registrado",
                response.getBody().get("message")
        );
    }

    @Test
    void shouldReturnGenericMessageForUnknownConstraint() {
        DataIntegrityViolationException exception =
                new DataIntegrityViolationException(
                        "Unknown database constraint"
                );

        ResponseEntity<Map<String, String>> response =
                handler.handleDataIntegrityViolation(exception);

        assertEquals(HttpStatus.CONFLICT, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(
                "No se pudieron guardar los datos por una restricción de la base de datos",
                response.getBody().get("message")
        );
    }

    @Test
    void shouldPreserveResponseStatusException() {
        ResponseStatusException exception =
                new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Usuario no encontrado"
                );

        ResponseEntity<Map<String, String>> response =
                handler.handleResponseStatus(exception);

        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("NOT_FOUND", response.getBody().get("error"));
        assertEquals(
                "Usuario no encontrado",
                response.getBody().get("message")
        );
    }
}
