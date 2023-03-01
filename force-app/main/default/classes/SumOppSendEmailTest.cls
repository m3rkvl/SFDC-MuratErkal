@isTest
private class SumOppSendEmailTest {
    @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        List<Opportunity> opps = new List<Opportunity>();
        // insert 10 accounts
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(name='TESTER '+ i));
        }
        insert accounts;

        // select one of the accounts and create opportunities for it
        opps.add(new Opportunity(Name = 'Test Opp1', StageName='Closed Lost', CloseDate = Date.today().addDays(1), AccountId = accounts[0].Id, Amount = 1));
        opps.add(new Opportunity(Name = 'Test Opp2', StageName='Closed Won', CloseDate = Date.today().addDays(1), AccountId = accounts[0].Id, Amount = 1));
        opps.add(new Opportunity(Name = 'Test Opp3', StageName='Value Proposition', CloseDate = Date.today().addDays(1), AccountId = accounts[0].Id, Amount = 1));
        insert opps;

        contacts.add(new Contact(LastName = 'TesterOne', AccountId = accounts[0].Id, Is_Primary_Contact__c = true, Email = 'ocorigin@outlook.com'));
        contacts.add(new Contact(LastName = 'TesterTwo', AccountId = accounts[1].Id, Is_Primary_Contact__c = true, Email = 'half-hour@outlook.com'));
        insert contacts;
    }

    @isTest static void test() {
        Test.startTest();
        SumOppSendEmail myBatch = new SumOppSendEmail();
        Id batchId = Database.executeBatch(myBatch);
        Test.stopTest();

        Set<String> emails = new Set<String>{'ocorigin@outlook.com', 'half-hour@outlook.com'};
        
        List<Email_Log__c> logs = [SELECT To_Addresses__c, Is_Success__c
                                   FROM Email_Log__c];

        System.assert(logs.size() == 2);
        for (Email_Log__c log : logs) {
            System.assert(emails.contains(log.To_Addresses__c));
            System.assertEquals(true, log.Is_Success__c);
        }
    }
}