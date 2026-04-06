/**
 * @class       LeadConversionServiceTest
 * @description Cobertura de prueba para LeadConversionService.
 *              Cubre conversión exitosa, lead ya convertido y leadId nulo.
 */
@isTest
private class LeadConversionServiceTest {

    @TestSetup
    static void makeData() {
        Lead testLead = new Lead(
            FirstName   = 'Test',
            LastName    = 'Lead',
            Company     = 'Acme Corp',
            Email       = 'test.lead@acme.com',
            Status      = 'Open - Not Contacted'
        );
        insert testLead;
    }

    @isTest
    static void testConvertLeadSuccess() {
        Lead lead = [SELECT Id FROM Lead WHERE LastName = 'Lead' LIMIT 1];

        LeadConversionService.ConversionRequest req = new LeadConversionService.ConversionRequest();
        req.leadId            = lead.Id;
        req.createOpportunity = true;
        req.opportunityName   = 'Opp desde Test';

        Test.startTest();
        LeadConversionService.ConversionResult result = LeadConversionService.convertLead(req);
        Test.stopTest();

        System.assert(result.isSuccess,      'La conversión debería ser exitosa');
        System.assertNotEquals(null, result.accountId,  'Account Id no debe ser null');
        System.assertNotEquals(null, result.contactId,  'Contact Id no debe ser null');
        System.assertNotEquals(null, result.opportunityId, 'Opportunity Id no debe ser null');
    }

    @isTest
    static void testConvertLeadWithoutOpportunity() {
        Lead lead = [SELECT Id FROM Lead WHERE LastName = 'Lead' LIMIT 1];

        LeadConversionService.ConversionRequest req = new LeadConversionService.ConversionRequest();
        req.leadId            = lead.Id;
        req.createOpportunity = false;

        Test.startTest();
        LeadConversionService.ConversionResult result = LeadConversionService.convertLead(req);
        Test.stopTest();

        System.assert(result.isSuccess,      'La conversión debería ser exitosa');
        System.assertEquals(null, result.opportunityId, 'Opportunity no debería crearse');
    }

    @isTest
    static void testNullLeadId() {
        LeadConversionService.ConversionRequest req = new LeadConversionService.ConversionRequest();
        req.leadId = null;

        Test.startTest();
        LeadConversionService.ConversionResult result = LeadConversionService.convertLead(req);
        Test.stopTest();

        System.assert(!result.isSuccess, 'Debería fallar con leadId nulo');
        System.assertNotEquals(null, result.errorMessage, 'Debe tener mensaje de error');
    }

    @isTest
    static void testInvocableMethod() {
        Lead lead = [SELECT Id FROM Lead WHERE LastName = 'Lead' LIMIT 1];

        LeadConversionService.ConversionRequest req = new LeadConversionService.ConversionRequest();
        req.leadId            = lead.Id;
        req.createOpportunity = true;

        Test.startTest();
        List<LeadConversionService.ConversionResult> results =
            LeadConversionService.convertLeads(
                new List<LeadConversionService.ConversionRequest>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assert(results[0].isSuccess, 'La conversión invocable debería ser exitosa');
    }
}