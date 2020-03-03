import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0

App {
	id: root

	property url trayUrl : "TwinklyTray.qml";
	property url twinklyScreenUrl : "TwinklyScreen.qml"
	property url twinklyConfigurationScreenUrl : "TwinklyConfigurationScreen.qml"
	property TwinklyConfigurationScreen twinklyConfigurationScreen
	property url twinklySelectColorScreenUrl : "TwinklySelectColorScreen.qml"
	property TwinklySelectColorScreen twinklySelectColorScreen
	property url twinklyTileUrl : "TwinklyTile.qml"
	property url thumbnailIcon: "qrc:/tsc/DomoticzSystrayIcon.png"

	//Edit these settings:
	property string hostName
	//Stop editing here!

	property string switch1Name
	property string authenticationToken
	property string challengeResponse 
	property variant twinklyDetails : {
		'device_name': "",
		'product_code': "",
		'number_of_led': 1
	}

	property string newDeviceName
	property bool twinklyLoaded : false
	property variant twinklySettingsJson
	property bool enableSystray
	property string timerStart : "2200"
	property string timerStop : "0700" 
	property string tilebulb_offvar: "qrc:/tsc/TileLightBulbOff.png";
	property string tilebulb_onvar: "qrc:/tsc/TileLightBulbOn.png";
	property string dimtilebulb_offvar: "qrc:/tsc/DimTileLightBulbOff.png";
	property string dimtilebulb_onvar: "qrc:/tsc/DimTileLightBulbOn.png";
	property string twinklyStatusIcon
	property bool twinklyLit : false
	property bool singleColorGlow : false
	property bool singleRandomColorGlow : false
	property int movieFrames
	property int singleGlowAmplitude : 50
	property int trainLength : 50
 	property int movieDelay : 83 
 	property int movieCounter : 1 
 	property variant movieNames : [] 
 	property int selectedFavourite : 0 

	property int colorR
	property int colorG
	property int colorB
	property string selectedColor

	function init() {
		registry.registerWidget("systrayIcon", trayUrl, this, "twinklyTray");
		registry.registerWidget("screen", twinklyScreenUrl, this);
		registry.registerWidget("screen", twinklyConfigurationScreenUrl, this, "twinklyConfigurationScreen");
		registry.registerWidget("screen", twinklySelectColorScreenUrl, this, "twinklySelectColorScreen");
		registry.registerWidget("tile", twinklyTileUrl, this, null, {thumbLabel: "Twinkly", thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
	}

	FileIO {
		id: twinklySettingsFile
		source: "file:///mnt/data/tsc/twinkly.userSettings.json"
 	}

	Component.onCompleted: {
		// read user settings

		enableSystray = true
		try {
			twinklySettingsJson = JSON.parse(twinklySettingsFile.read());
			hostName = twinklySettingsJson['hostName'];
			if (twinklySettingsJson['TrayIcon'] == "Yes") {
				enableSystray = true
			} else {
				enableSystray = false
			}
			timerStart = twinklySettingsJson['timerStart'];
			timerStop = twinklySettingsJson['timerStop'];
			singleGlowAmplitude = twinklySettingsJson['singleGlowAmplitude'];
			movieDelay = twinklySettingsJson['movieDelay'];
			movieCounter = twinklySettingsJson['movieCounter'];
			movieNames = twinklySettingsJson['movieNames'];
			trainLength = twinklySettingsJson['trainLength'];
		
		} catch(e) {
			saveSettings();
		}
		loginTwinkly("getTwinklyDetails");
	}

        function randomStr(len) { 
            var ranStr = ''; 
	    var arr = "abcdefghijklmnopqrstuvwxyz0123456789";
            for (var i = len; i > 0; i--) { 
                ranStr +=  
                  arr[Math.floor(Math.random() * arr.length)]; 
            } 
            return ranStr; 
        } 
  
	function saveSettings() {
		
		// save user settings

		var tmpTrayIcon = "";
		if (enableSystray == true) {
			tmpTrayIcon = "Yes";
		} else {
			tmpTrayIcon = "No";
		}

 		var tmpUserSettingsJson = {
			"hostName" : hostName,
			"TrayIcon" : tmpTrayIcon,
			"timerStart" : timerStart,
			"timerStop" : timerStop,
			"singleGlowAmplitude" : singleGlowAmplitude,
			"movieDelay" : movieDelay,
			"movieCounter" : movieCounter,
			"movieNames" : movieNames,
			"trainLength" : trainLength
		}

  		var doc3 = new XMLHttpRequest();
   		doc3.open("PUT", "file:///mnt/data/tsc/twinkly.userSettings.json");
   		doc3.send(JSON.stringify(tmpUserSettingsJson ));
	}

	function loginTwinkly(action) {

		console.log("Twinkly login:" + action);
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open("POST", "http://"+hostName+"/xled/v1/login", true);
		var postData = '{"challenge":"' + randomStr(24) + '"}';
		console.log("Twinkly login challenge:" + postData);
		xmlhttp.setRequestHeader('Content-Type', 'application/json');
		xmlhttp.onreadystatechange=function() {
			if (xmlhttp.readyState == 4) {
				if (xmlhttp.status == 200) {
					var temp = JSON.parse(xmlhttp.responseText);
					authenticationToken = temp["authentication_token"];
					challengeResponse = temp["challenge-response"];
					console.log("Twinkly login response:" + xmlhttp.responseText);
					verifyTwinkly(action);
				}
			}
		}
		xmlhttp.send(postData);
	}

	function verifyTwinkly(action) {

		console.log("Twinkly verify:" + action);
		var xmlhttp2 = new XMLHttpRequest();
		xmlhttp2.open("POST", "http://"+hostName+"/xled/v1/verify", true);
		var postData2 = '{"challenge_response":"' + challengeResponse + '"}';

		xmlhttp2.setRequestHeader('X-Auth-Token', authenticationToken);
		xmlhttp2.setRequestHeader('Content-Type', 'application/json');
		xmlhttp2.onreadystatechange=function() {
			if (xmlhttp2.readyState == 4) {
				if (xmlhttp2.status == 200) {
					twinklyLoaded = true;
					if (action == "switchOn") {
						switchTwinklyOn();
					}
					if (action == "switchOff") {
						switchTwinklyOff();
					}
					if (action == "switchRt") {
						switchTwinklyRt();
					}
					if (action == "getTwinklyDetails") {
						getTwinklyDetails();
//						getTwinklyStatus();
					}
					if (action == "renameTwinkly") {
						renameTwinkly();
					}
					if (action == "demo") {
						demoTwinkly();
					}
					if (action == "activateTimer") {
						activateTimer();
					}
					if (action == "sendMovie") {
						sendMovie();
					}
					if (action == "sendMovieConfig") {
						sendMovieConfig();
					}
					if (action == "sendColor") {
						sendColor();
					}
					if (action == "sendTrain") {
						sendTrain();
					}
					if (action == "getStatus") {
						getStatus();
					}
				}
			}
		}
		xmlhttp2.send(postData2);
	}

	function switchTwinklyRt() {
		var xmlhttp2 = new XMLHttpRequest();
		xmlhttp2.open("POST", "http://"+hostName+"/xled/v1/led/mode", true);
		var postData = '{"mode":"rt"}';
		xmlhttp2.setRequestHeader('Content-Type', 'application/json');
		xmlhttp2.setRequestHeader('X-Auth-Token', authenticationToken);
		xmlhttp2.onreadystatechange=function() {
			if (xmlhttp2.readyState == 4) {
				if (xmlhttp2.status == 200) {
					console.log("Twinkly rt:" + xmlhttp2.responseText);
					twinklyLit = true;
				}
			}
		}
		xmlhttp2.send(postData);
	}

	function switchTwinklyOn() {
		var xmlhttp2 = new XMLHttpRequest();
		xmlhttp2.open("POST", "http://"+hostName+"/xled/v1/led/mode", true);
		var postData = '{"mode":"movie"}';
		xmlhttp2.setRequestHeader('Content-Type', 'application/json');
		xmlhttp2.setRequestHeader('X-Auth-Token', authenticationToken);
		xmlhttp2.onreadystatechange=function() {
			if (xmlhttp2.readyState == 4) {
				if (xmlhttp2.status == 200) {
					console.log("Twinkly On:" + xmlhttp2.responseText);
					twinklyLit = true;
				}
			}
		}
		xmlhttp2.send(postData);
	}

	function switchTwinklyOff() {
		var xmlhttp2 = new XMLHttpRequest();
		xmlhttp2.open("POST", "http://"+hostName+"/xled/v1/led/mode", true);
		var postData = '{"mode":"off"}';
		xmlhttp2.setRequestHeader('Content-Type', 'application/json');
		xmlhttp2.setRequestHeader('X-Auth-Token', authenticationToken);
		xmlhttp2.onreadystatechange=function() {
			if (xmlhttp2.readyState == 4) {
				if (xmlhttp2.status == 200) {
					console.log("Twinkly Off:" + xmlhttp2.responseText);
					twinklyLit = false;
				}
			}
		}
		xmlhttp2.send(postData);
	}

	function activateTimer() {
		var currentTime = new Date();
		var timerStartParm = (parseInt(timerStart.substring(2,4)) * 60) + (parseInt(timerStart.substring(0,2)) * 3600);
		var timerStopParm = (parseInt(timerStop.substring(2,4)) * 60) + (parseInt(timerStop.substring(0,2)) * 3600);
		var timerNowParm = (currentTime.getMinutes() * 60) + (currentTime.getHours() * 3600) + currentTime.getSeconds();
		var xmlhttp2 = new XMLHttpRequest();
		xmlhttp2.open("POST", "http://"+hostName+"/xled/v1/timer", true);
		var postData = '{"time_on":' + timerStartParm + ',"time_off":' + timerStopParm + ',"time_now":' + timerNowParm + '}';
		console.log("Twinkly timer data (" + currentTime + "):" + postData);
		xmlhttp2.setRequestHeader('Content-Type', 'application/json');
		xmlhttp2.setRequestHeader('X-Auth-Token', authenticationToken);
		xmlhttp2.onreadystatechange=function() {
			if (xmlhttp2.readyState == 4) {
				if (xmlhttp2.status == 200) {
					console.log("Twinkly Start Timer:" + xmlhttp2.responseText);
				}
			}
		}
		xmlhttp2.send(postData);
	}

	function demoTwinkly() {
		var xmlhttp2 = new XMLHttpRequest();
		xmlhttp2.open("POST", "http://"+hostName+"/xled/v1/led/mode", true);
		var postData = '{"mode":"demo"}';
		xmlhttp2.setRequestHeader('Content-Type', 'application/json');
		xmlhttp2.setRequestHeader('X-Auth-Token', authenticationToken);
		xmlhttp2.send(postData);
	}

	function renameTwinkly() {
		var xmlhttp2 = new XMLHttpRequest();
		xmlhttp2.open("POST", "http://"+hostName+"/xled/v1/device_name", true);
		var postData = '{"name":"' + newDeviceName + '"}';
		xmlhttp2.setRequestHeader('Content-Type', 'application/json');
		xmlhttp2.setRequestHeader('X-Auth-Token', authenticationToken);
		xmlhttp2.onreadystatechange=function() {
			if (xmlhttp2.readyState == 4) {
				getTwinklyDetails();
			}
		}

		xmlhttp2.send(postData);
	}

	function sendMovie() {

		console.log("Twinkly send movie " + selectedFavourite);
		var xhr = new XMLHttpRequest();
		xhr.open('GET', "file:///mnt/data/tsc/appData/twinkly.movie." + selectedFavourite + ".dat" , true);
		xhr.responseType = 'arraybuffer';
		xhr.onreadystatechange=function() {
			console.log("Twinkly send movie State-status:" + xhr.readyState + "/" + xhr.status);
			if (xhr.readyState == 4) {
				if (xhr.status == 200) {
					var xmlhttp2 = new XMLHttpRequest();
					xmlhttp2.open("POST", "http://"+hostName+"/xled/v1/led/movie/full", true);
					xmlhttp2.setRequestHeader('Content-Type', 'application/octet-stream');
					xmlhttp2.setRequestHeader('X-Auth-Token', authenticationToken);
					xmlhttp2.onreadystatechange=function() {
						if (xmlhttp2.readyState == 4) {
							console.log("Twinkly send movie data:" + xmlhttp2.responseText);
							var temp = JSON.parse(xmlhttp2.responseText);
							movieFrames = temp["frames_number"];
							console.log("Send config");
							loginTwinkly("sendMovieConfig");
						}
					}
					xmlhttp2.send(xhr.response);
		   		}
			}
		}
		xhr.send();
	}

	function saveEffect(movieName) {

		var xhr = new XMLHttpRequest();
		xhr.open('GET', "file:///mnt/data/tsc/appData/twinkly.movie.0.dat" , true);
		xhr.responseType = 'arraybuffer';
		xhr.onreadystatechange=function() {
			if (xhr.readyState == 4) {
				if (xhr.status == 200) {
					console.log("Twinkly write movie file:///mnt/data/tsc/appData/twinkly.movie." + movieCounter + ".dat");

					var xmlhttp2 = new XMLHttpRequest();
					xmlhttp2.open("PUT", "file:///mnt/data/tsc/appData/twinkly.movie." + movieCounter + ".dat", true);
					xmlhttp2.send(xhr.response);
					movieNames.push(movieName + "@" + movieCounter);
					movieCounter = movieCounter + 1;
					saveSettings();
		   		}
			}
		}
		xhr.send();
	}

	function sendMovieConfig() {
		var xmlhttp2 = new XMLHttpRequest();
		xmlhttp2.open("POST", "http://"+hostName+"/xled/v1/led/movie/config", true);
		var postData = '{"frame_delay":' + movieDelay + ',"leds_number":175,"frames_number":' + movieFrames + '}';
		xmlhttp2.setRequestHeader('Content-Type', 'application/json');
		xmlhttp2.setRequestHeader('X-Auth-Token', authenticationToken);
		xmlhttp2.onreadystatechange=function() {
			if (xmlhttp2.readyState == 4) {
				if (xmlhttp2.status == 200) {
					console.log("Twinkly send movie config:" + xmlhttp2.responseText);
					twinklyLit = true;
					switchTwinklyOn();
				}
			}
		}
		xmlhttp2.send(postData);
	}

	function sendColor() {

		var offSet = 0;
		var offSetR = 0;
		var offSetG = 0;
		var offSetB = 0;
		if (!singleColorGlow) {

				// single fixed color, create 2 movieframes

			var buffer = new ArrayBuffer(twinklyDetails['number_of_led'] * 3);
			var postData = new Uint8Array(buffer);
			for (var i = 0; i < twinklyDetails['number_of_led']; i++) {
				postData[i * 3] = colorR;
				postData[(i * 3) + 1] = colorG;
				postData[(i * 3) + 2] = colorB;
			}
		} else {
			var numberOfGlowPoints = 50;
			var offsetArray = new Array(numberOfGlowPoints)

				// build offset array for glow effect

			for (var i=0; i < (offsetArray.length / 2); i++) {
				offsetArray[i] = (singleGlowAmplitude / (numberOfGlowPoints / 2)) * i;
				offsetArray[offsetArray.length - i] = (singleGlowAmplitude / (numberOfGlowPoints /2)) * i;
			}


			var numberOfFrames = offsetArray.length;
			var buffer = new ArrayBuffer(twinklyDetails['number_of_led'] * 3 * numberOfFrames);
			var postData = new Uint8Array(buffer);

			if (singleRandomColorGlow) {  // fill random array with glowindex
				var singleLedGlow = new Array(twinklyDetails['number_of_led']);
				for (var i = 0; i < twinklyDetails['number_of_led']; i++) {
					singleLedGlow[i] = Math.floor(Math.random() * offsetArray.length);
				}
			}
			for (var actualFrame = 0; actualFrame < numberOfFrames; actualFrame++) {
				if (!singleRandomColorGlow) {
					offSet = offsetArray[actualFrame];
				}
				for (var i = twinklyDetails['number_of_led'] * actualFrame; i < twinklyDetails['number_of_led'] * (actualFrame + 1); i++) {
					if (singleRandomColorGlow) {
						offSet = offsetArray[singleLedGlow[i % twinklyDetails['number_of_led']]];
						singleLedGlow[i % twinklyDetails['number_of_led']] = (singleLedGlow[i % twinklyDetails['number_of_led']] + 1) % offsetArray.length;
					}

					// reduce offset if LED is not at full power
					offSetR = Math.floor((colorR / 128) * offSet);		
					offSetG = Math.floor((colorG / 128) * offSet);		
					offSetB = Math.floor((colorB / 128) * offSet);		

					postData[i * 3] = ((colorR + offSetR) > 255) ? 255 : colorR + offSetR;
					postData[(i * 3) + 1] =((colorG + offSetG) > 255) ? 255 : colorG + offSetG;
					postData[(i * 3) + 2] = ((colorB + offSetB) > 255) ? 255 : colorB + offSetB;
				}
			}
		}

  		var doc3 = new XMLHttpRequest();
   		doc3.open("PUT", "file:///mnt/data/tsc/appData/twinkly.movie.0.dat");
		doc3.onreadystatechange=function() {
			if (doc3.readyState == 4) {
				selectedFavourite = 0;
				sendMovie();
			}
		}

   		doc3.send(buffer);
	}

	function sendTrain() {

		var numberOfFrames = twinklyDetails['number_of_led'];
		var buffer = new ArrayBuffer(twinklyDetails['number_of_led'] * 3 * numberOfFrames);
		var postData = new Uint8Array(buffer);

		// fill frames

		for (var actualFrame = 0; actualFrame < (numberOfFrames - 1); actualFrame++) {
			for (var i = 0; i < trainLength; i++) {
				postData[(((twinklyDetails['number_of_led'] * actualFrame) + i + actualFrame) * 3)] = colorR;
				postData[(((twinklyDetails['number_of_led'] * actualFrame) + i + actualFrame) * 3) + 1] = colorG;
				postData[(((twinklyDetails['number_of_led'] * actualFrame) + i + actualFrame) * 3) + 2] = colorB;
			}
		}

  		var doc3 = new XMLHttpRequest();
   		doc3.open("PUT", "file:///mnt/data/tsc/appData/twinkly.movie.0.dat");
		doc3.onreadystatechange=function() {
			if (doc3.readyState == 4) {
				selectedFavourite = 0;
				sendMovie();
			}
		}

   		doc3.send(buffer);
	}

	function getTwinklyDetails() {
		var xmlhttp2 = new XMLHttpRequest();
		xmlhttp2.open("GET", "http://"+hostName+"/xled/v1/gestalt", true);
		xmlhttp2.onreadystatechange=function() {
			if (xmlhttp2.readyState == 4) {
				if (xmlhttp2.status == 200) {
					twinklyDetails = JSON.parse(xmlhttp2.responseText);
				}
			}
		}
		xmlhttp2.send();
	}

	
}
