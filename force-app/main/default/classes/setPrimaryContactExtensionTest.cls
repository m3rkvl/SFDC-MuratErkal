@isTest
public class setPrimaryContactExtensionTest {
    @isTest static void testError() {
        /////////////////////////////////////////////
        //Create test data.
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        List<Contact> cons = new List<Contact>();
        cons.add(new Contact(LastName = 'Test Con 1', AccountId = acc.Id, Is_Primary_Contact__c = false));
        cons.add(new Contact(LastName = 'Test Con 2', AccountId = acc.Id, Is_Primary_Contact__c = true));

        insert cons;

        /////////////////////////////////////////////
        // Prepare the page
        PageReference pageRef = Page.SetPrimaryContact;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('contactToUpdateId', cons[0].Id);

        ApexPages.StandardController accController = new ApexPages.StandardController(acc);

        setPrimaryContactExtension accContExt = new setPrimaryContactExtension(accController);

        /////////////////////////////////////////////
        // Start testing and asserting
        Test.startTest();
        accContExt.updateContacts();
        Test.stopTest();

        Contact primaryCon = [SELECT Id, Is_Primary_Contact__c
                              FROM Contact WHERE Id = :cons[0].id];
        System.assertEquals(false, primaryCon.Is_Primary_Contact__c);
    }

    @isTest static void testNextPrevPages() {
        /////////////////////////////////////////////
        // Create test data.
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        List<Contact> cons = new List<Contact>();
        for (Integer i = 0; i < 20; i++) {
            cons.add(new Contact(LastName = 'Test Con ' + i, AccountId = acc.Id, Is_Primary_Contact__c = false));
        }
        cons.add(new Contact(LastName = 'Test Con 21', AccountId = acc.Id, Is_Primary_Contact__c = true));

        insert cons;

        /////////////////////////////////////////////
        // Prepare the page
        PageReference pageRef = Page.SetPrimaryContact;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController accController = new ApexPages.StandardController(acc);

        setPrimaryContactExtension accContExt = new setPrimaryContactExtension(accController);

        /////////////////////////////////////////////
        // Start testing and asserting
        accContExt.contactToUpdateId = cons[0].Id;
        accContExt.inputText = 'Test';

        Test.startTest();
        Boolean hasNextTest = accContExt.getHasNext();
        accContExt.nextPage();
        Boolean hasPrevTest = accContExt.getHasPrev();
        Test.stopTest();

        System.assertEquals(true, hasNextTest);
        System.assertEquals(true, hasPrevTest);
    }

    @isTest static void testSuccess() {
        /////////////////////////////////////////////
        // Create test data.
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        List<Contact> cons = new List<Contact>();
        cons.add(new Contact(LastName = 'Test Con 1', AccountId = acc.Id, Is_Primary_Contact__c = false));
        cons.add(new Contact(LastName = 'Test Con 2', AccountId = acc.Id, Is_Primary_Contact__c = true));

        insert cons;

        /////////////////////////////////////////////
        // Prepare the page
        PageReference pageRef = Page.SetPrimaryContact;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController accController = new ApexPages.StandardController(acc);

        setPrimaryContactExtension accContExt = new setPrimaryContactExtension(accController);

        /////////////////////////////////////////////
        // Start testing and asserting
        accContExt.contactToUpdateId = cons[0].Id;
        accContExt.inputText = 'Test';

        Test.startTest();
        accContExt.refreshNameInput();
        List<Contact> testCons = accContExt.getContacts();
        accContExt.showPopUp();
        accContExt.updateContacts();
        accContExt.closePopUp();
        accContExt.nextPage();
        accContExt.prevPage();
        accContExt.lastPage();
        accContExt.firstPage();
        accContExt.refreshPageSize();
        Test.stopTest();

        Contact primaryCon = [SELECT Id, Is_Primary_Contact__c
                              FROM Contact WHERE Id = :cons[0].id];
        System.assertEquals(true, primaryCon.Is_Primary_Contact__c);
        System.assertEquals(2, testCons.size());
        System.assertEquals('Test%', accContExt.nameInput);
        System.assertEquals(false, accContExt.getHasNext());
        System.assertEquals(false, accContExt.getHasPrev());
        System.assertEquals(false, accContExt.isShowPopUp);
        System.assertEquals(false, accContExt.isErrorShown);
        System.assertEquals(1, accContExt.page);
        System.assertEquals(0, accContExt.offset);
        System.assertEquals(10, accContExt.size);
    }
}