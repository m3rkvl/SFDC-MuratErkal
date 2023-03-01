public with sharing class SendAndLogEmails {
    public static final String DELIMITER = '; ';

    public static void sendAndLog(List<Messaging.SingleEmailMessage> emails) {

    Integer index = 0;

    List<Email_Log__c> logs = new List<Email_Log__c>();

    for (Messaging.SendEmailResult result : Messaging.sendEmail(emails, false)) {
        logs.add(buildLog(emails[index++], result));
    }

    insert logs;
    }

    public static Email_Log__c buildLog(Messaging.SingleEmailMessage email, Messaging.SendEmailResult result) {
        return new Email_Log__c(
        Is_Success__c = result.isSuccess(),
        Error_Messages__c = concatenateErrors(result.getErrors()),
        To_Addresses__c = String.join(email.getToAddresses(), DELIMITER),
        Html_Body__c = email.getHtmlBody()
        );
    }

    public static String concatenateErrors(List<Messaging.SendEmailError> errors) {
        List<String> messages = new List<String>();
        for (Messaging.SendEmailError error : errors) messages.add(error.getMessage());
        return String.join(messages, DELIMITER);
    }
}