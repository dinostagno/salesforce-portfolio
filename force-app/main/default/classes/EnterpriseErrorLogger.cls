public class EnterpriseErrorLogger {

    public static void log(Exception ex) {

        System.debug('ENTERPRISE ERROR');
        System.debug('Message: ' + ex.getMessage());
        System.debug('StackTrace: ' + ex.getStackTraceString());

        /*
         FUTURO:
         - Insert Custom Log Object
         - Publish Platform Event
         - External Monitoring Tool
        */
    }

    public static void log(Database.Error[] errors) {

        for (Database.Error err : errors) {
            System.debug('DML ERROR: ' + err.getMessage());
        }

    }
}
