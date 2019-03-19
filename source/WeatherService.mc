using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.Time;
using Toybox.Math;

(:background)
module Weather {

	var temperatureFormatter = new TemperatureFieldFormatter();
	var weatherIconFormatter = new WeatherIconFormatter();
	var humidityFormatter = new HumidityFieldFormatter();
	var windSpeedFormatter = new WindSpeedFieldFormatter();

	function getUnits() {
		var units;	
		
		if (Sys.getDeviceSettings().temperatureUnits == Sys.UNIT_METRIC) {
			units = "metric";
		} else {
			units = "imperial";
		}
		
		return units;
	}
					
	function getWeatherUrl() {
		return "https://api.openweathermap.org/data/2.5/weather";
	}
	
	function getWeatherApiKey() {
		return "d72271af214d870eb94fe8f9af450db4";
	}
	
	function getWeatherParams() {
		return {
			"lat" => App.Storage.getValue("LastLocationLat"),
			"lon" => App.Storage.getValue("LastLocationLng"),
			"appid" => getWeatherApiKey(),
			"units" => getUnits()
		};
	}
	
	function parseWeatherData(data) {
		return {
			"cod" => data["cod"],
			"lat" => data["coord"]["lat"],
			"lon" => data["coord"]["lon"],
			"dt" => data["dt"],
			"temp" => data["main"]["temp"],
			"humidity" => data["main"]["humidity"],
			"wind-speed" => data["wind"]["speed"],
			"icon" => data["weather"][0]["icon"]
		};
	}
	
	function getWeatherData() {
		return App.Storage.getValue("OpenWeatherMapCurrent");
	}
	
	function isWeatherDataStale() {
		var weather = getWeatherData();
		
		return ((weather == null) || 
				(weather["dt"] == null) ||
				(Time.now().value() > (weather["dt"] + 1800)));
	}
	
	function isLocationDifferent(locationLat, locationLng) {
		var owmCurrent = getWeatherData();
		
		return ((locationLat - owmCurrent["lat"]).abs() > 0.02) || ((locationLng - owmCurrent["lon"]).abs() > 0.02);
	}
	
	
	function getHumidity() {
		return humidityFormatter.getValue();
	}
	
	function getWindSpeed() {
		return windSpeedFormatter.getValue();
	}
	
	function getWeatherIcon () {
		return weatherIconFormatter.getValue();
	}
	
	function getWeatherTemperature () {
		return temperatureFormatter.getValue();
	}

	// Sample invalid API key:
	/*
	{
		"cod":401,
		"message": "Invalid API key. Please see http://openweathermap.org/faq#error401 for more info."
	}
	*/

	// Sample current weather:
	/*
	{
		"coord":{
			"lon":-0.46,
			"lat":51.75
		},
		"weather":[
			{
				"id":521,
				"main":"Rain",
				"description":"shower rain",
				"icon":"09d"
			}
		],
		"base":"stations",
		"main":{
			"temp":281.82,
			"pressure":1018,
			"humidity":70,
			"temp_min":280.15,
			"temp_max":283.15
		},
		"visibility":10000,
		"wind":{
			"speed":6.2,
			"deg":10
		},
		"clouds":{
			"all":0
		},
		"dt":1540741800,
		"sys":{
			"type":1,
			"id":5078,
			"message":0.0036,
			"country":"GB",
			"sunrise":1540709390,
			"sunset":1540744829
		},
		"id":2647138,
		"name":"Hemel Hempstead",
		"cod":200
	}
	*/

	class AbstractWeatherFieldFormatter {
	
		function getDefaultValue() {
			return "";
		}
	
		function getFieldName() {
			return "";
		}
		
		function getNoGpsValue() {
			return "gps?";
		}
		
		function getPendingRequestValue() {
			return "...";
		}
	
		function formatField(value) {
			return value;
		}
	
		function getValue() {
			var value = getDefaultValue();
			
			if (App has :Storage) {
				var weather = App.Storage.getValue("OpenWeatherMapCurrent");
	
				// Awaiting location.
				if (gLocationLat == -360.0) { // -360.0 is a special value, meaning "unitialised". Can't have null float property.
					value = getNoGpsValue();
				// Stored weather data available.
				} else if ((weather != null) && (weather[getFieldName()] != null)) {
					value = formatField(weather[getFieldName()]);
				// Awaiting response.
				} else if (App.Storage.getValue("PendingWebRequests")["OpenWeatherMapCurrent"]) {
					value = getPendingRequestValue();
				}
			}
			
			return value;
		}
	}

	class HumidityFieldFormatter extends AbstractWeatherFieldFormatter {
	
		function initialize() {
			AbstractWeatherFieldFormatter.initialize();
		}
	
		function getFieldName() {
			return "humidity";
		}
		
		function formatField(value) {
			return value.format(INTEGER_FORMAT) + "%";
		}
	}
	
	class TemperatureFieldFormatter extends AbstractWeatherFieldFormatter {
	
		function initialize() {
			AbstractWeatherFieldFormatter.initialize();
		}
	
		function getFieldName() {
			return "temp";
		}
		
		function formatField(value) {
			return Math.round(value).format(INTEGER_FORMAT) + "°";
		}
	}
	
	class WeatherIconFormatter extends AbstractWeatherFieldFormatter {
	
		function initialize() {
			AbstractWeatherFieldFormatter.initialize();
		}
	
		function getFieldName() {
			return "icon";
		}
		
		// Default = sunshine!
		function getDefaultValue() {
			return "01d";
		}
		
		function getNoGpsValue() {
			return "01d";
		}
		
		function getPendingRequestValue() {
			return "01d";
		}
	}
	
	class WindSpeedFieldFormatter extends AbstractWeatherFieldFormatter {
	
		function initialize() {
			AbstractWeatherFieldFormatter.initialize();
		}
	
		function getFieldName() {
			return "wind-speed";
		}
		
		function formatField(value) {
			return Math.round(value).format(INTEGER_FORMAT);
		}
	}
}

