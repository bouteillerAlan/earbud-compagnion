import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.11
import Qt.labs.platform

Item {
    id: configRoot

    property alias cfg_customColor: checkCustomColor.checked
    property alias cfg_earbudColor: colorDialog.color
    property alias cfg_iconSize: iconSizeSpinBox.value
    property alias cfg_opacity: opacitySpinBox.value
    property alias cfg_updateInterval: updateIntervalSpinBox.value
    property alias cfg_bluetoothCommand: bluetoothCommandField.text
    property alias cfg_showBatteryLevel: showBatteryLevelCheck.checked
    property alias cfg_showDeviceName: showDeviceNameCheck.checked

    ColorDialog {
        id: colorDialog
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: units.largeSpacing
        Layout.fillWidth: true

        GridLayout {
            columns: 2

            Label {
                Layout.minimumWidth: configRoot.width/2
                text: i18n("Use custom color:")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox {
                id: checkCustomColor
            }

            Label {
                Layout.minimumWidth: configRoot.width/2
                text: i18n("Earbud color:")
                horizontalAlignment: Text.AlignRight
                enabled: checkCustomColor.checked
            }

            Item {
                width: 64
                height: 24
                opacity: checkCustomColor.checked ? 1.0 : 0.2
                Rectangle {
                    width: 64
                    radius: 4
                    height: 24
                    border.color: "black"
                    opacity: 0.5
                    color: "transparent"
                    border.width: 2
                }
                Rectangle {
                    color: colorDialog.color
                    border.color: "#B3FFFFFF"
                    border.width: 1
                    width: 64
                    radius: 4
                    height: 24
                    MouseArea {
                        anchors.fill: parent
                        enabled: checkCustomColor.checked
                        onClicked: {
                            colorDialog.open()
                        }
                    }
                }
            }

            Label {
                Layout.minimumWidth: configRoot.width/2
                text: i18n("Icon size:")
                horizontalAlignment: Text.AlignRight
            }

            SpinBox {
                id: iconSizeSpinBox
                from: 16
                to: 64
                stepSize: 4
            }

            Label {
                Layout.minimumWidth: configRoot.width/2
                text: i18n("Opacity:")
                horizontalAlignment: Text.AlignRight
            }

            SpinBox {
                id: opacitySpinBox
                from: 10
                to: 100
                stepSize: 10
            }

            // Separator
            Rectangle {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                height: 1
                color: Qt.rgba(0, 0, 0, 0.2)
            }

            Label {
                Layout.columnSpan: 2
                text: i18n("Bluetooth Settings")
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                Layout.minimumWidth: configRoot.width/2
                text: i18n("Update interval (minutes):")
                horizontalAlignment: Text.AlignRight
            }

            SpinBox {
                id: updateIntervalSpinBox
                from: 1
                to: 60
                stepSize: 1
            }

            Label {
                Layout.minimumWidth: configRoot.width/2
                text: i18n("Bluetooth command:")
                horizontalAlignment: Text.AlignRight
            }

            TextField {
                id: bluetoothCommandField
                Layout.minimumWidth: 200
                Layout.fillWidth: true
                placeholderText: "bluetoothctl info"
                ToolTip.visible: hovered
                ToolTip.text: i18n("Command to get information about connected Bluetooth devices. The default command 'bluetoothctl info' shows details about the currently connected device, including battery level. If you have multiple devices, you can specify a device ID like 'bluetoothctl info XX:XX:XX:XX:XX:XX'.")
                ToolTip.delay: 500
            }

            Label {
                Layout.minimumWidth: configRoot.width/2
                text: i18n("Show battery level:")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox {
                id: showBatteryLevelCheck
            }

            Label {
                Layout.minimumWidth: configRoot.width/2
                text: i18n("Show device name:")
                horizontalAlignment: Text.AlignRight
            }

            CheckBox {
                id: showDeviceNameCheck
            }
        }
    }
}
