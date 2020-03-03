import QtQuick 2.11
import QtQuick.Layouts 1.11
import qb.components 1.0

Screen {
	id: root

	screenTitle: "Twinkly Selekteer Kleur"
 	property int colorHandleRadius : 8
	property int cursorHeight: 7
	property int r : colorHandleRadius

		//  creates color value from hue, saturation, brightness
	function _hsla(h, s, b) {
		var lightness = (2 - s)*b
		var satHSL = s*b/((lightness <= 1) ? lightness : 2 - lightness)
		lightness /= 2

		var c = Qt.hsla(h, satHSL, lightness, 255)
		colorChanged(c)
		return c
	}
	onShown: {
		addCustomTopRightButton("Opslaan");
	}

	hasBackButton: false

	onCustomButtonClicked: {
		app.colorR = _getChannelStr(colorPicker.colorValue, 0);
		app.colorG = _getChannelStr(colorPicker.colorValue, 1);
		app.colorB = _getChannelStr(colorPicker.colorValue, 2);
		app.selectedColor = colorPicker.colorValue;
		hide();
	}

	//  creates a full color string from color value, e.g. "#FF00FF00"
	function _fullColorString(clr) {
		return "#FF" + clr.toString().substr(1, 6).toUpperCase()
	}

	//  extracts integer color channel value [0..255] from color value
	function _getChannelStr(clr, channelIdx) {
		return parseInt(clr.toString().substr(channelIdx*2 + 1, 2), 16)
	}

	//  calculates SBPicker size from this
	function _getSBPickerSize() {
		var h = colorPicker.height - 2 * colorHandleRadius
		var w = colorPicker.width - 2 * colorHandleRadius - huePicker.width
		w = w - detailColumn.implicitWidth
		if(h > w) {
			return w
		} else {
			return h
		}
	}

	Text {
        	id: satTitle
        	anchors {
            		top: parent.top
            		left: parent.left
            		leftMargin: 10
        	}
        	font {
            		family: qfont.semiBold.name
            		pixelSize: 20
        	}
	        text: "                Selekteer de helderheid en verzadiging" 
	}
	Text {
        	id: hueTitle
        	anchors {
            		top: satTitle.top
            		left: satTitle.right
            		leftMargin: isNxt ? 100 : 80
        	}
        	font {
            		family: qfont.semiBold.name
            		pixelSize: 20
        	}
	        text: "Kleur:" 
	}

	Rectangle {
		id: colorPicker
		property color colorValue: _hsla(hueSlider.value, sbPicker.saturation, sbPicker.brightness)
		signal colorChanged(color changedColor)

		width: isNxt ? 750 : 600
		height: isNxt ? 450 : 360
		color: "transparent"
		anchors.top: satTitle.bottom
		anchors.left: satTitle.left

		RowLayout {
			id: row
			x: Math.round(parent.width / 2 - implicitWidth / 2)
			y: Math.round(parent.height / 2 - implicitHeight / 2)
			width: colorHandleRadius* 2 + sbPicker.implicitWidth + huePicker.implicitWidth + detailColumn.implicitWidth
			height: colorHandleRadius* 2 + sbPicker.implicitHeight
			spacing: 3	

			// saturation/brightness picker box
			Item {
				id: sbPicker
				property real saturation : pickerCursor.x/width
				property real brightness : 1 - pickerCursor.y/height
				width: _getSBPickerSize()
				height: _getSBPickerSize()
				Layout.alignment: Qt.AlignLeft | Qt.AlignTop
				property color hueColor: {
					var v = 1.0-hueSlider.value
					if(0.0 <= v && v < 0.16) {
						return Qt.rgba(1.0, 0.0, v/0.16, 1.0)
					} else if(0.16 <= v && v < 0.33) {
						return Qt.rgba(1.0 - (v-0.16)/0.17, 0.0, 1.0, 1.0)
					} else if(0.33 <= v && v < 0.5) {
						return Qt.rgba(0.0, ((v-0.33)/0.17), 1.0, 1.0)
					} else if(0.5 <= v && v < 0.76) {
						return Qt.rgba(0.0, 1.0, 1.0 - (v-0.5)/0.26, 1.0)
					} else if(0.76 <= v && v < 0.85) {
						return Qt.rgba((v-0.76)/0.09, 1.0, 0.0, 1.0)
					} else if(0.85 <= v && v <= 1.0) {
						return Qt.rgba(1.0, 1.0 - (v-0.85)/0.15, 0.0, 1.0)
					} else {
						return "red"
					}
				}
				Rectangle {
					anchors.fill: parent;
					rotation: -90
					gradient: Gradient {
						GradientStop { position: 0.0; color: "#FFFFFF" }
 						GradientStop { position: 1.0; color: sbPicker.hueColor }
					}
				}
				Rectangle {
					anchors.fill: parent
					gradient: Gradient {
						GradientStop { position: 1.0; color: "#FF000000" }
						GradientStop { position: 0.0; color: "#00000000" }
					}
				}
				Item {
					id: pickerCursor
					Rectangle {
						x: -r; y: -r
						width: r*2; height: r*2
						radius: r
						border.color: "black"; border.width: 2
						color: "transparent"
						Rectangle {
							anchors.fill: parent; anchors.margins: 2;
							border.color: "white"; border.width: 2
							radius: width/2
							color: "transparent"
						}
					}
				}
				MouseArea {
					x: -r
					y: -r
					width: parent.width + r
					height: parent.height + r
					function handleMouse(mouse) {
						if (mouse.buttons & Qt.LeftButton) {
							pickerCursor.x = Math.max(0, Math.min(width,  mouse.x) - r);
							pickerCursor.y = Math.max(0, Math.min(height, mouse.y) - r);
						}
					}
					onPositionChanged: handleMouse(mouse)
					onPressed: handleMouse(mouse)
				}
			}

			// hue picking slider
			Item {
				id: huePicker
				width: isNxt ? 75 : 60
				Layout.alignment: Qt.AlignLeft | Qt.AlignTop
				Layout.fillHeight: true
				Layout.leftMargin: 30
				Rectangle {
					anchors.fill: parent
					id: colorBar
					gradient: Gradient {
						GradientStop { position: 1.0;  color: "#FF0000" }
						GradientStop { position: 0.85; color: "#FFFF00" }
						GradientStop { position: 0.76; color: "#00FF00" }
						GradientStop { position: 0.5;  color: "#00FFFF" }
						GradientStop { position: 0.33; color: "#0000FF" }
						GradientStop { position: 0.16; color: "#FF00FF" }
						GradientStop { position: 0.0;  color: "#FF0000" }
					}
				}
				Item {
					id: hueSlider
					anchors.fill: parent
					property real value: (1 - pickerCursor2.y/height)
					width: 50; height: 300
					Item {
						id: pickerCursor2
						width: parent.width
						Rectangle {
							x: -3; y: -height*0.5
							width: parent.width + 4; height: cursorHeight
							border.color: "black"; border.width: 1
							color: "transparent"
							Rectangle {
								anchors.fill: parent; anchors.margins: 2
								border.color: "white"; border.width: 1
								color: "transparent"
							}
						}
					}
					MouseArea {
						y: -Math.round(cursorHeight/2)
						height: parent.height+cursorHeight
						anchors.left: parent.left
						anchors.right: parent.right
						function handleMouse(mouse) {
							if (mouse.buttons & Qt.LeftButton) {
								pickerCursor2.y = Math.max(0, Math.min(height, mouse.y)-cursorHeight)
							}
						}
						onPositionChanged: {
							handleMouse(mouse)
						}
						onPressed: handleMouse(mouse)
					}
				}
			}

			// details column
			Column {
				id: detailColumn
				Layout.alignment: Qt.AlignLeft | Qt.AlignTop
				Layout.leftMargin: 30
				spacing: 20

				 // R, G, B color values boxes
				Column {
					width: parent.width
					Text {
				        	id: redResult
				        	font {
            						family: qfont.semiBold.name
            						pixelSize: isNxt ? 20 : 16
        					}
					        text: "Rood:     " +  _getChannelStr(colorPicker.colorValue, 0)
					}
					Text {
				        	id: greenResult
				        	font {
            						family: qfont.semiBold.name
            						pixelSize: isNxt ? 20 : 16
        					}
					        text: "Groen:   " +  _getChannelStr(colorPicker.colorValue, 1)
					}
					Text {
				        	id: blueResult
				        	font {
            						family: qfont.semiBold.name
            						pixelSize: isNxt ? 20 : 16
        					}
					        text: "Blauw:   " +  _getChannelStr(colorPicker.colorValue, 2)
					}
					Text {
				        	id: space
						height: isNxt ? 200 : 160
				        	font {
            						family: qfont.semiBold.name
            						pixelSize: isNxt ? 20 : 16
        					}
					        text: " " 
					}
					Text {
				        	id: resultTitle
						height: isNxt ? 25 : 20
				        	font {
            						family: qfont.semiBold.name
            						pixelSize: isNxt ? 20 : 16
        					}
					        text: "Resultaat:" 
					}
					Rectangle {
						width: isNxt ? 100 : 80
						height: isNxt ? 100 : 80
						color: colorPicker.colorValue
					}
				}
			}
		}
	}
}
