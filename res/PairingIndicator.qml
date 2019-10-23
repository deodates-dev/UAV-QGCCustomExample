/****************************************************************************
 *
 *   (c) 2009-2019 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                  2.11
import QtQuick.Controls         2.4
import QtQuick.Layouts          1.11
import QtQuick.Dialogs          1.3

import QGroundControl                       1.0
import QGroundControl.Controllers           1.0
import QGroundControl.Controls              1.0
import QGroundControl.FactControls          1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Palette               1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.SettingsManager       1.0

//-------------------------------------------------------------------------
//-- Pairing Indicator
Item {
    id:             _root
    width:          pairingRow.width * 1.1
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    visible:        QGroundControl.pairingManager.usePairing

    property bool _light:               qgcPal.globalTheme === QGCPalette.Light && !activeVehicle
    property real _contentWidth:        ScreenTools.defaultFontPixelWidth  * 40
    property real _contentSpacing:      ScreenTools.defaultFontPixelHeight * 0.5
    property real _rectWidth:           _contentWidth
    property real _rectHeight:          _contentWidth * 0.75

    property string kPairingManager:    qsTr("Pairing Manager")

    function runPairing() {
        QGroundControl.pairingManager.firstBoot = false
        if(QGroundControl.pairingManager.pairedDeviceNameList.length > 0 || QGroundControl.pairingManager.connectedDeviceNameList.length > 0) {
            connectionPopup.open()
        } else {
            mhPopup.open()
        }
    }

    Row {
        id:                     pairingRow
        spacing:                ScreenTools.defaultFontPixelWidth
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        QGCColoredImage {
            id:                 pairingIcon
            height:             parent.height
            width:              height
            color:              qgcPal.text
            source:             "/custom/img/PairingIcon.svg"
            sourceSize.width:   width
            fillMode:           Image.PreserveAspectFit
            smooth:             true
            mipmap:             true
            antialiasing:       true
            anchors.verticalCenter: parent.verticalCenter
        }
        QGCLabel {
            text:               qsTr("Pair Vehicle")
            width:              !activeVehicle ? (ScreenTools.defaultFontPixelWidth * 12) : 0
            visible:            !activeVehicle
            font.family:        ScreenTools.demiboldFontFamily
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    MouseArea {
        anchors.fill:           parent
        onClicked: {
            runPairing()
        }
    }
    //-------------------------------------------------------------------------
    //-- Pairing Manager Dialog
    Popup {
        id:                     mhPopup
        width:                  mhBody.width
        height:                 mhBody.height
        modal:                  true
        focus:                  true
        parent:                 Overlay.overlay
        x:                      Math.round((mainWindow.width  - width)  * 0.5)
        y:                      Math.round((mainWindow.height - height) * 0.5)
        closePolicy:            Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle {
            anchors.fill:       parent
            color:              qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1,1,1,0.95) : Qt.rgba(0,0,0,0.75)
            radius:             ScreenTools.defaultFontPixelWidth * 0.25
        }
        Item {
            id:                 mhBody
            width:              mhCol.width  + (ScreenTools.defaultFontPixelWidth   * 8)
            height:             mhCol.height + (ScreenTools.defaultFontPixelHeight  * 2)
            anchors.centerIn:   parent
            Column {
                id:                 mhCol
                spacing:            _contentSpacing
                anchors.centerIn:   parent
                Item { width: 1; height: 1; }
                QGCLabel {
                    text:           kPairingManager
                    font.family:    ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                Rectangle {
                    width:          _contentWidth
                    height:         1
                    color:          qgcPal.globalTheme !== QGCPalette.Light ? Qt.rgba(1,1,1,0.25) : Qt.rgba(0,0,0,0.25)
                }
                Item { width: 1; height: 1; }
                QGCLabel {
                    text:               qsTr("To connect to your vehicle, please click on the pairing button in order to put the vehicle in discovery mode")
                    width:              _contentWidth
                    wrapMode:           Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Item { width: 1; height: ScreenTools.defaultFontPixelHeight; }
                QGCColoredImage {
                    height:             ScreenTools.defaultFontPixelHeight * 4
                    width:              height
                    source:             "/custom/img/PairingButton.svg"
                    sourceSize.height:  height
                    fillMode:           Image.PreserveAspectFit
                    mipmap:             true
                    smooth:             true
                    color:              qgcPal.text
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Item { width: 1; height: ScreenTools.defaultFontPixelHeight; }
                GridLayout {
                    columns:            2
                    columnSpacing:      ScreenTools.defaultFontPointSize
                    rowSpacing:         ScreenTools.defaultFontPointSize * 0.25
                    width:              _contentWidth

                    QGCLabel {
                        text:               qsTr("Pairing key:")
                        Layout.row:         0
                        Layout.column:      0
                        Layout.fillWidth:   true
                    }
                    QGCTextField {
                        id:                 encryptionKey
                        text:               QGroundControl.microhardManager.encryptionKey
                        Layout.row:         0
                        Layout.column:      1
                        Layout.fillWidth:   true
                        echoMode:           TextInput.Password
                    }
                    QGCLabel {
                        text:               qsTr("Pairing channel:")
                        Layout.row:         1
                        Layout.column:      0
                        Layout.fillWidth:   true
                    }
                    QGCComboBox {
                        model:              QGroundControl.microhardManager.channelLabels
                        currentIndex:       QGroundControl.microhardManager.pairingChannel - QGroundControl.microhardManager.channelMin
                        Layout.row:         1
                        Layout.column:      1
                        Layout.fillWidth:   true
                        onActivated:        QGroundControl.microhardManager.pairingChannel = currentIndex + QGroundControl.microhardManager.channelMin
                    }
                    QGCLabel {
                        text:               qsTr("Connect channel:")
                        Layout.row:         2
                        Layout.column:      0
                        Layout.fillWidth:   true
                    }
                    QGCComboBox {
                        model:              QGroundControl.microhardManager.channelLabels
                        currentIndex:       QGroundControl.microhardManager.connectingChannel - QGroundControl.microhardManager.channelMin
                        Layout.row:         2
                        Layout.column:      1
                        Layout.fillWidth:   true
                        onActivated:        QGroundControl.pairingManager.setConnectingChannel(currentIndex + QGroundControl.microhardManager.channelMin)
                    }
                }
                Item { width: 1; height: ScreenTools.defaultFontPixelHeight; }
                QGCButton {
                    text:           qsTr("Pair a Vehicle")
                    width:          _contentWidth
                    onClicked: {
                        mhPopup.close()
                        progressPopup.open()
                        QGroundControl.pairingManager.startMicrohardPairing(encryptionKey.text);
                    }
                }
                Item { width: 1; height: 1; }
            }
        }
    }
    //-------------------------------------------------------------------------
    //-- NFC
    Popup {
        id:                     nfcPopup
        width:                  nfcBody.width
        height:                 nfcBody.height
        modal:                  true
        focus:                  true
        parent:                 Overlay.overlay
        x:                      Math.round((mainWindow.width  - width)  * 0.5)
        y:                      Math.round((mainWindow.height - height) * 0.5)
        closePolicy:            Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle {
            anchors.fill:       parent
            color:              qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1,1,1,0.95) : Qt.rgba(0,0,0,0.75)
            radius:             ScreenTools.defaultFontPixelWidth * 0.25
        }
        Item {
            id:                 nfcBody
            width:              nfcCol.width  + (ScreenTools.defaultFontPixelWidth   * 8)
            height:             nfcCol.height + (ScreenTools.defaultFontPixelHeight  * 2)
            anchors.centerIn:   parent
            Column {
                id:                 nfcCol
                spacing:            _contentSpacing
                anchors.centerIn:   parent
                Item { width: 1; height: 1; }
                QGCLabel {
                    text:           kPairingManager
                    font.family:    ScreenTools.demiboldFontFamily
                    font.pointSize: ScreenTools.mediumFontPointSize * 1.5
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                Rectangle {
                    width:          _contentWidth
                    height:         1
                    color:          qgcPal.globalTheme !== QGCPalette.Light ? Qt.rgba(1,1,1,0.25) : Qt.rgba(0,0,0,0.25)
                }
                Item { width: 1; height: 1; }
                Rectangle {
                    width:          _rectWidth
                    height:         _rectHeight
                    color:          Qt.rgba(0,0,0,0)
                    border.color:   qgcPal.text
                    border.width:   1
                    anchors.horizontalCenter: parent.horizontalCenter
                    QGCLabel {
                        text:       "Vehicle and Tablet  Graphic"
                        anchors.centerIn: parent
                    }
                }
                Item { width: 1; height: 1; }
                QGCLabel {
                    text:           qsTr("Please make sure your vehicle is close to your Ground Station device")
                    width:          _contentWidth
                    wrapMode:       Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Item { width: 1; height: 1; }
                QGCButton {
                    text:           qsTr("Pair Via NFC")
                    width:          _contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        nfcPopup.close()
                        progressPopup.open()
                        QGroundControl.pairingManager.startNFCScan();
                    }
                }
                Item { width: 1; height: 1; }
            }
        }
    }
    //-------------------------------------------------------------------------
    //-- Pairing/Connection Progress
    Popup {
        id:                     progressPopup
        width:                  progressBody.width
        height:                 progressBody.height
        modal:                  true
        focus:                  true
        parent:                 Overlay.overlay
        x:                      Math.round((mainWindow.width  - width)  * 0.5)
        y:                      Math.round((mainWindow.height - height) * 0.5)
        closePolicy:            cancelButton.visible ? Popup.NoAutoClose : (Popup.CloseOnEscape | Popup.CloseOnPressOutside)
        background: Rectangle {
            anchors.fill:       parent
            color:              qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1,1,1,0.95) : Qt.rgba(0,0,0,0.75)
            radius:             ScreenTools.defaultFontPixelWidth * 0.25
        }
        Item {
            id:                 progressBody
            width:              progressCol.width  + (ScreenTools.defaultFontPixelWidth   * 8)
            height:             progressCol.height + (ScreenTools.defaultFontPixelHeight  * 2)
            anchors.centerIn:   parent
            Column {
                id:                     progressCol
                spacing:                _contentSpacing
                anchors.centerIn:       parent
                Item { width: 1; height: 1; }
                QGCLabel {
                    text:               kPairingManager
                    font.family:        ScreenTools.demiboldFontFamily
                    font.pointSize:     ScreenTools.mediumFontPointSize * 1.5
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                QGCLabel {
                    text:               QGroundControl.pairingManager ? QGroundControl.pairingManager.pairingStatusStr : ""
                    visible:            !connectedIndicator.visible
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Rectangle {
                    width:              _contentWidth
                    height:             1
                    color:              qgcPal.globalTheme !== QGCPalette.Light ? Qt.rgba(1,1,1,0.25) : Qt.rgba(0,0,0,0.25)
                }
                Item { width: 1; height: 1; }
                //-- Pairing/Connecting
                Item { width: 1; height: ScreenTools.defaultFontPixelHeight * 3; visible: busyIndicator.visible; }
                QGCColoredImage {
                    id:                 busyIndicator
                    height:             ScreenTools.defaultFontPixelHeight * 4
                    width:              height
                    source:             "/qmlimages/MapSync.svg"
                    sourceSize.height:  height
                    fillMode:           Image.PreserveAspectFit
                    mipmap:             true
                    smooth:             true
                    color:              qgcPal.text
                    visible:            QGroundControl.pairingManager.pairingStatus === PairingManager.PairingActive || QGroundControl.pairingManager.pairingStatus === PairingManager.PairingConnecting
                    anchors.horizontalCenter: parent.horizontalCenter
                    RotationAnimation on rotation {
                        loops:          Animation.Infinite
                        from:           360
                        to:             0
                        duration:       720
                        running:        busyIndicator.visible
                    }
                }
                Item { width: 1; height: ScreenTools.defaultFontPixelHeight * 3; visible: busyIndicator.visible; }
                //-- Error State
                Image {
                    height:             ScreenTools.defaultFontPixelHeight * 4
                    width:              height
                    source:             "/custom/img/PairingError.svg"
                    sourceSize.height:  height
                    fillMode:           Image.PreserveAspectFit
                    mipmap:             true
                    smooth:             true
                    visible:            QGroundControl.pairingManager.errorState
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                //-- Connection Successful
                Image {
                    id:                 connectedIndicator
                    height:             width * 0.2
                    width:              _contentWidth
                    source:             "/custom/img/PairingConnected.svg"
                    sourceSize.height:  height
                    fillMode:           Image.PreserveAspectFit
                    mipmap:             true
                    smooth:             true
                    visible:            QGroundControl.pairingManager.pairingStatus === PairingManager.PairingConnected
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Item { width: 1; height: _contentSpacing; visible: connectedIndicator.visible; }
                QGCLabel {
                    text:               QGroundControl.pairingManager.connectedVehicle
                    visible:            connectedIndicator.visible
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                QGCLabel {
                    text:               qsTr("Connection Successful")
                    visible:            connectedIndicator.visible
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Item { width: 1; height: _contentSpacing; }
                //-- Buttons
                QGCButton {
                    width:                  _contentWidth
                    visible:                QGroundControl.pairingManager ? (QGroundControl.pairingManager.pairingStatus === PairingManager.PairingConnected) : false
                    text:                   qsTr("Done")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        progressPopup.close()
                    }
                }
                QGCButton {
                    text:                   qsTr("Pair Another")
                    width:                  _contentWidth
                    visible:                QGroundControl.pairingManager ? (QGroundControl.pairingManager.pairingStatus === PairingManager.PairingConnected) : false
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        progressPopup.close()
                        mhPopup.open()
                    }
                }
                QGCButton {
                    text:                   qsTr("Try Again")
                    width:                  _contentWidth
                    visible:                QGroundControl.pairingManager ? QGroundControl.pairingManager.errorState : false
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        progressPopup.close()
                        runPairing()
                    }
                }
                QGCButton {
                    id:                     cancelButton
                    width:                  _contentWidth
                    visible:                QGroundControl.pairingManager ? (QGroundControl.pairingManager.pairingStatus === PairingManager.PairingActive || QGroundControl.pairingManager.pairingStatus === PairingManager.PairingConnecting || QGroundControl.pairingManager.errorState) : false
                    text:                   qsTr("Cancel")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        if(QGroundControl.pairingManager.pairingStatus === PairingManager.PairingActive)
                            QGroundControl.pairingManager.stopPairing()
                        else {
                            //-- TODO: Cancel connection to paired device
                        }
                        progressPopup.close()
                    }
                }
                Item { width: 1; height: 1; }
            }
        }
    }
    //-------------------------------------------------------------------------
    //-- Connection Manager
    Popup {
        id:                     connectionPopup
        width:                  connectionBody.width
        height:                 connectionBody.height
        modal:                  true
        focus:                  true
        parent:                 Overlay.overlay
        x:                      Math.round((mainWindow.width  - width)  * 0.5)
        y:                      Math.round((mainWindow.height - height) * 0.5)
        closePolicy:            cancelButton.visible ? Popup.NoAutoClose : (Popup.CloseOnEscape | Popup.CloseOnPressOutside)
        background: Rectangle {
            anchors.fill:       parent
            color:              qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1,1,1,0.95) : Qt.rgba(0,0,0,0.75)
            radius:             ScreenTools.defaultFontPixelWidth * 0.25
        }
        Item {
            id:                 connectionBody
            width:              connectionCol.width  + (ScreenTools.defaultFontPixelWidth   * 8)
            height:             connectionCol.height + (ScreenTools.defaultFontPixelHeight  * 2)
            anchors.centerIn:   parent
            ColumnLayout {
                id:                      connectionCol
                spacing:                 _contentSpacing
                anchors.centerIn:        parent
                QGCLabel {
                    text:                kPairingManager
                    font.family:         ScreenTools.demiboldFontFamily
                    font.pointSize:      ScreenTools.mediumFontPointSize * 1.5
                    Layout.fillWidth:    true
                    horizontalAlignment: Text.AlignHCenter
                }
                Rectangle {
                    Layout.fillWidth:    true
                    height:              1
                    color:               qgcPal.globalTheme !== QGCPalette.Light ? Qt.rgba(1,1,1,0.25) : Qt.rgba(0,0,0,0.25)
                }

                //-----------------------------------------------------------
                // Connected & available devices
                GridLayout {
                    id: _connectedLayout
                    columns:            4
                    visible:            _connectedVisible || _availableVisible
                    columnSpacing:      ScreenTools.defaultFontPointSize * 2
                    rowSpacing:         ScreenTools.defaultFontPointSize * 0.5

                    property var  _connectedModel: QGroundControl.pairingManager ? QGroundControl.pairingManager.connectedDeviceNameList : []
                    property bool _connectedVisible: QGroundControl.pairingManager ? (QGroundControl.pairingManager.connectedDeviceNameList.length > 0 && !cancelButton.visible) : false
                    property var  _pairModel: QGroundControl.pairingManager ? QGroundControl.pairingManager.pairedDeviceNameList : []
                    property bool _availableVisible: QGroundControl.pairingManager ? (QGroundControl.pairingManager.pairedDeviceNameList.length > 0 && !cancelButton.visible) : false
                    property real _baseIndex: 4 + (_connectedModel ? _connectedModel.length : 0)

                    QGCLabel {
                        text:               qsTr("Connected Vehicles")
                        visible:            parent._connectedVisible
                        font.family:        ScreenTools.demiboldFontFamily
                        font.pointSize:     ScreenTools.mediumFontPointSize
                        Layout.row:         0
                        Layout.column:      0
                        Layout.columnSpan:  4
                        Layout.minimumWidth:ScreenTools.defaultFontPixelWidth * 14
                        Layout.fillWidth:   true
                    }

                    Repeater {
                        model: parent._connectedModel
                        delegate: QGCColoredImage {
                            Layout.row:             2 + index * 2
                            Layout.rowSpan:         2
                            Layout.column:          0
                            Layout.minimumWidth:    ScreenTools.defaultFontPixelHeight * 1.5
                            Layout.minimumHeight:   ScreenTools.defaultFontPixelHeight * 1.5
                            height:                 ScreenTools.defaultFontPixelHeight * 1.5
                            width:                  height
                            smooth:                 true
                            mipmap:                 true
                            antialiasing:           true
                            fillMode:               Image.PreserveAspectFit
                            source:                 "/qmlimages/PaperPlane.svg"
                            sourceSize.height:      height
                            color:                  qgcPal.buttonText
                        }
                    }
                    Repeater {
                        model:                  parent._connectedModel
                        delegate: QGCLabel {
                            text:               deviceName
                            font.family:        ScreenTools.demiboldFontFamily
                            font.pointSize:     ScreenTools.mediumFontPointSize
                            Layout.row:         2 + index * 2
                            Layout.column:      1
                            Layout.minimumWidth:ScreenTools.defaultFontPixelWidth * 28
                            Layout.fillWidth:   true
                            property string deviceName: QGroundControl.pairingManager.extractName(modelData);
                        }
                    }
                    Repeater {
                        model:                  parent._connectedModel
                        delegate: QGCLabel {
                            text:               deviceChannel
                            font.family:        ScreenTools.normalFontFamily
                            font.pointSize:     ScreenTools.smallFontPointSize * 1.1
                            Layout.row:         2 + index * 2 + 1
                            Layout.column:      1
                            property string deviceChannel: QGroundControl.pairingManager.extractChannel(modelData);
                        }
                    }
                    Repeater {
                        model: parent._connectedModel
                        delegate: QGCButton {
                            Layout.preferredWidth:  ScreenTools.defaultFontPixelHeight * 5
                            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5
                            Layout.row:             2 + index * 2
                            Layout.rowSpan:         2
                            Layout.column:          2
                            text:                   qsTr("Disconnect")
                            onClicked: {
                                disconnectPrompt.open()
                            }
                            property string deviceName: QGroundControl.pairingManager.extractName(modelData);

                            MessageDialog {
                                id:                 disconnectPrompt
                                title:              qsTr("Disconnect Vehicle")
                                text:               qsTr("Confirm disconnecting vehicle %1?").arg(deviceName)
                                standardButtons:    StandardButton.Yes | StandardButton.No
                                onNo:               disconnectPrompt.close()
                                onYes: {
                                    QGroundControl.pairingManager.disconnectDevice(deviceName)
                                    disconnectPrompt.close()
                                }
                            }
                        }
                    }
                    Repeater {
                        // Unpair replacement
                        model: parent._connectedModel
                        delegate: Item {
                            Layout.row:             2 + index
                            Layout.rowSpan:         2
                            Layout.column:          4
                            Layout.minimumWidth:    ScreenTools.defaultFontPixelHeight * 1.5
                            Layout.minimumHeight:   ScreenTools.defaultFontPixelHeight * 1.5
                        }
                    }

                    QGCLabel {
                        text:               qsTr("Available Vehicles")
                        visible:            parent._availableVisible
                        font.family:        ScreenTools.demiboldFontFamily
                        font.pointSize:     ScreenTools.mediumFontPointSize
                        Layout.row:         parent._baseIndex
                        Layout.column:      0
                        Layout.columnSpan:  4
                        Layout.minimumWidth:ScreenTools.defaultFontPixelWidth * 14
                        Layout.fillWidth:   true
                    }

                    Item { width: 1; height: 1; Layout.row: parent._baseIndex + 1; Layout.column: 0; Layout.columnSpan: 4}

                    Repeater {
                        model: parent._pairModel
                        delegate: QGCColoredImage {
                            Layout.row:             2 + (parent._baseIndex + index) * 2
                            Layout.rowSpan:         2
                            Layout.column:          0
                            Layout.minimumWidth:    ScreenTools.defaultFontPixelHeight * 1.5
                            Layout.minimumHeight:   ScreenTools.defaultFontPixelHeight * 1.5
                            height:                 ScreenTools.defaultFontPixelHeight * 1.5
                            width:                  height
                            smooth:                 true
                            mipmap:                 true
                            antialiasing:           true
                            fillMode:               Image.PreserveAspectFit
                            source:                 "/qmlimages/PaperPlane.svg"
                            sourceSize.height:      height
                            color:                  qgcPal.buttonText
                        }
                    }
                    Repeater {
                        model: parent._pairModel
                        delegate: QGCLabel {
                            text:               deviceName
                            font.family:        ScreenTools.demiboldFontFamily
                            font.pointSize:     ScreenTools.mediumFontPointSize
                            Layout.row:         2 + (parent._baseIndex + index) * 2
                            Layout.column:      1
                            Layout.minimumWidth:ScreenTools.defaultFontPixelWidth * 28
                            Layout.fillWidth:   true
                            property string deviceName: QGroundControl.pairingManager.extractName(modelData);
                        }
                    }
                    Repeater {
                        model: parent._pairModel
                        delegate: QGCLabel {
                            text:               deviceChannel
                            font.family:        ScreenTools.normalFontFamily
                            font.pointSize:     ScreenTools.smallFontPointSize * 1.1
                            Layout.row:         2 + (parent._baseIndex + index) * 2 + 1
                            Layout.column:      1
                            property string deviceChannel: QGroundControl.pairingManager.extractChannel(modelData);
                        }
                    }
                    Repeater {
                        model: parent._pairModel
                        delegate: QGCButton {
                            Layout.preferredWidth:  ScreenTools.defaultFontPixelHeight * 5
                            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5
                            Layout.row:             2 + (parent._baseIndex + index) * 2
                            Layout.rowSpan:         2
                            Layout.column:          2
                            text:                   qsTr("Connect")
                            onClicked: {
                                QGroundControl.pairingManager.connectToDevice(deviceName)
                                connectionPopup.close()
                                progressPopup.open()
                            }
                            property string deviceName: QGroundControl.pairingManager.extractName(modelData);
                        }
                    }
                    Repeater {
                        model: parent._pairModel
                        delegate: QGCColoredImage {
                            Layout.row:             2 + (parent._baseIndex + index) * 2
                            Layout.rowSpan:         2
                            Layout.column:          3
                            Layout.minimumWidth:    ScreenTools.defaultFontPixelHeight * 1.5
                            Layout.minimumHeight:   ScreenTools.defaultFontPixelHeight * 1.5
                            height:                 ScreenTools.defaultFontPixelHeight * 1.5
                            width:                  height
                            smooth:                 true
                            mipmap:                 true
                            antialiasing:           true
                            fillMode:               Image.PreserveAspectFit
                            source:                 "/custom/img/PairingDelete.svg"
                            sourceSize.height:      height
                            color:                  qgcPal.colorRed
                            property string deviceName: QGroundControl.pairingManager.extractName(modelData);

                            MouseArea {
                                anchors.fill:       parent
                                onClicked: {
                                    removePrompt.open()
                                }
                            }

                            MessageDialog {
                                id:                 removePrompt
                                title:              qsTr("Remove Paired Vehicle")
                                text:               qsTr("Confirm removing %1?").arg(deviceName)
                                standardButtons:    StandardButton.Yes | StandardButton.No
                                onNo:               removePrompt.close()
                                onYes: {
                                    QGroundControl.pairingManager.removePairedDevice(deviceName)
                                    removePrompt.close()
                                }
                            }
                        }
                    }
                } // GridLayout

                Item { width: 1; height: _contentSpacing; }

                GridLayout {
                    columns:            2
                    columnSpacing:      ScreenTools.defaultFontPointSize * 2
                    rowSpacing:         ScreenTools.defaultFontPointSize * 0.75
                    visible:            QGroundControl.pairingManager ? (QGroundControl.pairingManager.connectedDeviceNameList.length > 0 && !cancelButton.visible) : false

                    QGCLabel {
                        text:               qsTr("Connect channel:")
                        font.family:        ScreenTools.demiboldFontFamily
                        font.pointSize:     ScreenTools.defaultFontPointSize
                        Layout.row:         0
                        Layout.column:      0
                        Layout.columnSpan:  1
                        Layout.fillWidth:   true
                    }
                    QGCComboBox {
                        model:              QGroundControl.microhardManager.channelLabels
                        currentIndex:       QGroundControl.microhardManager.connectingChannel - QGroundControl.microhardManager.channelMin
                        Layout.row:         0
                        Layout.column:      1
                        Layout.columnSpan:  1
                        Layout.fillWidth:   true
                        onActivated:        QGroundControl.pairingManager.setConnectingChannel(currentIndex + QGroundControl.microhardManager.channelMin)
                    }
                }

                QGCButton {
                    width:              _contentWidth
                    text:               qsTr("Done")
                    Layout.fillWidth:   true
                    onClicked: {
                        connectionPopup.close()
                    }
                }
                QGCButton {
                    text:               qsTr("Pair Another")
                    width:              _contentWidth
                    Layout.fillWidth:   true
                    onClicked: {
                        connectionPopup.close()
                        mhPopup.open()
                    }
                }
                Item { width: 1; height: 1; }
            }
        }
    }
}
