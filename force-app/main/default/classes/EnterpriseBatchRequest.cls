public class EnterpriseBatchRequest {

    public String soqlQuery;
    public Integer batchSize;
    public Boolean enablePartialProcessing;

    public EnterpriseBatchRequest(
        String soqlQuery,
        Integer batchSize,
        Boolean enablePartialProcessing
    ) {
        this.soqlQuery = soqlQuery;
        this.batchSize = batchSize;
        this.enablePartialProcessing = enablePartialProcessing;
    }

}
