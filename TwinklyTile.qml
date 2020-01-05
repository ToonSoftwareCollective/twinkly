import QtQuick 2.1
import qb.components 1.0


Tile {
	id: domoticzTile
	property bool dimState: screenStateController.dimmedColors

	onClicked: {
		stage.openFullscreen(app.twinklyScreenUrl);
	}

	function iconToShow(status) {

		if (status) {
			return app.tilebulb_onvar;
		} else {
			return app.tilebulb_offvar;
		}
	}
	
	function iconToShowDim(status) {

		if (status) {
			return app.dimtilebulb_onvar;
		} else {
			return app.dimtilebulb_offvar;
		}
	}

	function switchTwinkly() {
		if (app.twinklyLit) {
			app.loginTwinkly("switchOff");
		} else {
			app.loginTwinkly("switchOn");
		}
	}

 	Image {
        	id: twinklyButton
        	anchors {
         	   top: parent.top
         	   topMargin: isNxt ? 25 : 20
		   horizontalCenter: parent.horizontalCenter
        	}
        	width: isNxt ? 100 : 75
        	height: isNxt ? 100 : 75
     		source: dimState ? iconToShowDim(app.twinklyLit) : iconToShow(app.twinklyLit)
		MouseArea {
			id: switch1Mouse
			anchors.fill: parent
			onClicked: {
				switchTwinkly();
			}
		}

	}

	Text {
		id: txtTile
		text: "Twinkly"
		anchors {
			top: twinklyButton.bottom
			topMargin: 10
			horizontalCenter: parent.horizontalCenter
		}
		horizontalAlignment: Text.AlignHCenter
		font.pixelSize: isNxt ? 32 : 25
		font.family: qfont.regular.name
	}

}
