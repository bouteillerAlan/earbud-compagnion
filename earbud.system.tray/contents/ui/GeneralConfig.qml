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
        }
    }
}
