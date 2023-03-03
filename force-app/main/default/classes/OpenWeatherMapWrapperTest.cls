@IsTest
public class OpenWeatherMapWrapperTest {
	
	static testMethod void testParse() {
		String json = '{'+
		'    \"coord\": {'+
		'        \"lon\": 10.99,'+
		'        \"lat\": 44.34'+
		'    },'+
		'    \"weather\": ['+
		'        {'+
		'            \"id\": 804,'+
		'            \"main\": \"Clouds\",'+
		'            \"description\": \"overcast clouds\",'+
		'            \"icon\": \"04n\"'+
		'        }'+
		'    ],'+
		'    \"base\": \"stations\",'+
		'    \"main\": {'+
		'        \"temp\": 275.69,'+
		'        \"feels_like\": 275.69,'+
		'        \"temp_min\": 273.82,'+
		'        \"temp_max\": 277.38,'+
		'        \"pressure\": 1017,'+
		'        \"humidity\": 91,'+
		'        \"sea_level\": 1017,'+
		'        \"grnd_level\": 929'+
		'    },'+
		'    \"visibility\": 7965,'+
		'    \"wind\": {'+
		'        \"speed\": 1.14,'+
		'        \"deg\": 304,'+
		'        \"gust\": 1.93'+
		'    },'+
		'    \"clouds\": {'+
		'        \"all\": 100'+
		'    },'+
		'    \"dt\": 1677803100,'+
		'    \"sys\": {'+
		'        \"type\": 2,'+
		'        \"id\": 2004688,'+
		'        \"country\": \"IT\",'+
		'        \"sunrise\": 1677822654,'+
		'        \"sunset\": 1677863134'+
		'    },'+
		'    \"timezone\": 3600,'+
		'    \"id\": 3163858,'+
		'    \"name\": \"Zocca\",'+
		'    \"cod\": 200'+
		'}';
		OpenWeatherMapWrapper obj = OpenWeatherMapWrapper.parse(json);
		System.assert(obj != null);
	}
}