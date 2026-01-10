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

        // 🔒 Normalización segura del path
        String normalizedPath = request.path != null
            ? (request.path.startsWith('/') ? request.path : '/' + request.path)
            : '';

        req.setEndpoint('callout:' + namedCredentialName + normalizedPath);
        req.setMethod(method);

        // ⏱️ Timeout explícito (Salesforce recomienda siempre setearlo)
        req.setTimeout(
            request.timeoutMs != null
                ? request.timeoutMs
                : DEFAULT_TIMEOUT
        );

        // 📦 Headers dinámicos
        if (request.headers != null) {
            for (String key : request.headers.keySet()) {
                req.setHeader(key, request.headers.get(key));
            }
        }

        // 📄 Body solo si corresponde
        if (request.body != null && method != 'GET' && method != 'DELETE') {
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(request.body));
        }

        try {
            return new Http().send(req);
        } catch (CalloutException ex) {
            // Aquí normalmente iría logging persistente
            throw ex;
        }
    }
}

