/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Utility class for logging errors as "Error__c" custom object records for easier further
* investigation when error handling. See below for the info saved on the record.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Murat Erkal   <murat-erkal@outlook.com>
* @version        1.0
* @created        26-02-2023
* @modified       26-02-2023
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public class HandleException extends Exception {
    public static void LogError(Exception e) {
        LogError(e, '');
    }

    public static void LogError(Exception e, String relatedToId) {
        try {
            String stackTrace = e.getStackTraceString().substringBefore('\n');
            String className = stackTrace.substringAfter('.').substringBefore('.');
            String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');

            String QueryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
            String DMLimit = '2. Number of records queried so far /  Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
            String DMLStat = '3. Number of DML statements used so far / Number allowed: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();   
            String CPUT = '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();

            Error__c err = new Error__c();
            err.Related_To_Number__c = relatedToId;
            err.Govt_Limit_in_Executing_Code__c = String.format('{0}\n{1}\n{2}\n{3}',new List<string>{QueryLimit, DMLimit,DMLStat,CPUT});
            err.Exception_Message__c = e.getMessage();
            err.Exception_Type__c = e.getTypeName();
            err.Line_Number__c = e.getLineNumber();
            err.StackTrace__c = e.getStackTraceString();
            err.MethodName__c = methodName;
            err.ClassName__c = className;
            database.insert(err);
        } finally {}
    }
}