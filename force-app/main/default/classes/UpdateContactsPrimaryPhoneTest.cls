  /**
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
* @author         Murat Erkal   <murat-erkal@outlook.com>
* @version        1.0
* @created        27-02-2023
* @modified       28-02-2023
  ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */

@isTest
private class UpdateContactsPrimaryPhoneTest {

  /**
  ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * Prepares the data necessary for this test class to run.
  * 500 secondary contacts and inserts them.
  * 499 secondary and 1 primary contacts,
  * Starts the test and inserts them.
  * Asserts that the secondary contacts get the phone of the primary
  contact set as their Primary_Contact_Phone__c
  ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
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


  /**
  ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * Prepares the data necessary for this test class to run.
  * 500 secondary contacts and inserts them.
  * 500 secondary and 2 primary contacts,
  * Starts the test and inserts them.
  * Asserts that the primary contacts failed, as it's not allowed
  to have 2 primary contacts at once.
  * Also asserts that the error message is correct.
  ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
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

  /**
  ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * Prepares the data necessary for this test class to run.
  * 500 secondary and 1 primary contacts and inserts them.
  * 500 secondary and 1 primary contacts,
  * Starts the test and inserts them.
  * Asserts that the primary contacts failed, as it's not allowed
  to set a primary contact when there's one already set.
  * Also asserts that the error message is correct.
  ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
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