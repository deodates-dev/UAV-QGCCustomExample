import QtQuick 2.11

import OnlineServices                   1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Controls          1.0
import QGroundControl.Palette           1.0

Rectangle {
    width:      columnLayout.width  + (ScreenTools.defaultFontPixelWidth  * 2)
    height:     columnLayout.height + (ScreenTools.defaultFontPixelHeight * 2)
    radius:     ScreenTools.defaultFontPixelHeight * 0.5
    color:      qgcPal.window

    property real _contentWidth:    ScreenTools.defaultFontPixelWidth  * 40
    property real _contentSpacing:  ScreenTools.defaultFontPixelHeight * 0.5

    Column {
        id:             columnLayout
        padding:        ScreenTools.defaultFontPixelWidth * 2
        spacing:        _contentSpacing
        anchors.centerIn: parent
        Item { width: 1; height: 1; }
        QGCLabel {
            text:           qsTr("Welcome to AGS")
            font.family:    ScreenTools.demiboldFontFamily
            font.pointSize: ScreenTools.mediumFontPointSize
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Rectangle {
            width: _contentWidth
            height: 1
            color: qgcPal.globalTheme !== QGCPalette.Light ? Qt.rgba(1,1,1,0.25) : Qt.rgba(0,0,0,0.25)
        }
        Item { width: 1; height: 1; }
        QGCLabel {
            text:           qsTr("Upon using the login button, a browser session will open, where you can use your Auterion account information to login. After a successful login return to the Auterion Ground Station to proceed using your pilot account.")
            width:          _contentWidth
            wrapMode:       Text.WordWrap
            horizontalAlignment: Text.AlignJustify
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Item { width: 1; height: ScreenTools.defaultFontPixelHeight; }
        UserSummaryControl {
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
