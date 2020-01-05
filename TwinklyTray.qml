import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

SystrayIcon {
	id: twinklySystrayIcon
	visible: true
	posIndex: 8000
	property string objectName: "twinklySystray"

	onClicked: {
		stage.openFullscreen(app.twinklyScreenUrl);
	}

	Image {
		id: imgDomoticz
		anchors.centerIn: parent
		source: "qrc:/tsc/LightbulbSystrayIcon.png"
		visible: app.enableSystray
	}
}
