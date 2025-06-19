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

    toolTipMainText: i18n("Earbud")

    Layout.minimumWidth: iconSize
    Layout.minimumHeight: iconSize
    Layout.preferredWidth: iconSize
    Layout.preferredHeight: iconSize

    // Bluetooth service
    Js.BluetoothService {
        id: bluetoothService
        cmd: cmd
    }

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

    // Timer to periodically check Bluetooth status
    Timer {
        id: updateTimer
        interval: updateInterval * 60000 // Convert minutes to milliseconds
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!root.isUpdating && bluetoothService) {
                bluetoothService.checkBluetoothStatus()
            } else if (!bluetoothService) {
                console.error("Error: bluetoothService is null in Timer.onTriggered")
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
        customColor: root.customColor
        earbudColor: root.earbudColor
        iconSize: root.iconSize
        opacityValue: root.opacityValue
        bluetoothService: bluetoothService

        Component.onCompleted: {
            // Trigger a Bluetooth status check when the FullRepresentation is first created
            if (!root.isUpdating && bluetoothService) {
                bluetoothService.checkBluetoothStatus()
            }
        }
    }
}
