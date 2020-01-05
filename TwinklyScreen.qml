import QtQuick 2.1

import qb.components 1.0

Screen {
	id: root

	screenTitle: "Twinkly Kerstverlichting"

	onShown: {
		addCustomTopRightButton("Instellingen");
		timerStartLabel.inputText = app.timerStart;
		timerStopLabel.inputText = app.timerStop;
	}

	onCustomButtonClicked: {
		if (app.twinklyConfigurationScreen) {
			 app.twinklyConfigurationScreen.show();
		}
	}

	function saveTimerStart(text) {
		if (text) {
			app.timerStart = text;
			timerStartLabel.inputText = text;
			app.saveSettings();
		}
	}
	
	function saveTimerStop(text) {
		if (text) {
			app.timerStop = text;
			timerStopLabel.inputText = text;
			app.saveSettings();
		}
	}

	StandardButton {
		id: switch1Button
		width: isNxt ? 75 : 60
		text: "Uit"
        	anchors {
            		top: parent.top
            		topMargin: 50
			verticalCenter: switch1Button.verticalCenter
			left:switch1Title.right
            		leftMargin: 50
        	}
		leftClickMargin: 3
		bottomClickMargin: 5
		onClicked: {
			app.loginTwinkly("switchOff");
		}
	}

	StandardButton {
		id: switch2Button
		width: isNxt ? 75 : 60
		text: "Aan"
        	anchors {
            		top: parent.top
            		topMargin: 50
			verticalCenter: switch2Button.verticalCenter
			left:switch1Button.right
            		leftMargin: isNxt ? 15 : 12
        	}
		leftClickMargin: 3
		bottomClickMargin: 5
		onClicked: {
			app.loginTwinkly("switchOn");
		}
	}

	Text {
        	id: switch1Title
		height: switch1Button.height
        	anchors {
            		top: parent.top
            		topMargin: 55
            		left: parent.left
            		leftMargin: 10
        	}
        	font {
            		family: qfont.semiBold.name
            		pixelSize: 20
        	}
	        text: "Twinkly lampjes: " + app.twinklyDetails['device_name'] 
	}

	StandardButton {
		id: demoButton
		width: isNxt ? 200 : 160
		text: "Lichtjesdemo"
        	anchors {
            		top: setTimerTitle.bottom
            		topMargin: 50
			left:parent.left
            		leftMargin: 50
        	}
		leftClickMargin: 3
		bottomClickMargin: 5
		onClicked: {
			app.loginTwinkly("demo");
		}
	}

	Text {
        	id: setTimerTitle
		height: switch1Button.height
        	anchors {
            		top: switch1Title.bottom
			topMargin: 20
            		left: parent.left
            		leftMargin: 10
        	}
        	font {
            		family: qfont.semiBold.name
            		pixelSize: 20
        	}
	        text: "Twinkly timerfunctie: " 
	}

	EditTextLabel4421 {
		id: timerStartLabel
		width: isNxt ? 250 : 200
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 175 : 140
		leftText: "start (hhmm):"

		anchors {
			left:switch1Title.right
            		leftMargin: 50
			top: setTimerTitle.top
		}

		onClicked: {
			qkeyboard.open("Starttijd (hhmm)", timerStartLabel.inputText, saveTimerStart)
		}
	}


	EditTextLabel4421 {
		id: timerStopLabel
		width: isNxt ? 250 : 200
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 175 : 140
		leftText: "stop (hhmm):"

		anchors {
			left: timerStartLabel.right
			leftMargin: isNxt ? 20 : 16
			top: timerStartLabel.top
		}

		onClicked: {
			qkeyboard.open("Stoptijd (hhmm)", timerStopLabel.inputText, saveTimerStop)
		}
	}

	StandardButton {
		id: activateTimer
		width: isNxt ? 125 : 100
		text: "Start Timer"
        	anchors {
            		top: timerStopLabel.top
			left:timerStopLabel.right
            		leftMargin: 10
        	}
		leftClickMargin: 3
		bottomClickMargin: 5
		onClicked: {
			app.loginTwinkly("activateTimer");
		}
	}

}
