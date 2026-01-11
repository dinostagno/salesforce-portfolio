@IsTest
public class HttpIntegrationClientTest {

    /* =========================================================
     * Mock HTTP Response
     * ========================================================= */
    private class SuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"ok"}');
            return res;
        }
    }

    /* =========================================================
     * TEST: GET exitoso (path normalizado + timeout default)
     * ========================================================= */
    @IsTest
    static void testSend_getSuccess() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        HttpIntegrationRequest req = new HttpIntegrationRequest();
        req.method = 'GET';
        req.path = 'test/path';

        Test.startTest();
        HttpResponse res = HttpIntegrationClient.send(
            'My_Named_Credential',
            req
        );
        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
        System.assert(res.getBody().contains('ok'));
    }

    /* =========================================================
     * TEST: POST con body, headers y timeout explícito
     * ========================================================= */
    @IsTest
    static void testSend_postWithBodyAndHeaders() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        HttpIntegrationRequest req = new HttpIntegrationRequest();
        req.method = 'POST';
        req.path = '/orders';
        req.timeoutMs = 10000;
        req.headers = new Map<String, String>{
            'Authorization' => 'Bearer test-token'
        };
        req.body = new Map<String, Object>{
            'name' => 'Test Order'
        };

        Test.startTest();
        HttpResponse res = HttpIntegrationClient.send(
            'My_Named_Credential',
            req
        );
        Test.stopTest();

        System.assertEquals(200, res.getStatusCode());
    }

    /* =========================================================
     * TEST: Named Credential vacío
     * ========================================================= */
    @IsTest
    static void testSend_namedCredentialBlank() {
        try {
            HttpIntegrationClient.send(
                '',
                new HttpIntegrationRequest()
            );
            System.assert(false, 'Se esperaba excepción');
        } catch (IllegalArgumentException ex) {
            System.assertEquals(
                'Named Credential es requerido',
                ex.getMessage()
            );
        }
    }

    /* =========================================================
     * TEST: Request nulo
     * ========================================================= */
    @IsTest
    static void testSend_requestNull() {
        try {
            HttpIntegrationClient.send(
                'My_Named_Credential',
                null
            );
            System.assert(false, 'Se esperaba excepción');
        } catch (IllegalArgumentException ex) {
            System.assertEquals(
                'Request inválido',
                ex.getMessage()
            );
        }
    }

    /* =========================================================
     * TEST: Método HTTP no permitido
     * ========================================================= */
    @IsTest
    static void testSend_invalidHttpMethod() {
        HttpIntegrationRequest req = new HttpIntegrationRequest();
        req.method = 'TRACE';

        try {
            HttpIntegrationClient.send(
                'My_Named_Credential',
                req
            );
            System.assert(false, 'Se esperaba excepción');
        } catch (IllegalArgumentException ex) {
            System.assert(
                ex.getMessage().contains('Método HTTP no permitido')
            );
        }
    }
}
