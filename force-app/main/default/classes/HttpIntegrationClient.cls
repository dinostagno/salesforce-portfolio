/*
 * Copyright (c) 2026 Dino Stagno
 *
 * Licensed for internal use within Salesforce applications.
 * This file is provided "as is", without warranties of any kind,
 * either express or implied.
 */

/**
 * @group Integration Framework
 * @author Dino Stagno
 * @description
 * HttpIntegrationClient is a centralized HTTP client responsible for executing
 * outbound callouts using Salesforce Named Credentials.
 *
 * This class provides a consistent and reusable way to:
 * - Validate HTTP methods and input parameters.
 * - Build endpoints using Named Credentials.
 * - Apply explicit timeouts and dynamic headers.
 * - Send HTTP requests with optional request bodies.
 *
 * This client is intentionally lightweight and transport-focused.
 * Business logic, response interpretation, retries, and logging
 * should be handled by higher-level service layers.
 */
public with sharing class HttpIntegrationClient {

    private static final Integer DEFAULT_TIMEOUT = 30000;

    private static final Set<String> ALLOWED_METHODS = new Set<String>{
        'GET', 'POST', 'PUT', 'PATCH', 'DELETE'
    };

    public static HttpResponse send(
        String namedCredentialName,
        HttpIntegrationRequest request
    ) {
        if (String.isBlank(namedCredentialName)) {
            throw new IllegalArgumentException('Named Credential es requerido');
        }

        if (request == null || String.isBlank(request.method)) {
            throw new IllegalArgumentException('Request inválido');
        }

        String method = request.method.toUpperCase();
        if (!ALLOWED_METHODS.contains(method)) {
            throw new IllegalArgumentException('Método HTTP no permitido: ' + method);
        }

        HttpRequest req = new HttpRequest();

        // Normalize request path
        String normalizedPath = request.path != null
            ? (request.path.startsWith('/') ? request.path : '/' + request.path)
            : '';

        req.setEndpoint('callout:' + namedCredentialName + normalizedPath);
        req.setMethod(method);

        // Apply explicit timeout
        req.setTimeout(
            request.timeoutMs != null
                ? request.timeoutMs
                : DEFAULT_TIMEOUT
        );

        // Apply dynamic headers
        if (request.headers != null) {
            for (String key : request.headers.keySet()) {
                req.setHeader(key, request.headers.get(key));
            }
        }

        // Set request body when applicable
        if (request.body != null && method != 'GET' && method != 'DELETE') {
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(request.body));
        }

        try {
            return new Http().send(req);
        } catch (CalloutException ex) {
            // Persistent logging can be implemented by higher layers
            throw ex;
        }
    }
}
