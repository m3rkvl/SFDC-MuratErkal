/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Utility class for sending an logging emails.
* Takes a list of emails, sends them, and creates
custom "Mail_Log__c" objects with the results of each email. 
──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Murat Erkal   <murat-erkal@outlook.com>
* @version        1.0
* @created        1-03-2023
* @modified       1-03-2023
* @param          List<Messaging.SingleEmailMessage>
─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public with sharing class SendAndLogEmails {
    public static final String DELIMITER = '; ';

    // Takes a list of SingleEmailMessage objects,
    // sends them,
    // logs their results.
    public static void sendAndLog(List<Messaging.SingleEmailMessage> emails) {

    Integer index = 0;

    List<Email_Log__c> logs = new List<Email_Log__c>();

    for (Messaging.SendEmailResult result : Messaging.sendEmail(emails, false)) {
        logs.add(buildLog(emails[index++], result));
    }

    insert logs;
    }

    // Utility method to build the "Mail_Log__c" custom object.
    public static Email_Log__c buildLog(Messaging.SingleEmailMessage email, Messaging.SendEmailResult result) {
        return new Email_Log__c(
        Is_Success__c = result.isSuccess(),
        Error_Messages__c = concatenateErrors(result.getErrors()),
        To_Addresses__c = String.join(email.getToAddresses(), DELIMITER),
        Html_Body__c = email.getHtmlBody()
        );
    }

    // Utility method to concat the error messages into 1 string.
    public static String concatenateErrors(List<Messaging.SendEmailError> errors) {
        List<String> messages = new List<String>();
        for (Messaging.SendEmailError error : errors) messages.add(error.getMessage());
        return String.join(messages, DELIMITER);
    }
}