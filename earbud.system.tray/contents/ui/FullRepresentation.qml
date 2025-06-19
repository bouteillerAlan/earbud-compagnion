import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import "components" as Components
import "js" as Js

Item {
    id: fullRep

    property bool customColor: false
    property color earbudColor: "#ffffff"
    property int iconSize: 24
    property int opacityValue: 100

    property bool showBatteryLevel: Plasmoid.configuration.showBatteryLevel
    property bool showDeviceName: Plasmoid.configuration.showDeviceName

    Layout.minimumWidth: 300
    Layout.minimumHeight: 200
    Layout.preferredWidth: 300
    Layout.preferredHeight: 200

    // Reference to the Bluetooth service from main.qml
    property var bluetoothService: null

    Component.onCompleted: {
        console.log("FullRepresentation component in FullRepresentation.qml created")
        console.log("bluetoothService is " + (bluetoothService ? "available" : "not available"))
        if (bluetoothService) {
            console.log("bluetoothService type: " + typeof bluetoothService)
            try {
                console.log("bluetoothService properties: " + JSON.stringify(Object.keys(bluetoothService)))
            } catch (e) {
                console.error("Error inspecting bluetoothService: " + e)
            }
        }
    }

    // Update UI when bluetoothService property changes
    onBluetoothServiceChanged: {
        console.log("bluetoothService changed: " + (bluetoothService ? "not null" : "null"))
        if (bluetoothService) {
            console.log("bluetoothService type: " + typeof bluetoothService)
            try {
                console.log("bluetoothService properties: " + JSON.stringify(Object.keys(bluetoothService)))
                console.log("bluetoothService.cmd: " + (bluetoothService.cmd ? "available" : "not available"))
                console.log("bluetoothService.checkBluetoothStatus: " + (typeof bluetoothService.checkBluetoothStatus === 'function' ? "is a function" : "is not a function"))
            } catch (e) {
                console.error("Error inspecting bluetoothService: " + e)
            }
            updateUI()
        } else {
            console.error("Error: bluetoothService is null in onBluetoothServiceChanged")
            noDeviceLabel.visible = true
            deviceListView.visible = false
        }
    }

    // Function to update the UI with current data
    function updateUI() {
        console.log("updateUI called")

        if (!bluetoothService) {
            console.error("Error: bluetoothService is null in updateUI")
            noDeviceLabel.visible = true
            deviceListView.visible = false
            return
        }

        console.log("bluetoothService is available in updateUI")
        console.log("bluetoothService.devices: " + (bluetoothService.devices ? "available" : "not available"))

        if (bluetoothService.devices) {
            console.log("bluetoothService.devices.length: " + bluetoothService.devices.length)
            console.log("bluetoothService.devices: " + JSON.stringify(bluetoothService.devices))
        }

        try {
            // Update the device list
            deviceListView.model = bluetoothService.devices

            // Show/hide the no devices message
            noDeviceLabel.visible = bluetoothService.devices.length === 0
            deviceListView.visible = bluetoothService.devices.length > 0

            console.log("UI updated successfully")
        } catch (e) {
            console.error("Error updating UI: " + e)
            noDeviceLabel.visible = true
            deviceListView.visible = false
        }
    }

    // Connect to the dataUpdated signal from the BluetoothService
    Connections {
        id: bluetoothServiceConnections
        target: bluetoothService
        enabled: bluetoothService !== null

        Component.onCompleted: {
            console.log("BluetoothService Connections component created")
            console.log("target is " + (target ? "available" : "not available"))
            console.log("enabled is " + enabled)
        }

        function onDataUpdated() {
            console.log("dataUpdated signal received from bluetoothService")
            updateUI()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Header
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: i18n("Bluetooth Audio Devices")
            font.bold: true
            font.pixelSize: 16
        }

        // Icon
        Components.EarbudIcon {
            id: iconContainer
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: iconSize * 1.5
            Layout.preferredHeight: iconSize * 1.5
            customColor: fullRep.customColor
            earbudColor: fullRep.earbudColor
            opacityValue: fullRep.opacityValue
        }

        // No device connected message
        ColumnLayout {
            id: noDeviceLabel
            Layout.alignment: Qt.AlignHCenter
            visible: true
            spacing: 5

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: i18n("No audio devices connected")
                font.bold: true
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: i18n("Make sure your Bluetooth device is:")
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: i18n("1. Turned on and in pairing mode")
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: i18n("2. Paired with your computer")
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: i18n("3. Connected (not just paired)")
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
            }
        }

        // Device list
        ListView {
            id: deviceListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: false
            clip: true
            spacing: 10

            // Use a placeholder model until real data arrives
            model: []

            // Delegate for each device
            delegate: Item {
                width: deviceListView.width
                height: deviceDelegate.height

                Rectangle {
                    id: deviceBackground
                    anchors.fill: parent
                    color: Kirigami.Theme.backgroundColor
                    opacity: 0.2
                    radius: 5
                }

                ColumnLayout {
                    id: deviceDelegate
                    width: parent.width
                    spacing: 5

                    // Device name and status
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.margins: 5

                        Kirigami.Icon {
                            source: modelData.icon || "audio-headset"
                            width: 22
                            height: 22
                        }

                        Label {
                            text: modelData.name || i18n("Unknown Device")
                            font.bold: true
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            visible: showDeviceName
                        }

                        Label {
                            text: modelData.isConnected ? i18n("Connected") : i18n("Disconnected")
                            color: modelData.isConnected ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                        }
                    }

                    // Device type (audio or not)
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.margins: 5
                        visible: modelData.icon !== ""

                        Label {
                            text: i18n("Type:")
                        }

                        Label {
                            text: modelData.icon || i18n("Unknown")
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Label {
                            text: modelData.isAudioDevice ? i18n("Audio Device") : i18n("Other Device")
                            color: modelData.isAudioDevice ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.neutralTextColor
                        }
                    }

                    // Battery level
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.margins: 5
                        visible: showBatteryLevel

                        Label {
                            text: i18n("Battery:")
                        }

                        Label {
                            text: modelData.batteryLevel >= 0 ? modelData.batteryLevel + "%" : i18n("Unknown")
                            Layout.preferredWidth: 60
                        }

                        ProgressBar {
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: modelData.batteryLevel >= 0 ? modelData.batteryLevel : 0

                            // Color based on battery level
                            contentItem: Rectangle {
                                width: parent.visualPosition * parent.width
                                height: parent.height
                                radius: 2
                                color: {
                                    if (modelData.batteryLevel < 0) return Kirigami.Theme.disabledTextColor
                                    if (modelData.batteryLevel < 20) return Kirigami.Theme.negativeTextColor
                                    if (modelData.batteryLevel < 50) return Kirigami.Theme.neutralTextColor
                                    return Kirigami.Theme.positiveTextColor
                                }
                            }
                        }
                    }
                }
            }
        }

        // Refresh button
        Button {
            id: refreshButton
            Layout.alignment: Qt.AlignHCenter
            text: refreshing ? i18n("Refreshing...") : i18n("Refresh")
            icon.name: "view-refresh"
            enabled: !refreshing
            property bool refreshing: false

            Component.onCompleted: {
                console.log("Refresh button created")
                console.log("bluetoothService in refresh button is " + (typeof bluetoothService !== 'undefined' && bluetoothService !== null ? "available" : "not available"))
            }

            onClicked: {
                console.log("Refresh button clicked")
                console.log("bluetoothService is " + (typeof bluetoothService !== 'undefined' && bluetoothService !== null ? "available" : "not available"))
                if (typeof bluetoothService !== 'undefined' && bluetoothService !== null) {
                    console.log("bluetoothService type: " + typeof bluetoothService)
                    console.log("bluetoothService properties: " + JSON.stringify(Object.keys(bluetoothService)))
                }

                refreshing = true
                refreshTimer.start()
                if (typeof bluetoothService !== 'undefined' && bluetoothService !== null) {
                    console.log("Calling checkBluetoothStatus on bluetoothService")
                    bluetoothService.checkBluetoothStatus()
                } else {
                    console.error("Error: bluetoothService is null or undefined")
                    refreshing = false
                    refreshTimer.stop()
                }
            }

            // Timer to reset the button state after a delay
            Timer {
                id: refreshTimer
                interval: 2000
                repeat: false
                onTriggered: {
                    refreshButton.refreshing = false
                }
            }

            // Also listen for dataUpdated signal to reset button
            Connections {
                target: bluetoothService
                function onDataUpdated() {
                    refreshButton.refreshing = false
                    refreshTimer.stop()
                }
            }
        }
    }
}
