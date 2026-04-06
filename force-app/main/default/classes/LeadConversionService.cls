/**
 * @class       LeadConversionService
 * @description Servicio para convertir Leads a Account, Contact y Opportunity
 *              siguiendo las mejores prácticas de Salesforce Apex.
 *              Sin hardcodeos: el status de conversión se obtiene dinámicamente
 *              desde LeadStatus y los IDs de owner/account son parámetros.
 *
 * @author      Tu equipo
 * @version     1.0
 */
public with sharing class LeadConversionService {

    // ─────────────────────────────────────────────────────────────────────────
    // Inner class: Request (usado también como @InvocableVariable para Flow/Agentforce)
    // ─────────────────────────────────────────────────────────────────────────
    public class ConversionRequest {
        @InvocableVariable(label='Lead Id' required=true)
        public Id leadId;

        @InvocableVariable(label='Account Id existente (opcional)')
        public Id accountId;

        @InvocableVariable(label='Owner Id (opcional, usa el del Lead si está vacío)')
        public Id ownerId;

        @InvocableVariable(label='Crear Opportunity' description='true por defecto')
        public Boolean createOpportunity;

        @InvocableVariable(label='Nombre de la Opportunity (opcional)')
        public String opportunityName;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Inner class: Result
    // ─────────────────────────────────────────────────────────────────────────
    public class ConversionResult {
        @InvocableVariable(label='Éxito')
        public Boolean isSuccess;

        @InvocableVariable(label='Account Id generado')
        public Id accountId;

        @InvocableVariable(label='Contact Id generado')
        public Id contactId;

        @InvocableVariable(label='Opportunity Id generado')
        public Id opportunityId;

        @InvocableVariable(label='Mensaje de error')
        public String errorMessage;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Método Invocable: permite llamarlo desde Flow, Process Builder o Agentforce
    // ─────────────────────────────────────────────────────────────────────────
    @InvocableMethod(
        label       = 'Convertir Lead'
        description = 'Convierte un Lead a Account, Contact y opcionalmente Opportunity'
        category    = 'Lead'
    )
    public static List<ConversionResult> convertLeads(List<ConversionRequest> requests) {
        List<ConversionResult> results = new List<ConversionResult>();

        // Obtener el status de conversión dinámicamente (sin hardcodear el label)
        String convertedStatus = getConvertedLeadStatus();

        for (ConversionRequest req : requests) {
            results.add(convertSingleLead(req, convertedStatus));
        }

        return results;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Método público para uso directo desde Apex
    // ─────────────────────────────────────────────────────────────────────────
    public static ConversionResult convertLead(ConversionRequest req) {
        String convertedStatus = getConvertedLeadStatus();
        return convertSingleLead(req, convertedStatus);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Lógica principal de conversión
    // ─────────────────────────────────────────────────────────────────────────
    private static ConversionResult convertSingleLead(ConversionRequest req, String convertedStatus) {
        ConversionResult result = new ConversionResult();

        try {
            // Validación básica
            if (req.leadId == null) {
                result.isSuccess    = false;
                result.errorMessage = 'leadId es requerido.';
                return result;
            }

            // Verificar que el lead no esté ya convertido
            Lead existingLead = [
                SELECT Id, IsConverted, OwnerId
                FROM Lead
                WHERE Id = :req.leadId
                LIMIT 1
            ];

            if (existingLead.IsConverted) {
                result.isSuccess    = false;
                result.errorMessage = 'El Lead ya fue convertido previamente.';
                return result;
            }

            // Construir el objeto LeadConvert
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(req.leadId);
            lc.setConvertedStatus(convertedStatus);

            // Si se pasa un Account existente, se vincula (no crea uno nuevo)
            if (req.accountId != null) {
                lc.setAccountId(req.accountId);
            }

            // Owner: usa el del request o hereda el del Lead
            if (req.ownerId != null) {
                lc.setOwnerId(req.ownerId);
            } else {
                lc.setOwnerId(existingLead.OwnerId);
            }

            // Opportunity: por defecto se crea, a menos que se indique false
            Boolean createOpp = (req.createOpportunity != null) ? req.createOpportunity : true;
            if (!createOpp) {
                lc.setDoNotCreateOpportunity(true);
            } else if (String.isNotBlank(req.opportunityName)) {
                lc.setOpportunityName(req.opportunityName);
            }

            // Ejecutar la conversión
            Database.LeadConvertResult lcr = Database.convertLead(lc);

            if (lcr.isSuccess()) {
                result.isSuccess      = true;
                result.accountId      = lcr.getAccountId();
                result.contactId      = lcr.getContactId();
                result.opportunityId  = lcr.getOpportunityId();
            } else {
                result.isSuccess    = false;
                result.errorMessage = lcr.getErrors()[0].getMessage();
            }

        } catch (Exception e) {
            result.isSuccess    = false;
            result.errorMessage = e.getMessage();
        }

        return result;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Obtiene dinámicamente el primer LeadStatus marcado como "IsConverted"
    // Evita hardcodear strings como 'Closed - Converted'
    // ─────────────────────────────────────────────────────────────────────────
    private static String getConvertedLeadStatus() {
        LeadStatus convertedStatus = [
            SELECT MasterLabel
            FROM LeadStatus
            WHERE IsConverted = true
            LIMIT 1
        ];
        return convertedStatus.MasterLabel;
    }
}