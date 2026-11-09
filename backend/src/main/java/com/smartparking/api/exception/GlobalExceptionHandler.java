package com.smartparking.api.exception;

import org.hibernate.exception.ConstraintViolationException;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

import java.sql.SQLException;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

        private static final String EMAIL_CONSTRAINT = "uk4vj92ux8a2eehds1mdvmks473";

        private static final String DOCUMENT_CONSTRAINT = "uk_app_users_document";

        @ExceptionHandler(DataIntegrityViolationException.class)
        public ResponseEntity<Map<String, String>> handleDataIntegrityViolation(
                        DataIntegrityViolationException ex) {

                String constraintName = findConstraintName(ex);

                String message;

                if (EMAIL_CONSTRAINT.equalsIgnoreCase(constraintName)) {
                        message = "El correo electrónico ya está registrado";
                } else if (DOCUMENT_CONSTRAINT.equalsIgnoreCase(constraintName)) {
                        message = "El documento ya está registrado";
                } else {
                        message = "No se pudieron guardar los datos por una restricción de la base de datos";
                }

                return ResponseEntity.status(HttpStatus.CONFLICT)
                                .body(Map.of(
                                                "error", "CONFLICT",
                                                "message", message));
        }

        private String findConstraintName(Throwable ex) {

                Throwable current = ex;

                while (current != null) {

                        if (current instanceof ConstraintViolationException violation) {
                                return violation.getConstraintName();
                        }

                        current = current.getCause();
                }

                return null;
        }

        @ExceptionHandler(ResponseStatusException.class)
        public ResponseEntity<Map<String, String>> handleResponseStatus(
                        ResponseStatusException ex) {

                HttpStatus status = HttpStatus.valueOf(
                                ex.getStatusCode().value());

                return ResponseEntity.status(status)
                                .body(Map.of(
                                                "error", status.name(),
                                                "message", ex.getReason() != null
                                                                ? ex.getReason()
                                                                : "Ha ocurrido un error"));
        }

        @ExceptionHandler(MethodArgumentNotValidException.class)
        public ResponseEntity<Map<String, String>> handleValidation(
                        MethodArgumentNotValidException ex) {

                String message = ex.getBindingResult()
                                .getFieldErrors()
                                .stream()
                                .findFirst()
                                .map(error -> error.getDefaultMessage())
                                .orElse("Los datos enviados no son válidos");

                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body(Map.of(
                                                "error", "BAD_REQUEST",
                                                "message", message));
        }
}
