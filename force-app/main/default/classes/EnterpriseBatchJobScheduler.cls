public class EnterpriseBatchJobScheduler implements Schedulable {

    private EnterpriseBatchRequest request;

    public EnterpriseBatchJobScheduler(EnterpriseBatchRequest request) {
        this.request = request;
    }

    public void execute(SchedulableContext ctx) {

        Integer batchSize = request.batchSize != null 
            ? request.batchSize 
            : 200;

        EnterpriseDataBatchProcessor batch =
            new EnterpriseDataBatchProcessor(request);

        Database.executeBatch(batch, batchSize);
    }

}
