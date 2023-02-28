@isTest
private class UpdateContactsPrimaryPhoneTest {
    @isTest static void TestInsertSuccess() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        List<Contact> cons = new List<Contact>();
        for (Integer i = 0; i < 500; i++) {
            cons.add(new Contact(LastName = 'Test ' + i, Is_Primary_Contact__c = false, AccountId = acc.Id));
        }
        insert cons;

        List<Contact> consWithPrimary = new List<Contact>();
        for (Integer i = 0; i < 499; i++) {
            consWithPrimary.add(new Contact(LastName = 'Test ' + 500 + i, Is_Primary_Contact__c = false, AccountId = acc.Id));
        }

        Contact pCon = new Contact(LastName = 'Test 1000', Is_Primary_Contact__c = true, Phone = '505', AccountId = acc.Id);
        consWithPrimary.add(pCon);

        Test.startTest();
        insert consWithPrimary;
        Test.stopTest();

        System.assert(consWithPrimary[499].Id != null);
        List<Contact> secondaryCon = [SELECT Primary_Contact_Phone__c
                                      FROM Contact
                                      WHERE Id = :cons[4].Id];
        System.assertEquals('505', secondaryCon[0].Primary_Contact_Phone__c);
    }

    @isTest static void TestInsertMultiplePrimariesError() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        List<Contact> cons = new List<Contact>();
        for (Integer i = 0; i < 500; i++) {
            cons.add(new Contact(LastName = 'Test ' + i, Is_Primary_Contact__c = false, AccountId = acc.Id));
        }
        insert cons;

        List<Contact> consWithPrimaries = new List<Contact>();
        for (Integer i = 0; i < 500; i++) {
            consWithPrimaries.add(new Contact(LastName = 'Test ' + 500 + i, Is_Primary_Contact__c = false, AccountId = acc.Id));
        }

        Contact pCon1 = new Contact(LastName = 'Test 1000', Is_Primary_Contact__c = true, Phone = '505', AccountId = acc.Id);
        Contact pCon2 = new Contact(LastName = 'Test 1001', Is_Primary_Contact__c = true, Phone = '505', AccountId = acc.Id);
        consWithPrimaries.add(pCon1);
        consWithPrimaries.add(pCon2);

        Test.startTest();
        List<Database.SaveResult> results = Database.insert(consWithPrimaries, false);
        Test.stopTest();

        System.assert(!results[500].isSuccess());
        System.assert(results[500].getErrors().size() > 0);
        System.assertEquals('An account can have only 1 primary contact.', results[500].getErrors()[0].getMessage());
    }

    @isTest static void TestInsertSinglePrimaryError() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        List<Contact> consWithPrimary1 = new List<Contact>();
        for (Integer i = 0; i < 500; i++) {
            consWithPrimary1.add(new Contact(LastName = 'Test ' + i, Is_Primary_Contact__c = false, AccountId = acc.Id));
        }
        Contact pCon1 = new Contact(LastName = 'Test 500', Is_Primary_Contact__c = true, Phone = '504', AccountId = acc.Id);
        consWithPrimary1.add(pCon1);
        insert consWithPrimary1;

        List<Contact> consWithPrimary2 = new List<Contact>();
        for (Integer i = 0; i < 500; i++) {
            consWithPrimary2.add(new Contact(LastName = 'Test ' + 500 + i, Is_Primary_Contact__c = false, AccountId = acc.Id));
        }

        Contact pCon2 = new Contact(LastName = 'Test 1000', Is_Primary_Contact__c = true, Phone = '505', AccountId = acc.Id);
        consWithPrimary2.add(pCon2);

        Test.startTest();
        List<Database.SaveResult> results = Database.insert(consWithPrimary2, false);
        Test.stopTest();

        System.assert(!results[500].isSuccess());
        System.assert(results[500].getErrors().size() > 0);
        System.assertEquals('Related account already has a primary contact set.', results[500].getErrors()[0].getMessage());
    }
}