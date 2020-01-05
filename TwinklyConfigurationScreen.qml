import QtQuick 2.1
import qb.components 1.0
import BxtClient 1.0

Screen {
	id: twinklyConfigurationScreen

	function saveTwinklyHostname(text) {
		if (text) {
			app.hostName = text;
			twinklyHostnameLabel.inputText = app.hostName;
			app.twinklyLoaded = false;
			app.loginTwinkly("getTwinklyDetails");
			app.saveSettings();
		}
	}
	function saveTwinklyDeviceName(text) {
		if (text) {
			app.newDeviceName = text;
			twinklyDeviceNameLabel.inputText = text;
			app.loginTwinkly("renameTwinkly");
			app.saveSettings();
		}
	}

	screenTitle: "Twinkly lampjes configuratie"

	onShown: {
		twinklyHostnameLabel.inputText = app.hostName;
		twinklyDeviceNameLabel.inputText = app.twinklyDetails['device_name'];
		enableSystrayToggle.isSwitchedOn = app.enableSystray;
		if (app.hostName.length > 5) app.loginTwinkly("getTwinklyDetails");
	}

	Text {
		id: title
		x: 30
		y: 10
		text: "Invoeren Twinkly ip-adres of hostname:"
		font.pixelSize: 24
		font.family: qfont.semiBold.name
	}

	EditTextLabel4421 {
		id: twinklyHostnameLabel
		width: isNxt ? 550 : 440 
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 350 : 280
		leftText: "IP-adres:"

		anchors {
			left: title.left
			top: title.bottom
			topMargin: 6
		}

		onClicked: {
			qkeyboard.open("Voer ip-adres in (voorbeeld: 192.168.1.12)", twinklyHostnameLabel.inputText, saveTwinklyHostname)
		}
	}

	IconButton {
		id: twinklyHostnameLabelButton;
		width: 40
		iconSource: "qrc:/tsc/edit.png"

		anchors {
			left: twinklyHostnameLabel.right
			leftMargin: 6
			top: title.bottom
			topMargin: 6
		}

		bottomClickMargin: 3
		onClicked: {
			qkeyboard.open("Voer ip-adres in (voorbeeld: 192.168.1.12)", twinklyHostnameLabel.inputText, saveTwinklyHostname)
		}
	}


	Text {
		id: connectedLabel
		anchors {
			left: twinklyHostnameLabelButton.right
			leftMargin: isNxt ? 15 : 12
			top: title.bottom
			topMargin: 6
		}
		text: app.twinklyLoaded ? "     (Twinkly gevonden!)" : "     (Twinkly niet gevonden)"
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 25 : 20
	}

	EditTextLabel4421 {
		id: twinklyDeviceNameLabel
		width: isNxt ? 450 : 360
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 250 : 200
		leftText: "Naam Twinkly:"

		anchors {
			left: title.left
			leftMargin: isNxt ? 100 : 80
			top: twinklyHostnameLabelButton.bottom
			topMargin: 6
		}

		onClicked: {
			qkeyboard.open("Voer nieuwe naam Twinkly in", twinklyDeviceNameLabel.inputText, saveTwinklyDeviceName)
		}
		visible: app.twinklyLoaded
	}

	IconButton {
		id: twinklyDeviceNameLabelButton;
		width: 40
		iconSource: "qrc:/tsc/edit.png"

		anchors {
			left: twinklyDeviceNameLabel.right
			leftMargin: 6
			top: twinklyHostnameLabelButton.bottom
			topMargin: 6
		}

		bottomClickMargin: 3
		visible: app.twinklyLoaded
		onClicked: {
			qkeyboard.open("Voer nieuwe naam in voor de Twinkly", twinklyDeviceNameLabel.inputText, saveTwinklyDeviceName)
		}
	}


	Text {
		id: numberOfLedsLabel
		anchors {
			left: twinklyDeviceNameLabel.left
			top: twinklyDeviceNameLabel.bottom
			topMargin: 6
		}
		text: "Aantal LED's:"
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 25 : 20
		visible: app.twinklyLoaded
	}

	Text {
		id: numberOfLeds
		anchors {
			left: twinklyDeviceNameLabel.left
			leftMargin: isNxt ? 200 : 160
			top: twinklyDeviceNameLabel.bottom
			topMargin: 6
		}
		text: app.twinklyDetails['number_of_led']
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 25 : 20
		visible: app.twinklyLoaded
	}

	Text {
		id: productcodeLabel
		anchors {
			left: numberOfLedsLabel.left
			top: numberOfLedsLabel.bottom
			topMargin: 6
		}
		text: "Product code:"
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 25 : 20
		visible: app.twinklyLoaded
	}

	Text {
		id:  productcode
		anchors {
			left: productcodeLabel.left
			leftMargin: isNxt ? 200 : 160
			top: numberOfLedsLabel.bottom
			topMargin: 6
		}
		text: app.twinklyDetails['product_code']
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 25 : 20
		visible: app.twinklyLoaded
	}

	Text {
		id: enableSystrayLabel
		width: isNxt ? 200 : 160
		height: isNxt ? 45 : 36
		text: "Icon in systray"
		font.family: qfont.semiBold.name
		font.pixelSize: isNxt ? 25 : 20
		anchors {
			left: title.left
			top: productcodeLabel.bottom
			topMargin: isNxt ? 50 : 40
		}
	}

	OnOffToggle {
		id: enableSystrayToggle
		height: isNxt ? 45 : 36
		anchors.left: enableSystrayLabel.right
		anchors.leftMargin: 10
		anchors.top: enableSystrayLabel.top
		leftIsSwitchedOn: false
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				app.enableSystray = true;
			} else {
				app.enableSystray = false;
			}
			app.saveSettings();
		}
	}


}
