using Toybox.Background as Bg;
using Toybox.System as Sys;
using Toybox.Communications as Comms;
using Toybox.Application as App;

(:background)
class BackgroundService extends Sys.ServiceDelegate {

	var weather = new WeatherService();
	
	function initialize() {
		Sys.ServiceDelegate.initialize();
	}

	// Read pending web requests, and call appropriate web request function.
	// This function determines priority of web requests, if multiple are pending.
	// Pending web request flag will be cleared only once the background data has been successfully received.
	function onTemporalEvent() {
		Sys.println("onTemporalEvent");
		var pendingWebRequests = App.Storage.getValue("PendingWebRequests");
		Sys.println("pendingWebRequests: " + pendingWebRequests);
		if (pendingWebRequests != null) {

			// 1. City local time.
			if (pendingWebRequests["CityLocalTime"] != null) {
				makeWebRequest(
					"https://script.google.com/macros/s/AKfycbwPas8x0JMVWRhLaraJSJUcTkdznRifXPDovVZh8mviaf8cTw/exec",
					{
						"city" => App.getApp().getProperty("LocalTimeInCity")
					},
					method(:onReceiveCityLocalTime)
				);

			// 2. Weather.
			} else if (pendingWebRequests["OpenWeatherMapCurrent"] != null) {
			// Assume that any watch that can make web requests, also supports App.Storage.
				Sys.println("about to request weather data");
				makeWebRequest(
					weather.getWeatherUrl(),
					weather.getWeatherParams(),
					method(:onReceiveOpenWeatherMapCurrent)
				);
			}
		} /* else {
			Sys.println("onTemporalEvent() called with no pending web requests!");
		} */
		
		Sys.println("end of onTemporalEvent()");
	}

	// Sample time zone data:
	/*
	{
	"requestCity":"london",
	"city":"London",
	"current":{
		"gmtOffset":3600,
		"dst":true
		},
	"next":{
		"when":1540688400,
		"gmtOffset":0,
		"dst":false
		}
	}
	*/

	// Sample error when city is not found:
	/*
	{
	"requestCity":"atlantis",
	"error":{
		"code":2, // CITY_NOT_FOUND
		"message":"City \"atlantis\" not found."
		}
	}
	*/
	function onReceiveCityLocalTime(responseCode, data) {

		// HTTP failure: return responseCode.
		// Otherwise, return data response.
		if (responseCode != 200) {
			data = {
				"httpError" => responseCode
			};
		}

		Bg.exit({
			"CityLocalTime" => data
		});
	}

	function onReceiveOpenWeatherMapCurrent(responseCode, data) {
		var result;
		
		// Useful data only available if result was successful.
		// Filter and flatten data response for data that we actually need.
		// Reduces runtime memory spike in main app.
		if (responseCode == 200) {
			result = weather.parseWeatherData(data);
		// HTTP error: do not save.
		} else {
			result = {
				"httpError" => responseCode
			};
		}

		Bg.exit({
			"OpenWeatherMapCurrent" => result
		});
	}

	function makeWebRequest(url, params, callback) {
		var options = {
			:method => Comms.HTTP_REQUEST_METHOD_GET,
			:headers => {
					"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
			:responseType => Comms.HTTP_RESPONSE_CONTENT_TYPE_JSON
		};

		Sys.println("makeWebRequest:");
		Sys.println("\t" + url);
		Sys.println("\t" + params);
		
		Comms.makeWebRequest(url, params, options, callback);
	}
}
