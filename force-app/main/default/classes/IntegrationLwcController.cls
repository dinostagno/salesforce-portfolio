/**
 * Aura-enabled controller exposed to Lightning Web Components (LWC).
 *
 * This controller acts as a thin orchestration layer between the UI
 * and the integration framework, delegating all HTTP transport
 * responsibilities to the HttpIntegrationClient.
 */
public with sharing class IntegrationLwcController {

    /**
     * Executes a sample outbound callout using the centralized HTTP client.
     *
     * This method is intentionally simple and UI-oriented:
     * - Builds a minimal HTTP request definition.
     * - Delegates execution to HttpIntegrationClient.
     * - Maps the HTTP response into a DTO suitable for LWC consumption.
     *
     * No business logic, retries, or response interpretation
     * should be implemented at this level.
     */
    @AuraEnabled
    public static IntegrationResponseDTO callExternalService() {
        IntegrationResponseDTO result = new IntegrationResponseDTO();

        try {
            // Build the HTTP request definition
            HttpIntegrationRequest req = new HttpIntegrationRequest();
            req.method = 'GET';
            req.path = 'todos/1';
            req.timeoutMs = 20000;

            // Execute the outbound callout via Named Credential
            HttpResponse res = HttpIntegrationClient.send(
                'namedCredExample',
                req
            );

            // Map raw HTTP response data to the UI response DTO
            result.statusCode = res.getStatusCode();
            result.success = res.getStatusCode() >= 200 && res.getStatusCode() < 300;
            result.body = res.getBody();

        } catch (Exception ex) {
            // Capture and expose any unexpected error to the UI layer
            result.success = false;
            result.errorMessage = ex.getMessage();
        }

        return result;
    }
}
