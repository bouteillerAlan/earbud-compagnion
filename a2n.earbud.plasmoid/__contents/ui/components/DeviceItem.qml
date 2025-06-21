import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami

// A reusable component for displaying a Bluetooth device in the list
Item {
    id: root
    width: parent ? parent.width : 0
    height: deviceDelegate.height

    // Properties for the device data
    property string deviceName: ""
    property string deviceIcon: "audio-headset"
    property bool isConnected: false
    property bool isAudioDevice: false
    property int batteryLevel: -1
    property string deviceType: ""

    // Property to control visibility of different sections
    property bool showBatteryLevel: true

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
                source: root.deviceIcon || "audio-headset"
                width: 22
                height: 22
            }

            Label {
                text: root.deviceName || i18n("Unknown Device")
                font.bold: true
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Label {
                text: root.isConnected ? i18n("Connected") : i18n("Disconnected")
                color: root.isConnected ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
            }
        }

        // Device type (audio or not)
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 5
            visible: root.deviceIcon !== ""

            Label {
                text: i18n("Type:")
            }

            Label {
                text: root.deviceType || i18n("Unknown")
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Label {
                text: root.isAudioDevice ? i18n("Audio Device") : i18n("Other Device")
                color: root.isAudioDevice ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.neutralTextColor
            }
        }

        // Battery level
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 5
            visible: root.showBatteryLevel

            Label {
                text: i18n("Battery:")
            }

            Label {
                text: root.batteryLevel >= 0 ? root.batteryLevel + "%" : i18n("Unknown")
                Layout.preferredWidth: 60
            }

            ProgressBar {
                Layout.fillWidth: true
                from: 0
                to: 100
                value: root.batteryLevel >= 0 ? root.batteryLevel : 0

                // Color based on battery level
                contentItem: Rectangle {
                    width: parent.visualPosition * parent.width
                    height: parent.height
                    radius: 2
                    color: {
                        if (root.batteryLevel < 0) return Kirigami.Theme.disabledTextColor
                        if (root.batteryLevel < 20) return Kirigami.Theme.negativeTextColor
                        if (root.batteryLevel < 50) return Kirigami.Theme.neutralTextColor
                        return Kirigami.Theme.positiveTextColor
                    }
                }
            }
        }
    }
}
