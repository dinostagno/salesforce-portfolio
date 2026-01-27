public class EnterpriseDataBatchProcessor 
    implements Database.Batchable<SObject>, Database.Stateful {

    private EnterpriseBatchRequest request;

    private Integer processedRecords = 0;
    private Integer failedRecords = 0;

    // Constructor parametrizado
    public EnterpriseDataBatchProcessor(EnterpriseBatchRequest request) {
        this.request = request;
    }

    // =====================
    // START
    // =====================
    public Database.QueryLocator start(Database.BatchableContext bc) {

        if (String.isBlank(request.soqlQuery)) {
            throw new BatchInitializationException('SOQL query cannot be empty');
        }

        return Database.getQueryLocator(request.soqlQuery);
    }

    // =====================
    // EXECUTE
    // =====================
    public void execute(Database.BatchableContext bc, List<SObject> scope) {

        try {

            List<SObject> recordsToUpdate = new List<SObject>();

            for (SObject record : scope) {

                // 👉 TU LOGICA DE NEGOCIO VA AQUI
                recordsToUpdate.add(record);
            }

            if (!recordsToUpdate.isEmpty()) {

                if (request.enablePartialProcessing) {

                    Database.SaveResult[] results =
                        Database.update(recordsToUpdate, false);

                    for (Database.SaveResult sr : results) {

                        if (sr.isSuccess()) {
                            processedRecords++;
                        } else {
                            failedRecords++;
                            EnterpriseErrorLogger.log(sr.getErrors());
                        }

                    }

                } else {

                    update recordsToUpdate;
                    processedRecords += recordsToUpdate.size();

                }
            }

        } catch (Exception ex) {

            failedRecords += scope.size();
            EnterpriseErrorLogger.log(ex);

        }

    }

    // =====================
    // FINISH
    // =====================
    public void finish(Database.BatchableContext bc) {

        System.debug('ENTERPRISE BATCH FINISHED');
        System.debug('Processed Records: ' + processedRecords);
        System.debug('Failed Records: ' + failedRecords);

        /*
         FUTURO:
         - Email notification
         - Platform Event
         - Batch chaining
         - Monitoring integration
        */

    }

    // =====================
    // Custom Exception
    // =====================
    public class BatchInitializationException extends Exception {}

}
