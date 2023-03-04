/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Controller extension of Standard Account Controller, for GetAccountWeather Visualforce page.
* Fetches the weather data of the current account and displays it.
* First, it checks the cache: if the weather data has been cached in the past 24 hours, gets and displays that value.
* If it wasn't cached: fetches the data from the OpenWeatherMap API, puts it in the cache and displays it.
──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Murat Erkal   <murat-erkal@outlook.com>
* @version        1.0
* @created        02-03-2023
* @modified       02-03-2023
* @utilClasses    HandleException.cls
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public with sharing class GetAccountWeatherExtension {
    public Account acct{get; set;}
    private Cache.OrgPartition orgPart = Cache.Org.getPartition('local.WeatherCache');
    private final String API_KEY = 'd52607be30f818eaec4c0b6011a6fe3f';
    private final String IMG_URL = 'http://openweathermap.org/img/wn/';

    public Boolean hasAddress{get; set;}
    public Boolean isSuccess{get; set;}
    public String errMessage{get; set;}
    public String description{get; set;}
    public String temperature{get; set;}
    public String iconUrl{get; set;}
    

    public GetAccountWeatherExtension(ApexPages.StandardController sc) {
        this.acct = (Account)sc.getRecord();
    }

    public PageReference getWeather() {
        //if the account has a billing city
        if (acct.BillingCity != null && !String.isBlank(acct.BillingCity)) {

            //set the hasAddress state as true
            hasAddress = true;
            
            //get cached values
            String cachedDesc = (String)orgPart.get(acct.BillingCity.replaceAll( '\\s+', '') + 'WeatherDesc');
            String cachedTemp = (String)orgPart.get(acct.BillingCity.replaceAll( '\\s+', '') + 'WeatherTemp');
            String cachedIcon = (String)orgPart.get(acct.BillingCity.replaceAll( '\\s+', '') + 'WeatherIcon');

            //if there are cached values for this city, use them
            //instead of making an http call
            if (cachedDesc != null) {
                isSuccess = true;
                description = cachedDesc;
                temperature = cachedTemp;
                iconUrl = IMG_URL + cachedIcon + '.png';

            //if there aren't cached values ready to use,
            //make the http call and get the weather data
            } else {

                //generate and make the http call
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://api.openweathermap.org/data/2.5/weather?q='+ acct.BillingCity + '&appid=' + API_KEY);
                req.setMethod('GET');
                HTTPResponse res = http.send(req);

                //if its a success, use the retreived data
                if (res.getStatusCode() == 200) {

                    //set the isSuccess state as true
                    isSuccess = true;

                    //get the data from json using the wrapper class
                    OpenWeatherMapWrapper resBody = OpenWeatherMapWrapper.parse(res.getBody());

                    //get the needed data out of it
                    description = resBody.weather[0].description;
                    temperature = String.valueOf(resBody.Main.temp);
                    iconUrl = IMG_URL + resBody.weather[0].icon + '.png';

                    //put the values into the cache
                    orgPart.put(acct.BillingCity.replaceAll( '\\s+', '') + 'WeatherDesc', resBody.weather[0].description);
                    orgPart.put(acct.BillingCity.replaceAll( '\\s+', '') + 'WeatherTemp', String.valueOf(resBody.Main.temp));
                    orgPart.put(acct.BillingCity.replaceAll( '\\s+', '') + 'WeatherIcon', resBody.weather[0].icon);

                //if the http request fails
                } else {

                    //set the isSuccess value as false
                    isSuccess = false;

                    //set the err message accordingly
                    errMessage = 'An error occured when fetching the weather. Try refreshing the page. If it does not resolve the issue, please contact your admin.';

                    //get the request's error message and log it
                    //as an Error__c custom object
                    OpenWeatherMapErrorWrapper resBody = OpenWeatherMapErrorWrapper.parse(res.getBody());

                    Error__c errLog = new Error__c(ClassName__c = 'GetAccountWeatherExtension', 
                    Error_Message__c = resBody.message, 
                    MethodName__c = 'getWeather', 
                    Topic__c = 'HTTP GET error');

                    Database.insert(errLog, false);
                }
            }
        
        //if the account doesn't have a billing address
        } else {

            //set the hasAddress state as false
            hasAddress = false;

            //set the error message as accordingly
            errMessage = 'Please provide a billing address to view the weather.';
        }
        return null;
    }
}