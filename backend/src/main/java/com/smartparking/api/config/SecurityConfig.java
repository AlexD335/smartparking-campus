package com.smartparking.api.config;

import com.nimbusds.jose.jwk.source.ImmutableSecret;
import com.smartparking.api.model.AppUser;
import com.smartparking.api.repository.AppUserRepository;
import com.nimbusds.jose.proc.SecurityContext;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.core.convert.converter.Converter;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.jwt.Jwt;
import java.util.Collection;
import java.util.List;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final SecretKey secretKey;
    private final AppUserRepository appUserRepository;

    public SecurityConfig(
            @Value("${JWT_SECRET}") String jwtSecret,
            AppUserRepository appUserRepository) {
        this.appUserRepository = appUserRepository;
        byte[] keyBytes = java.util.Base64.getDecoder().decode(jwtSecret);

        if (keyBytes.length < 32) {
            throw new IllegalArgumentException(
                    "JWT_SECRET must contain at least 32 random bytes encoded as Base64");
        }

        this.secretKey = new SecretKeySpec(keyBytes, "HmacSHA256");
    }

    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http) throws Exception {

        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/auth/**").permitAll()

                        .requestMatchers(
                                HttpMethod.GET,
                                "/api/plazas",
                                "/api/plazas/**")
                        .permitAll()

                        .requestMatchers("/api/admin/**")
                        .hasRole("ADMIN")

                        .anyRequest().authenticated())
                .oauth2ResourceServer(oauth2 -> oauth2.jwt(jwt -> jwt
                        .jwtAuthenticationConverter(jwtAuthenticationConverter())));

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public JwtDecoder jwtDecoder() {
        return NimbusJwtDecoder
            .withSecretKey(secretKey)
            .macAlgorithm(MacAlgorithm.HS256)
            .build();
    }

    @Bean
    public JwtEncoder jwtEncoder() {
        return new NimbusJwtEncoder(
            new ImmutableSecret<SecurityContext>(secretKey));
    }

    @Bean
    public Converter<Jwt, ? extends AbstractAuthenticationToken> jwtAuthenticationConverter() {

        JwtAuthenticationConverter converter = new JwtAuthenticationConverter();

        // El rol se consulta en la base de datos en cada petición autenticada.
        // Así, un cambio de rol tiene efecto inmediato y no depende de que
        // expire el JWT que contiene el rol anterior.
        converter.setJwtGrantedAuthoritiesConverter(jwt -> {
            Number userIdClaim = jwt.getClaim("userId");
            if (userIdClaim == null) {
                return List.of();
            }

            return appUserRepository.findById(userIdClaim.longValue())
                    .<Collection<GrantedAuthority>>map(user -> List.of(
                            new SimpleGrantedAuthority("ROLE_" + user.getRole().name())))
                    .orElseGet(List::of);
        });

        return converter;
    }
}
