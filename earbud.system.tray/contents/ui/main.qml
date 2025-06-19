import QtQuick
import QtQuick.Layouts 1.2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import "components" as Components
import "js" as Js

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

    // Command execution engine
    Plasma5Support.DataSource {
        id: cmd
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]

            console.log("Command executed: " + sourceName)
            console.log("Exit code: " + exitCode)
            console.log("Exit status: " + exitStatus)
            console.log("Stdout length: " + stdout.length)

            // Only log the first 200 characters of stdout to avoid flooding the console
            if (stdout.length > 200) {
                console.log("Stdout (truncated): " + stdout.substring(0, 200) + "...")
            } else {
                console.log("Stdout: " + stdout)
            }

            // Process the command output
            // Always parse the output for any bluetoothctl command
            if (sourceName.indexOf("bluetoothctl") !== -1) {
                console.log("Processing output for Bluetooth command")
                bluetoothService.parseBluetoothOutput(stdout)
            } else {
                console.log("Command is not a bluetoothctl command")
                console.log("Source name: " + sourceName)
            }

            // Log errors
            if (stderr !== '') {
                console.log("Error executing command: " + stderr)
            }

            // Disconnect the source
            disconnectSource(sourceName)
            root.isUpdating = false
        }

        onSourceConnected: function(source) {
            console.log("Command started: " + source)
            root.isUpdating = true
        }

        // Execute the given command
        function exec(cmd) {
            if (!cmd) return
            console.log("Executing command: " + cmd)
            connectSource(cmd)
        }
    }

    // Create a property to hold the BluetoothService instance
    // This will be accessible to all components that have a reference to root
    property var bluetoothService: null

    // Initialize the BluetoothService as early as possible
    Component.onCompleted: {
        console.log("Root component created")

        // Create the BluetoothService instance
        bluetoothService = bluetoothServiceComponent.createObject(root, { "cmd": cmd })

        // Set the bluetoothServiceRef property for backward compatibility
        root.bluetoothServiceRef = bluetoothService

        console.log("bluetoothService is " + (bluetoothService ? "available" : "not available"))
        console.log("bluetoothServiceRef is " + (root.bluetoothServiceRef ? "available" : "not available"))

        if (bluetoothService) {
            console.log("bluetoothService is available in root.onCompleted")
            console.log("cmd is " + (cmd ? "available" : "not available"))

            // Ensure cmd is properly set
            if (!cmd) {
                console.error("Error: cmd is not available in root.onCompleted")
            } else {
                console.log("cmd type in root.onCompleted: " + typeof cmd)
                try {
                    console.log("cmd properties in root.onCompleted: " + JSON.stringify(Object.keys(cmd)))
                    console.log("cmd.exec in root.onCompleted: " + (typeof cmd.exec === 'function' ? "is a function" : "is not a function"))
                } catch (e) {
                    console.error("Error inspecting cmd in root.onCompleted: " + e)
                }
            }
        } else {
            console.error("Error: bluetoothService is not available in root.onCompleted")
        }
    }

    // Component for creating BluetoothService instances
    Component {
        id: bluetoothServiceComponent
        Js.BluetoothService {}
    }

    // Timer to periodically check Bluetooth status
    Timer {
        id: updateTimer
        interval: updateInterval * 60000 // Convert minutes to milliseconds
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

    compactRepresentation: MouseArea {
        id: compactRoot

        Layout.minimumWidth: root.iconSize
        Layout.minimumHeight: root.iconSize
        Layout.preferredWidth: root.iconSize
        Layout.preferredHeight: root.iconSize

        property bool wasExpanded
        onPressed: wasExpanded = root.expanded
        onClicked: root.expanded = !wasExpanded

        Components.EarbudIcon {
            anchors.fill: parent
            customColor: root.customColor
            earbudColor: root.earbudColor
            opacityValue: root.opacityValue
        }
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
