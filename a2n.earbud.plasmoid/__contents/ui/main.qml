import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "components" as Components
import "../_toolbox" as Toolbox
import "../service" as Service
import "../service/Log.js" as Log

PlasmoidItem {
    id: root

    property bool customColor: Plasmoid.configuration.customColor
    property color earbudColor: Plasmoid.configuration.earbudColor
    property int iconSize: Plasmoid.configuration.iconSize
    property int opacityValue: Plasmoid.configuration.opacity
    property int updateInterval: Plasmoid.configuration.updateInterval
    property bool isUpdating: false
    property var bluetoothServiceRef: null // Reference to the bluetoothService for binding

    toolTipMainText: i18n("Earbud")

    Layout.minimumWidth: iconSize
    Layout.minimumHeight: iconSize
    Layout.preferredWidth: iconSize
    Layout.preferredHeight: iconSize

    // Command execution utility
    Toolbox.Cmd {
        id: cmd

        onCommandCompleted: function(command, stdout, stderr, exitCode, exitStatus) {
            root.isUpdating = false
        }
    }

    // Create a property to hold the BluetoothService instance
    // This will be accessible to all components that have a reference to root
    property var bluetoothService: null

    // Initialize the BluetoothService as early as possible
    Component.onCompleted: {
        Log.log("Root component created")

        // Create the BluetoothService instance
        bluetoothService = bluetoothServiceComponent.createObject(root, { "cmd": cmd })

        // Set the bluetoothServiceRef property for backward compatibility
        root.bluetoothServiceRef = bluetoothService

        Log.log("bluetoothService is " + (bluetoothService ? "available" : "not available"))
        Log.log("bluetoothServiceRef is " + (root.bluetoothServiceRef ? "available" : "not available"))

        if (bluetoothService) {
            Log.log("bluetoothService is available in root.onCompleted")
            Log.log("cmd is " + (cmd ? "available" : "not available"))

            // Ensure cmd is properly set
            if (!cmd) {
                Log.log("Error: cmd is not available in root.onCompleted")
            } else {
                Log.log("cmd type in root.onCompleted: " + typeof cmd)
                try {
                    Log.log("cmd properties in root.onCompleted: " + JSON.stringify(Object.keys(cmd)))
                    Log.log("cmd.exec in root.onCompleted: " + (typeof cmd.exec === 'function' ? "is a function" : "is not a function"))
                } catch (e) {
                    Log.log("Error inspecting cmd in root.onCompleted: " + e)
                }
            }
        } else {
            Log.log("Error: bluetoothService is not available in root.onCompleted")
        }
    }

    // Component for creating BluetoothService instances
    Component {
        id: bluetoothServiceComponent
        Service.BluetoothService {}
    }

    // Timer to periodically check Bluetooth status
    Timer {
        id: updateTimer
        interval: updateInterval * 1000 // Convert seconds to milliseconds
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            console.log("Timer triggered")
            console.log("root.isUpdating: " + root.isUpdating)
            console.log("bluetoothService is " + (bluetoothService ? "available" : "not available"))
            console.log("root.bluetoothServiceRef is " + (root.bluetoothServiceRef ? "available" : "not available"))

            // Try to get a valid service reference
            var service = bluetoothService || root.bluetoothServiceRef

            if (service) {
                console.log("Service type in Timer.onTriggered: " + typeof service)
                try {
                    console.log("Service properties in Timer.onTriggered: " + JSON.stringify(Object.keys(service)))
                    console.log("Service.cmd: " + (service.cmd ? "available" : "not available"))
                    console.log("Service.checkBluetoothStatus: " + (typeof service.checkBluetoothStatus === 'function' ? "is a function" : "is not a function"))
                } catch (e) {
                    console.error("Error inspecting service in Timer.onTriggered: " + e)
                }

                if (!root.isUpdating) {
                    console.log("Calling checkBluetoothStatus from Timer.onTriggered")
                    service.checkBluetoothStatus()
                } else {
                    console.log("Not calling checkBluetoothStatus: isUpdating=" + root.isUpdating)
                }
            } else {
                console.error("Error: No valid service reference available in Timer.onTriggered")
            }
        }
    }

    compactRepresentation: Compact {
        // The Compact.qml component has access to root properties
    }

    fullRepresentation: FullRepresentation {
        id: fullRep
        customColor: root.customColor
        earbudColor: root.earbudColor
        iconSize: root.iconSize
        opacityValue: root.opacityValue

        // Pass the root object to FullRepresentation
        // This gives it access to root.bluetoothService
        rootItem: root

        Component.onCompleted: {
            console.log("FullRepresentation component in main.qml created")

            // Trigger a Bluetooth status check when the FullRepresentation is first created
            if (!root.isUpdating && root.bluetoothService) {
                console.log("Triggering Bluetooth status check from FullRepresentation.onCompleted")
                root.bluetoothService.checkBluetoothStatus()
            } else {
                console.log("Not triggering Bluetooth status check: isUpdating=" + root.isUpdating +
                    ", bluetoothService=" + (root.bluetoothService ? "available" : "not available"))
            }
        }
    }
}
