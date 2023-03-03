@IsTest
public class OpenWeatherMapErrorWrapperTest {
	
	static testMethod void testParse() {
		String json = '{'+
		'    \"cod\": 401,'+
		'    \"message\": \"Some error message.\"'+
		'}';
		OpenWeatherMapErrorWrapper obj = OpenWeatherMapErrorWrapper.parse(json);
		System.assert(obj != null);
	}
}