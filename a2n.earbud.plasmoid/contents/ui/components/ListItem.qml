import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore

PlasmaComponents.ItemDelegate {
  id: listItem

  // stdoutDataLine is sent via Full.qml/injectList()
  // stdoutDataLine: {
  //     "name": "string",
  //     "data": {
  //         "address": "string",
  //         "uuids": [
  //             {
  //                 "description": "string",
  //                 "uuid": "string"
  //             }
  //         ],
  //         "supportedUUIDs": ["string"],
  //         "name": "string",
  //         "alias": "string",
  //         "class": "string",
  //         "icon": "string",
  //         "paired": "bool",
  //         "bonded": "bool",
  //         "trusted": "bool",
  //         "blocked": "bool",
  //         "connected": "bool",
  //         "legacyPairing": "bool",
  //         "cablepairing": "string",
  //         "modalias": "string",
  //         "batteryPercentage": "int"
  //     }
  // }

  width: parent.width // throw a warning but work anyway

  // Properties for device status
  property bool isConnected: stdoutDataLine.data.connected === true
  property bool isPaired: stdoutDataLine.data.paired === true
  property bool isTrusted: stdoutDataLine.data.trusted === true
  property int batteryLevel: stdoutDataLine.data.batteryPercentage || 0

  // Background color based on connection status
  background: Rectangle {
    color: {
      if (listItem.isConnected) {
        return listItem.hovered ? Qt.rgba(0.2, 0.7, 0.3, 0.2) : Qt.rgba(0.2, 0.7, 0.3, 0.1)
      } else {
        return listItem.hovered ? Qt.rgba(0.5, 0.5, 0.5, 0.2) : "transparent"
      }
    }
    radius: 4
    border.width: 1
    border.color: listItem.isConnected ? Qt.rgba(0.2, 0.7, 0.3, 0.3) : "transparent"
    Behavior on color { ColorAnimation { duration: 150 } }
  }

  contentItem: RowLayout {
    spacing: Kirigami.Units.largeSpacing

    // Device icon or status indicator
    Rectangle {
      Layout.alignment: Qt.AlignVCenter
      Layout.preferredWidth: Kirigami.Units.iconSizes.medium
      Layout.preferredHeight: Kirigami.Units.iconSizes.medium
      radius: width / 2
      color: listItem.isConnected ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.disabledTextColor

      Kirigami.Icon {
        anchors.centerIn: parent
        width: Kirigami.Units.iconSizes.small
        height: Kirigami.Units.iconSizes.small
        source: "network-bluetooth"
        color: "white"
      }
    }

    // Device information
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 2

      RowLayout {
        Layout.fillWidth: true

        Kirigami.Heading {
          id: itemHeading
          level: 3
          Layout.fillWidth: true
          text: stdoutDataLine.name || stdoutDataLine.data.alias || "Unknown Device"
          color: listItem.isConnected ? Kirigami.Theme.activeTextColor : Kirigami.Theme.textColor
        }

        // Connection status text
        Controls.Label {
          text: listItem.isConnected ? "Connected" : "Disconnected"
          color: listItem.isConnected ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.disabledTextColor
          font.italic: !listItem.isConnected
        }
      }

      // Device details
      Controls.Label {
        Layout.fillWidth: true
        text: stdoutDataLine.data.address || ""
        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.8
        opacity: 0.7
        visible: text !== ""
      }

      // Status indicators row
      RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        // Battery indicator
        RowLayout {
          visible: batteryLevel > 0
          spacing: 2

          Kirigami.Icon {
            width: Kirigami.Units.iconSizes.small
            height: Kirigami.Units.iconSizes.small
            source: {
              if (batteryLevel >= 90) "battery-full"
              else if (batteryLevel >= 70) "battery-good"
              else if (batteryLevel >= 40) "battery-medium"
              else if (batteryLevel >= 20) "battery-low"
              else "battery-empty"
            }
            color: {
              if (batteryLevel <= 20) Kirigami.Theme.negativeTextColor
              else if (batteryLevel <= 40) Kirigami.Theme.neutralTextColor
              else Kirigami.Theme.positiveTextColor
            }
          }

          Controls.Label {
            text: batteryLevel + "%"
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.8
            color: {
              if (batteryLevel <= 20) Kirigami.Theme.negativeTextColor
              else if (batteryLevel <= 40) Kirigami.Theme.neutralTextColor
              else Kirigami.Theme.positiveTextColor
            }
          }
        }

        // Status badges
        Row {
          spacing: Kirigami.Units.smallSpacing

          Rectangle {
            visible: listItem.isPaired
            width: pairedText.width + Kirigami.Units.largeSpacing
            height: pairedText.height + Kirigami.Units.smallSpacing
            radius: height / 2
            color: Kirigami.Theme.complementaryBackgroundColor

            Controls.Label {
              id: pairedText
              anchors.centerIn: parent
              text: "Paired"
              font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.7
              color: Kirigami.Theme.complementaryTextColor
            }
          }

          Rectangle {
            visible: listItem.isTrusted
            width: trustedText.width + Kirigami.Units.largeSpacing
            height: trustedText.height + Kirigami.Units.smallSpacing
            radius: height / 2
            color: Kirigami.Theme.highlightColor

            Controls.Label {
              id: trustedText
              anchors.centerIn: parent
              text: "Trusted"
              font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.7
              color: Kirigami.Theme.highlightedTextColor
            }
          }
        }
      }
    }
  }

  // separator
  Rectangle {
    id: headerSeparator
    anchors.bottom: parent.bottom
    width: parent.width
    height: 1
    color: Kirigami.Theme.textColor
    opacity: 0.15
    visible: true
  }
}
