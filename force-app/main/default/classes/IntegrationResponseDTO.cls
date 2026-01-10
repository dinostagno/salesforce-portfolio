/**
 * Data Transfer Object (DTO) used to expose integration results to the UI layer.
 *
 * This class provides a simple, serializable response model for Lightning
 * Web Components, containing execution status, HTTP information,
 * and error details when applicable.
 */
public class IntegrationResponseDTO {
    @AuraEnabled public Boolean success;
    @AuraEnabled public Integer statusCode;
    @AuraEnabled public String body;
    @AuraEnabled public String errorMessage;
}
