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
	property url twinklyTileUrl : "TwinklyTile.qml"
	property url thumbnailIcon: "qrc:/tsc/DomoticzSystrayIcon.png"

	//Edit these settings:
	property string hostName: "192.168.2.100"
	//Stop editing here!

	property string switch1Name
	property string authenticationToken
	property string challengeResponse 
	property variant twinklyDetails
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

	function init() {
		registry.registerWidget("systrayIcon", trayUrl, this, "twinklyTray");
		registry.registerWidget("screen", twinklyScreenUrl, this);
		registry.registerWidget("screen", twinklyConfigurationScreenUrl, this, "twinklyConfigurationScreen");
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
		
		} catch(e) {
		}
		loginTwinkly("getTwinklyDetails");
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
			"timerStop" : timerStop
		}

  		var doc3 = new XMLHttpRequest();
   		doc3.open("PUT", "file:///mnt/data/tsc/twinkly.userSettings.json");
   		doc3.send(JSON.stringify(tmpUserSettingsJson ));
	}

	function loginTwinkly(action) {

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open("POST", "http://"+hostName+"/xled/v1/login", true);
		var postData = '{"challenge":"AAAAAAAAAAAAAAAAAAAAAAAA"}';
		xmlhttp.setRequestHeader('Content-Type', 'application/json');
		xmlhttp.onreadystatechange=function() {
			if (xmlhttp.readyState == 4) {
				if (xmlhttp.status == 200) {
					var temp = JSON.parse(xmlhttp.responseText);
					authenticationToken = temp["authentication_token"];
					challengeResponse = temp["challenge-response"];
					verifyTwinkly(action);
				}
			}
		}
		xmlhttp.send(postData);
	}

	function verifyTwinkly(action) {

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
					if (action == "getTwinklyDetails") {
						getTwinklyDetails();
						getTwinklyStatus();
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
				}
			}
		}
		xmlhttp2.send(postData2);
	}

	function resetIcon() {

		if (twinklyLit) {
			switch1StatusIcon = "qrc:/tsc/LightBulbOn.png";
			} else {
			switch1StatusIcon = "qrc:/tsc/LightBulbOff.png";
		}
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
					twinklyLit = true;
					resetIcon();
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
					twinklyLit = false;
					resetIcon();
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
					console.log("Twinkly response:" + xmlhttp2.responseText);
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
