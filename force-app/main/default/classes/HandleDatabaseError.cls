public with sharing class HandleDatabaseError {
    public static void logError(List<Database.SaveResult> saveResults, List<SObject> objectList, String topic, String className){
        try{
            //error object list
            List<Error__c> errorList = new List<Error__c>();
            
            for (Integer i = 0; i < saveResults.size(); i++) {
                if (!saveResults.get(i).isSuccess()){
                    //get the database error object
                    Database.Error dbError = saveResults.get(i).getErrors().get(0);

                    //get the record id and name related to the error
                    String recordId, recordName = '';
                    if (objectList.size() > 0){
                        recordId = (String)objectList[i].get('Id');
                        recordName = (String)objectList[i].get('Name');
                    }

                    //create new custom error object and add fields to it.
                    Error__c err = new Error__c();
                    err.Error_Message__c = dbError.getMessage();
                    err.StackTrace__c = String.valueOf(dbError.getStatusCode());
                    err.Record_ID__c = recordId;
                    err.Record_Name__c = recordName;
                    err.Topic__c = topic;
                    err.ClassName__c = className;

                    //add error to the list
                    errorList.add(err);
                }
            }

            //if the list isn't empty, insert it.
            if (errorList.size() > 0) {
                insert errorList;
            }
        } finally {
        }
    }
}