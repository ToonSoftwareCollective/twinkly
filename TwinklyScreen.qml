import QtQuick 2.11
import QtQuick.Layouts 1.11
import qb.components 1.0
import FileIO 1.0

Screen {
	id: root

	screenTitle: "Twinkly Kerstverlichting"
   	property int colorHandleRadius : 8
   	property bool showFavourites : true
  	property bool showTrainEffectGenerator: false 
  	property bool showGlowEffectGenerator: false 
 	property bool enableEffectSaveButton : false
 
	onShown: {
		addCustomTopRightButton("Instellingen");
		enableGlowToggle.isSwitchedOn = app.singleColorGlow;
		enableRandomGlowToggle.isSwitchedOn = app.singleRandomColorGlow;
		timerStartLabel.inputText = app.timerStart;
		timerStopLabel.inputText = app.timerStop;
		speedLabel.inputText = app.movieDelay;
		ampLabel.inputText = app.singleGlowAmplitude;
		trainLengthLabel.inputText = app.trainLength;
		fillEffectsList();
	}

	onCustomButtonClicked: {
		if (app.twinklyConfigurationScreen) {
			 app.twinklyConfigurationScreen.show();
		}
	}

	FileIO {
		id: filesToDeleteFile
		source: "file:///tmp/files_to_delete.txt"
 	}

	function fillEffectsList() {
		// fill favourites list
		favouritesScrollableSimpleList.removeAll();
		console.log("Twinkly fill listview: "+ app.movieNames.length);
		for (var i = 0; i < app.movieNames.length; i++) {
			favouritesScrollableSimpleList.addDevice(app.movieNames[i]);
			console.log("Twinkly fill add to listview: "+ app.movieNames[i]);
		}
		favouritesScrollableSimpleList.refreshView();
	}

	function displayEffectName(effectName) {
		console.log("Twinkly effect name display:" + effectName);
		if (effectName) {
			var temp = effectName.split("@");
			return temp[0];
		} else {
			return " ";
		}
	}

	function getEffectNumber(effectName) {
		var temp = effectName.split("@");
		return temp[1]
	}

	function saveTimerStart(text) {
		if (text) {
			app.timerStart = text;
			timerStartLabel.inputText = text;
			app.saveSettings();
		}
	}

	function removeEffect(item) {
		var i = app.movieNames.indexOf(item);
		if (i > -1) {
  			app.movieNames.splice(i, 1);
		}
		app.saveSettings();
		fillEffectsList();
		console.log("Twinkly removing file :" + "file:///mnt/data/tsc/appData/twinkly.movie." + getEffectNumber(item) + ".dat");
	
		var existingFilesToDelete = "";
		try {
			existingFilesToDelete = filesToDeleteFile.read();   //in case files are deleted in the gui quicker than the tsc scripts picks up
		} catch(e) {
		}
		
  		var doc2 = new XMLHttpRequest();
  		doc2.open("PUT", "file:///tmp/files_to_delete.txt");
 		doc2.send(existingFilesToDelete + " twinkly.movie." + getEffectNumber(item) + ".dat");
	
 		var doc4 = new XMLHttpRequest();
  		doc4.open("PUT", "file:///tmp/tsc.command");
   		doc4.send("deletefile");
	}

	function saveTimerStop(text) {
		if (text) {
			app.timerStop = text;
			timerStopLabel.inputText = text;
			app.saveSettings();
		}
	}
	
	function saveEffectName(text) {
		if (text) {
			saveEffectNameLabel.inputText = text;
		}
	}
	
	function saveAmp(text) {
		if (text) {
			app.singleGlowAmplitude = text;
			ampLabel.inputText = text;
			app.saveSettings();
		}
	}
	
	function saveTrainLength(text) {
		if (text) {
			app.trainLength = text;
			trainLengthLabel.inputText = text;
			app.saveSettings();
		}
	}
	
	function saveSpeed(text) {
		if (text) {
			app.movieDelay = text;
			speedLabel.inputText = text;
			app.saveSettings();
		}
	}

	Text {
        	id: switch1Title
		height: isNxt ? 45 : 36
        	anchors {
            		top: parent.top
            		left: parent.left
            		leftMargin: 10
        	}
        	font {
            		family: qfont.semiBold.name
            		pixelSize: 20
        	}
	        text: (app.twinklyDetails['device_name'].length > 2) ? "Twinkly lampjes: " + app.twinklyDetails['device_name'] : "Twinkly lampjes niet gevonden"
	}

	OnOffToggle {
		id: switchOnOff
		height: isNxt ? 45 : 36
		anchors.left: switch1Title.right
		anchors.leftMargin: isNxt ? 16 : 12
		anchors.top: switch1Title.top
		leftIsSwitchedOn: false
		visible: (app.twinklyDetails['device_name'].length > 2)
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				app.loginTwinkly("switchOn");
			} else {
				app.loginTwinkly("switchOff");
			}
		}
	}

	EditTextLabel4421 {
		id: timerStartLabel
		width: isNxt ? 400 : 320
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 325 : 260
		leftText: "timerfunctie start (hhmm):"

		anchors {
			left:switch1Title.left
			top: switchOnOff.bottom
	           	topMargin: isNxt ? 15 : 12
		}
		onClicked: {
			qkeyboard.open("Starttijd(hhmm)", timerStartLabel.inputText, saveTimerStart)
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
		text: "Start"
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

	StandardButton {
		id: favouritesButton
		width: isNxt ? 200 : 160
		text: "Favorieten"
        	anchors {
            		top: timerStartLabel.bottom
	           	topMargin: isNxt ? 15 : 12
			left:timerStartLabel.left
        	}
		leftClickMargin: 3
		bottomClickMargin: 5
		onClicked: {
			if (app.movieNames.length > 0) {
				fillEffectsList();
				showFavourites = true;
				showGlowEffectGenerator = false;
				showTrainEffectGenerator = false;
				pointerRect.anchors.top = favouritesButton.top
			} else {
				qdialog.showDialog(qdialog.SizeLarge, "Twinkly mededeling", "U heeft geen opgeslagen favorieten", "Sluiten");
			}
		}
	}

	StandardButton {
		id: effectGeneratorButton
		width: isNxt ? 200 : 160
		text: "Glow effect"
        	anchors {
            		top: favouritesButton.bottom
            		topMargin: isNxt ? 15 : 12
			left:favouritesButton.left
        	}
		leftClickMargin: 3
		bottomClickMargin: 5
		onClicked: {
			showFavourites = false;
			showGlowEffectGenerator = true;
			showTrainEffectGenerator = false;
			pointerRect.anchors.top = effectGeneratorButton.top
		}
	}


	StandardButton {
		id: trainEffectGeneratorButton
		width: isNxt ? 200 : 160
		text: "Trein Effect"
        	anchors {
            		top: effectGeneratorButton.bottom
            		topMargin: isNxt ? 15 : 12
			left:favouritesButton.left
        	}
		leftClickMargin: 3
		bottomClickMargin: 5
		onClicked: {
			showFavourites = false;
			showGlowEffectGenerator = false;
			showTrainEffectGenerator = true;
			pointerRect.anchors.top = trainEffectGeneratorButton.top
		}
	}

	Rectangle {
		id: borderRect
		width: isNxt ? 775 : 620
		height: isNxt ? 405 : 324
       		anchors {
            		top: favouritesButton.top
            		left: favouritesButton.right
            		leftMargin: isNxt ? 20 : 16
        	}
		color: "transparent"
		border.color: "white"
		border.width: isNxt ? 12 : 10
		radius: isNxt ? 12 : 10
	}

	Rectangle {
		id: pointerRect
		width: isNxt ? 30 : 24
		height: isNxt ? 12 : 10
       		anchors {
            		top: favouritesButton.top
			topMargin: isNxt ? 15 : 12
            		left: favouritesButton.right
        	}
		color: "transparent"
		border.color: "white"
		border.width: isNxt ? 12 : 10
		radius: isNxt ? 12 : 10
	}

	Text {
        	id: selectColorText
		height: isNxt ? 45 : 36
 		visible: showGlowEffectGenerator || showTrainEffectGenerator 
       		anchors {
            		top: borderRect.top
            		left: borderRect.left
            		leftMargin: isNxt ? 20 : 16
            		topMargin: isNxt ? 25 : 20
        	}
        	font {
            		family: qfont.semiBold.name
            		pixelSize: 20
        	}
	        text: "Selekteer een kleur:"
	}

	Rectangle {
		id: showColor
		width: isNxt ? 50 : 40
		height: isNxt ? 50 : 40
		color: app.selectedColor
		anchors.top: selectColorText.top
		anchors.left: selectColorText.right
		anchors.leftMargin: 30
		visible: showGlowEffectGenerator || showTrainEffectGenerator
	}

	IconButton {
		id: editColor
		width: 40
		iconSource: "qrc:/tsc/edit.png"

		anchors {
			left: showColor.right
			leftMargin: 6
			top: showColor.top
		}

		bottomClickMargin: 3
		visible: showGlowEffectGenerator || showTrainEffectGenerator
		onClicked: stage.openFullscreen(app.twinklySelectColorScreenUrl)
	}

	Text {
        	id: selectGlowText
		height: isNxt ? 45 : 36
		visible: showGlowEffectGenerator
        	anchors {
            		top: selectColorText.bottom
			topMargin: isNxt ? 20 : 16
            		left: selectColorText.left
        	}
        	font {
            		family: qfont.semiBold.name
            		pixelSize: 20
        	}
		text: "Gloei effect:"
	}

	OnOffToggle {
		id: enableGlowToggle
		height: isNxt ? 45 : 36
		anchors.left: selectGlowText.right
		anchors.leftMargin: 10
		anchors.top: selectGlowText.top
		leftIsSwitchedOn: false
		visible: showGlowEffectGenerator
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				app.singleColorGlow = true;
			} else {
				app.singleColorGlow = false;
			}
			app.saveSettings();
		}
	}

	EditTextLabel4421 {
		id: trainLengthLabel
		width: isNxt ? 250 : 200
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 175 : 140
		leftText: "Lengte trein:"
		visible: showTrainEffectGenerator
		anchors {
			left:selectColorText.left
			top: selectColorText.bottom
			topMargin: isNxt ? 20 : 16
		}

		onClicked: {
			qkeyboard.open("Treinlengte (0-100)", trainLengthLabel.inputText, saveTrainLength)
		}
	}

	EditTextLabel4421 {
		id: ampLabel
		width: isNxt ? 250 : 200
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 175 : 140
		leftText: "Amplitude:"
		visible: showGlowEffectGenerator && app.singleColorGlow
		anchors {
			left:enableRandomGlowToggle.right
            		leftMargin: 30
			top: enableGlowToggle.bottom
			topMargin: isNxt ? 20 : 16
		}

		onClicked: {
			qkeyboard.open("Amplitude (0-100)", ampLabel.inputText, saveAmp)
		}
	}

	EditTextLabel4421 {
		id: speedLabel
		width: isNxt ? 250 : 200
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 175 : 140
		leftText: "Vertraging:"
		visible: showGlowEffectGenerator && app.singleColorGlow
		anchors {
			left:ampLabel.right
			leftMargin: isNxt ? 16 : 12
			top: ampLabel.top
		}

		onClicked: {
			qkeyboard.open("Snelheid (0-255)", speedLabel.inputText, saveSpeed)
		}
	}

	Text {
        	id: selectRandonGlowText
		height: isNxt ? 45 : 36
		visible: showGlowEffectGenerator && app.singleColorGlow
        	anchors {
            		top: selectGlowText.bottom
			topMargin: isNxt ? 20 : 16
            		left: selectGlowText.left
        	}
        	font {
            		family: qfont.semiBold.name
            		pixelSize: 20
        	}
		text: "per lampje:"
	}

	OnOffToggle {
		id: enableRandomGlowToggle
		height: isNxt ? 45 : 36
		anchors.left: enableGlowToggle.left
		anchors.top: selectRandonGlowText.top
		leftIsSwitchedOn: false
		visible: showGlowEffectGenerator && app.singleColorGlow
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				app.singleRandomColorGlow = true;
			} else {
				app.singleRandomColorGlow = false;
			}
			app.saveSettings();
		}
	}

	StandardButton {
		id: applyEffectButton
		width: isNxt ? 225 : 180
		text: "Toepassen"
		visible: showGlowEffectGenerator || showTrainEffectGenerator
        	anchors {
            		top: enableRandomGlowToggle.bottom
			topMargin: isNxt ? 30 : 24
			left:selectGlowText.left
            		leftMargin: 10
        	}
		leftClickMargin: 3
		bottomClickMargin: 5
		onClicked: {
			enableEffectSaveButton = true;
			app.loginTwinkly("switchOff");
			if (showGlowEffectGenerator) app.loginTwinkly("sendColor");
			if (showTrainEffectGenerator) app.loginTwinkly("sendTrain");
			switchOnOff.isSwitchedOn = true;
		}
	}

	EditTextLabel4421 {
		id: saveEffectNameLabel
		width: isNxt ? 500 : 400
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 200 : 160
		leftText: "Naam favouriet:"
		visible: (showGlowEffectGenerator || showTrainEffectGenerator) && enableEffectSaveButton
		anchors {
			left:applyEffectButton.left
			top: applyEffectButton.bottom
			topMargin: isNxt ? 20 : 16
		}

		onClicked: {
			qkeyboard.open("Naam favouriet:", saveEffectNameLabel.inputText, saveEffectName);
		}
	}

	StandardButton {
		id: saveEffectButton
		width: isNxt ? 225 : 180
		text: "Opslaan als favouriet"
		visible: (showGlowEffectGenerator || showTrainEffectGenerator) && enableEffectSaveButton
        	anchors {
            		top: saveEffectNameLabel.top
			left:saveEffectNameLabel.right
            		leftMargin: 10
        	}
		leftClickMargin: 3
		bottomClickMargin: 5
		onClicked: {
			app.saveEffect(saveEffectNameLabel.inputText);
			enableEffectSaveButton = false;
		}
	}

	// favourites list

	//this is the delegate of the saved favourites
	Component {
		id: favouritesDelegate
		//make it clickable
		Item {
			width: isNxt ? 500 : 400
			height: isNxt ? 50 : 40		
			
			//name and number showed in the playlist
			
			StandardButton {
				id: listItemText

				text: displayEffectName(item)
				width: isNxt ? parent.width - 50 : parent.width - 40
				anchors {
					top: parent.top
					left: parent.left
					topMargin: 10
				}
				onClicked: {
					app.selectedFavourite = getEffectNumber(item)
					app.loginTwinkly("sendMovie");
					switchOnOff.isSwitchedOn = true;
				}
			}

			IconButton {
				id: deleteIcon
				width: 40
				iconSource: "qrc:/tsc/icon_delete.png"

				anchors {
					left: listItemText.right
					leftMargin: 10
					top: listItemText.top
				}

				bottomClickMargin: 3
				onClicked: removeEffect(item)
			}
		}
	}
	
	//property's of the scrollable list
	ScrollableSimpleList {
		id: favouritesScrollableSimpleList
		width: isNxt ? 600 : 480
		height: isNxt ? 375 : 300
		itemsPerPage: 6
		delegate: favouritesDelegate
		anchors.top: borderRect.top
		anchors.left: borderRect.left
		anchors.leftMargin: isNxt ? 75 : 60
		anchors.topMargin: isNxt ? 15 : 12
		visible: showFavourites

		Throbber {
			id: throbber
			visible: false
			anchors {
				horizontalCenter: parent.horizontalCenter
				horizontalCenterOffset: -26
				verticalCenter: parent.verticalCenter
			}
		}
	}
}
