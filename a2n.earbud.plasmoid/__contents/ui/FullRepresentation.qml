import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import "components" as Components
import "../service/Log.js" as Log

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

    // Reference to the root item in main.qml
    property var rootItem: null

    // Access the BluetoothService through rootItem
    readonly property var bluetoothService: rootItem ? rootItem.bluetoothService : null

    Component.onCompleted: {
        Log.log("FullRepresentation component in FullRepresentation.qml created")
        Log.log("rootItem is " + (rootItem ? "available" : "not available"))
        Log.log("bluetoothService is " + (bluetoothService ? "available" : "not available"))

        // Update the UI with current data
        updateUI()
    }

    // Update UI when bluetoothService property changes
    onBluetoothServiceChanged: {
        Log.log("bluetoothService changed: " + (bluetoothService ? "not null" : "null"))

        if (!bluetoothService) {
            Log.log("Error: No valid bluetoothService reference available")
            noDeviceLabel.visible = true
            deviceListView.visible = false
            return
        }

        Log.log("bluetoothService is available, type: " + typeof bluetoothService)

        try {
            Log.log("bluetoothService properties: " + JSON.stringify(Object.keys(bluetoothService)))
            Log.log("bluetoothService.cmd: " + (bluetoothService.cmd ? "available" : "not available"))
            Log.log("bluetoothService.checkBluetoothStatus: " +
                (typeof bluetoothService.checkBluetoothStatus === 'function' ? "is a function" : "is not a function"))
        } catch (e) {
            Log.log("Error inspecting bluetoothService: " + e)
        }

        updateUI()
    }

    // Function to update the UI with current data
    function updateUI() {
        Log.log("updateUI called")

        if (!bluetoothService) {
            Log.log("Error: No valid bluetoothService reference available in updateUI")
            noDeviceLabel.visible = true
            deviceListView.visible = false
            return
        }

        Log.log("bluetoothService is available in updateUI, type: " + typeof bluetoothService)
        Log.log("bluetoothService.devices: " + (bluetoothService.devices ? "available" : "not available"))

        if (bluetoothService.devices) {
            Log.log("bluetoothService.devices.length: " + bluetoothService.devices.length)
            Log.log("bluetoothService.devices: " + JSON.stringify(bluetoothService.devices))
        }

        try {
            // Update the device list
            deviceListView.model = bluetoothService.devices

            // Show/hide the no devices message
            noDeviceLabel.visible = bluetoothService.devices.length === 0
            deviceListView.visible = bluetoothService.devices.length > 0

            Log.log("UI updated successfully")
        } catch (e) {
            Log.log("Error updating UI: " + e)
            noDeviceLabel.visible = true
            deviceListView.visible = false
        }
    }

    // Connect to the dataUpdated signal from the BluetoothService
    Connections {
        id: bluetoothServiceConnections
        target: bluetoothService
        enabled: target !== null

        Component.onCompleted: {
            Log.log("BluetoothService Connections component created")
            Log.log("target is " + (target ? "available" : "not available"))
            Log.log("enabled is " + enabled)
        }

        function onDataUpdated() {
            Log.log("dataUpdated signal received from bluetoothService")
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
            source: "audio-headset" // Fallback to system icon if needed
        }

        // No device connected message
        Components.NoDevicesMessage {
            id: noDeviceLabel
            Layout.alignment: Qt.AlignHCenter
            visible: true
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
            delegate: Components.DeviceItem {
                deviceName: modelData.name || i18n("Unknown Device")
                deviceIcon: modelData.icon || "audio-headset"
                isConnected: modelData.isConnected
                isAudioDevice: modelData.isAudioDevice
                batteryLevel: modelData.batteryLevel
                deviceType: modelData.icon || i18n("Unknown")
                showBatteryLevel: fullRep.showBatteryLevel
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
                Log.log("Refresh button created")
                Log.log("bluetoothService in refresh button is " + (typeof bluetoothService !== 'undefined' && bluetoothService !== null ? "available" : "not available"))
            }

            onClicked: {
                Log.log("Refresh button clicked")

                if (!bluetoothService) {
                    Log.log("Error: No valid bluetoothService reference available")
                    refreshing = false
                    return
                }

                Log.log("bluetoothService is available, type: " + typeof bluetoothService)

                try {
                    Log.log("bluetoothService properties: " + JSON.stringify(Object.keys(bluetoothService)))
                    Log.log("bluetoothService.cmd: " + (bluetoothService.cmd ? "available" : "not available"))
                    Log.log("bluetoothService.checkBluetoothStatus: " +
                        (typeof bluetoothService.checkBluetoothStatus === 'function' ? "is a function" : "is not a function"))
                } catch (e) {
                    Log.log("Error inspecting bluetoothService: " + e)
                }

                refreshing = true
                refreshTimer.start()

                try {
                    Log.log("Calling checkBluetoothStatus on bluetoothService")
                    bluetoothService.checkBluetoothStatus()
                } catch (e) {
                    Log.log("Error calling checkBluetoothStatus: " + e)
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
                id: serviceConnections
                target: bluetoothService
                enabled: target !== null

                Component.onCompleted: {
                    Log.log("Refresh button Connections component created")
                    Log.log("target is " + (target ? "available" : "not available"))
                }

                function onDataUpdated() {
                    Log.log("dataUpdated signal received in refresh button")
                    refreshButton.refreshing = false
                    refreshTimer.stop()
                }
            }
        }
    }
}
