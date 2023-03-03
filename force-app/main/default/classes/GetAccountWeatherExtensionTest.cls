  /**
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
* @author         Murat Erkal   <murat-erkal@outlook.com>
* @version        1.0
* @created        03-03-2023
* @modified       03-03-2023
  ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */

@isTest
private class GetAccountWeatherExtensionTest {

  /**
  ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * Creates an account with BillingCity as Rome.
  * Prepares the test page as GetAccountWeather page and controller
  with extension.
  * Sets the http mock for a successful response.
  * Calls the getWeather method to get the values from the mock.
  * Calls the getWeather method again to this time read the values from the cache.
  ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
    @isTest static void testGetWeather() {
        //create the account
        Account acct = new Account(Name = 'Test Account', BillingCity = 'Rome');
        insert acct;
        
        //set the successful mock
        Test.setMock(HttpCalloutMock.class, new GetAccountWeatherHttpCalloutMock());

        //prepare the page with the account and the controller extension
        Pagereference pageRef = Page.GetAccountWeather;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController accController = new ApexPages.StandardController(acct);
        GetAccountWeatherExtension accWeaExt = new GetAccountWeatherExtension(accController);

        //start test
        Test.startTest();
        //call the method once to get data from the mock
        accWeaExt.getWeather();
        //call the method again to read the data from cache
        accWeaExt.getWeather();
        Test.stopTest();

        //assert that the data is correct
        System.assertEquals('overcast clouds', accWeaExt.description);
        System.assertEquals('275.69', accWeaExt.temperature);
        System.assertEquals('http:/' + '/openweathermap.org/img/wn/04n.png', accWeaExt.iconUrl);
    }

  /**
  ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * Creates an account without a BillingCity.
  * Prepares the test page as GetAccountWeather page and controller
  with extension.
  * Calls the getWeather method to generate the error message.
  * Asserts that the correct error message is set and that the
  *hasAddress state is set to false.
  ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
    @isTest static void testGetWeatherNoAddress() {
        //create the account
        Account acct = new Account(Name = 'Test Account');
        insert acct;
        
        //prepare the page with the account and the controller extension
        Pagereference pageRef = Page.GetAccountWeather;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController accController = new ApexPages.StandardController(acct);
        GetAccountWeatherExtension accWeaExt = new GetAccountWeatherExtension(accController);

        //start test
        Test.startTest();
        //call the method to generate the error message
        accWeaExt.getWeather();
        Test.stopTest();

        //assert that the error is correctly displayed.
        System.assertEquals(false, accWeaExt.hasAddress);
        System.assertEquals('Please provide a billing address to view the weather.', accWeaExt.errMessage);
    }

  /**
  ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * Creates an account with BillingCity as Rome.
  * Prepares the test page as GetAccountWeather page and controller
  with extension.
  * Sets the http mock for an error response.
  * Calls the getWeather method to get the values from the mock.
  * Asserts that the correct error is displayed to the user.
  * Also asserts that an Error__c object is created with the correct error message from the mock.
  ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
    @isTest static void testGetWeatherNoSuccess() {
        //create the account
        Account acct = new Account(Name = 'Test Account', BillingCity = 'Rome');
        insert acct;
        
        //set the error mock
        Test.setMock(HttpCalloutMock.class, new GetAccountWeatherErrorHttpCalloutMock());

        //set the page
        Pagereference pageRef = Page.GetAccountWeather;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController accController = new ApexPages.StandardController(acct);
        GetAccountWeatherExtension accWeaExt = new GetAccountWeatherExtension(accController);

        //call the method to get the error from the mock
        Test.startTest();
        accWeaExt.getWeather();
        Test.stopTest();

        //get the created 
        List<Error__c> err = [SELECT Error_Message__c FROM Error__c];

        //assert that the Error_c object was created
        System.assertEquals(1, err.size());
        System.assertEquals('Some error message.', err[0].Error_Message__c);

        //assert that the error is correctly displayed to the user.
        System.assertEquals(false, accWeaExt.isSuccess);
        System.assertEquals('An error occured when fetching the weather. Try refreshing the page. If it does not resolve the issue, please contact your admin.', accWeaExt.errMessage);
    }
}