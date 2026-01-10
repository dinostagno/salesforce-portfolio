public class HttpIntegrationRequest {
    public String method;
    public String path;
    public Map<String, String> headers;
    public Object body;
    public Integer timeoutMs;
}
