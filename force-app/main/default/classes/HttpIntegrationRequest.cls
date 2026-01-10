/**
 * @group Integration Framework
 * @author Dino Stagno
 * @description
 * Simple data transfer object used to define HTTP request parameters
 * for outbound integrations.
 */
public class HttpIntegrationRequest {
    public String method;
    public String path;
    public Map<String, String> headers;
    public Object body;
    public Integer timeoutMs;
}
