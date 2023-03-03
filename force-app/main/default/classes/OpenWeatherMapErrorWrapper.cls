public class OpenWeatherMapErrorWrapper {

	public Integer cod;
	public String message;

	
	public static OpenWeatherMapErrorWrapper parse(String json) {
		return (OpenWeatherMapErrorWrapper) System.JSON.deserialize(json, OpenWeatherMapErrorWrapper.class);
	}
}