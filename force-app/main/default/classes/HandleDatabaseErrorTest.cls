  /**
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * Test class for the HandleDatabaseError class
  * Creates 10 invalid contact objects,
  * Tries to insert them and save the results,
  * Sends those results to HandleDatabaseError class,
  * Asserts that 10 Error__c objects are created and inserted.
  ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Murat Erkal   <murat-erkal@outlook.com>
* @version        1.0
* @created        27-02-2023
* @modified       27-02-2023
  ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */

@isTest
private class HandleDatabaseErrorTest {
    @isTest static void TestInsertSuccess() {
        List<Contact> conList = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            conList.add(new Contact(FirstName = 'Test ' + i));
        }
        List<Database.SaveResult> results = Database.insert(conList, false);

        Test.startTest();
        HandleDatabaseError.LogError(results, conList, 'Testing', 'HandleDatabaseErrorTest');
        Test.stopTest();

        List<Error__c> errs = [SELECT ClassName__c
                        FROM Error__c
                        WHERE Topic__c = 'Testing'];
        System.assertEquals('HandleDatabaseErrorTest', errs[0].ClassName__c);
        System.assertEquals(10, [SELECT COUNT() 
                                 FROM Error__c 
                                 WHERE Topic__c = 'Testing']);
    }
}