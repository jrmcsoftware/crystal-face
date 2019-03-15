using Toybox.System as Sys;
using Toybox.Application as App;

module WeatherService {
	function getUnits() {
		var units;	
		
		if (Sys.getDeviceSettings().temperatureUnits == System.UNIT_METRIC) {
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
	
	function isWeatherDataStale() {
		var weather = App.Storage.getValue("OpenWeatherMapCurrent");
		
		return ((weather == null) || 
				(weather["dt"] == null) ||
				(Time.now().value() > (weather["dt"] + 1800)));
	}
	
	function isLocationDifferent(locationLat, locationLng) {
		var owmCurrent = App.Storage.getValue("OpenWeatherMapCurrent");
		
		return ((locationLat - owmCurrent["lat"]).abs() > 0.02) || ((locationLng - owmCurrent["lon"]).abs() > 0.02);
	}
	
	function getHumidity() {
		var value = "";
		
		if (App has :Storage) {
			var weather = App.Storage.getValue("OpenWeatherMapCurrent");
	
			// Awaiting location.
			if (gLocationLat == -360.0) { // -360.0 is a special value, meaning "unitialised". Can't have null float property.
				value = "gps?";
	
			// Stored weather data available.
			} else if ((weather != null) && (weather["humidity"] != null)) {
				var humidity = weather["humidity"];
	
				value = humidity.format(INTEGER_FORMAT) + "%";
	
			// Awaiting response.
			} else if (App.Storage.getValue("PendingWebRequests")["OpenWeatherMapCurrent"]) {
				value = "...";
			}
		}
		
		return value;
	}
	
	function getWindSpeed() {
		var value = "";
		
		if (App has :Storage) {
			var weather = App.Storage.getValue("OpenWeatherMapCurrent");

			// Awaiting location.
			if (gLocationLat == -360.0) { // -360.0 is a special value, meaning "unitialised". Can't have null float property.
				value = "gps?";

			// Stored weather data available.
			} else if ((weather != null) && (weather["wind-speed"] != null)) {
				var windSpeed = Math.round(weather["wind-speed"]);
				
				value = windSpeed.format(INTEGER_FORMAT);

			// Awaiting response.
			} else if (App.Storage.getValue("PendingWebRequests")["OpenWeatherMapCurrent"]) {
				value = "...";
			}
		}
		
		return value;
	}
	
	function getWeatherIcon () {	
		// Default = sunshine!
		var value = "01d";

		if (App has :Storage) {
			var weather = App.Storage.getValue("OpenWeatherMapCurrent");

			// Awaiting location.
			if (gLocationLat == -360.0) { // -360.0 is a special value, meaning "unitialised". Can't have null float property.

			// Stored weather data available.
			} else if ((weather != null) && (weather["icon"] != null)) {
				value = weather["icon"];
			}
		}
		
		return value;
	}
	
	function getWeatherTemperature () {
		var value = "";
		
		if (App has :Storage) {
			var weather = App.Storage.getValue("OpenWeatherMapCurrent");

			// Awaiting location.
			if (gLocationLat == -360.0) { // -360.0 is a special value, meaning "unitialised". Can't have null float property.
				value = "gps?";

			// Stored weather data available.
			} else if ((weather != null) && (weather["temp"] != null)) {
				temperature = Math.round(weather["temp"]);

				value = temperature.format(INTEGER_FORMAT) + "°";
			// Awaiting response.
			} else if (App.Storage.getValue("PendingWebRequests")["OpenWeatherMapCurrent"]) {
				value = "...";
			}
		}
		
		return value;
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
}