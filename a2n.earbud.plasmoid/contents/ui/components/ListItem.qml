import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras

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
  implicitHeight: Math.max(Kirigami.Units.iconSizes.medium * 2.5, mainLayout.implicitHeight + Kirigami.Units.largeSpacing) // Ensure enough height for all elements

  // Add hover and click effects
  background: Rectangle {
    color: listItem.hovered ? Kirigami.Theme.highlightColor.toString().replace(/#/, "#15") : "transparent"
    Behavior on color { ColorAnimation { duration: 150 } }
  }

  // Properties for device status
  property string name: stdoutDataLine.data.name
  property string deviceIcon: stdoutDataLine.data.icon
  property string deviceClass: stdoutDataLine.data.class
  property string cablePairing: stdoutDataLine.data.cablepairing
  property string deviceAddress: stdoutDataLine.data.address || ""
  property int batteryLevel: stdoutDataLine.data.batteryPercentage || 0
  property bool isConnected: stdoutDataLine.data.connected === true
  property bool isPaired: stdoutDataLine.data.paired === true
  property bool isTrusted: stdoutDataLine.data.trusted === true
  property bool isBlocked: stdoutDataLine.data.blocked === true
  property bool isBonded: stdoutDataLine.data.bonded === true

  // Helper function to convert boolean to Yes/No text
  function boolToYesNo(value) {
    return value ? i18n("Yes") : i18n("No");
  }

  // Main content container
  RowLayout {
    id: mainLayout
    anchors.fill: parent
    anchors.margins: Kirigami.Units.smallSpacing
    spacing: Kirigami.Units.largeSpacing * 2 // Increased spacing between elements
    height: Math.max(Kirigami.Units.iconSizes.medium * 2, implicitHeight) // Ensure minimum height

    // Device icon
    Kirigami.Icon {
      id: deviceIconItem
      source: deviceIcon || "audio-headphones"
      Layout.preferredWidth: Kirigami.Units.iconSizes.medium
      Layout.preferredHeight: Kirigami.Units.iconSizes.medium
      Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
      opacity: isConnected ? 1.0 : 0.6
    }

    // Device information
    ColumnLayout {
      Layout.fillWidth: true
      Layout.preferredWidth: parent.width * 0.5 // Limit width to 50% of parent
      Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
      spacing: Kirigami.Units.smallSpacing // Increased spacing between elements

      // Device name
      Controls.Label {
        id: nameLabel
        text: name || i18n("Unknown Device")
        font.bold: true
        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.1
        elide: Text.ElideRight
        Layout.fillWidth: true
        opacity: isConnected ? 1.0 : 0.7
      }

      // Device status
      Controls.Label {
        id: statusLabel
        text: {
          let status = [];

          // Connection status
          if (isConnected) {
            status.push(i18n("Connected"));
          } else {
            status.push(i18n("Disconnected"));
          }

          // Paired status
          if (isPaired) {
            status.push(i18n("Paired"));
          }

          // Device class if available
          if (deviceClass) {
            status.push(deviceClass);
          }

          return status.join(" · ");
        }
        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
        opacity: 0.7
        elide: Text.ElideRight
        Layout.fillWidth: true
      }
    }

    // Battery indicator
    ColumnLayout {
      Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
      Layout.preferredWidth: Kirigami.Units.gridUnit * 4 // Fixed width for battery indicator
      Layout.rightMargin: Kirigami.Units.largeSpacing
      spacing: 2
      visible: batteryLevel > 0 || isConnected

      // Battery percentage
      Controls.Label {
        text: batteryLevel > 0 ? batteryLevel + "%" : ""
        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
        horizontalAlignment: Text.AlignHCenter
        Layout.alignment: Qt.AlignHCenter
        visible: batteryLevel > 0
      }

      // Battery visual indicator
      Rectangle {
        id: batteryContainer
        Layout.preferredWidth: Kirigami.Units.gridUnit * 3
        Layout.preferredHeight: Kirigami.Units.gridUnit * 0.7
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 2 // Add a small top margin
        Layout.bottomMargin: 2 // Add a small bottom margin
        color: "transparent"
        border.width: 1
        border.color: Kirigami.Theme.textColor
        opacity: isConnected ? 0.8 : 0.4
        visible: isConnected
        radius: 2

        // Battery level fill
        Rectangle {
          id: batteryLevelIndicator
          anchors.left: parent.left
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          anchors.margins: 2
          width: Math.max(0, (parent.width - 4) * (batteryLevel / 100))
          color: {
            if (batteryLevel > 70) return "#4CAF50"; // Green
            if (batteryLevel > 30) return "#FF9800"; // Orange
            return "#F44336"; // Red
          }
          radius: 1
          visible: batteryLevel > 0
        }

        // No battery data indicator
        Controls.Label {
          anchors.centerIn: parent
          text: "?"
          visible: isConnected && batteryLevel <= 0
          font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.8
          opacity: 0.7
        }
      }
    }

    // Connection indicator
    Rectangle {
      id: connectionIndicator
      Layout.preferredWidth: Kirigami.Units.largeSpacing
      Layout.preferredHeight: Kirigami.Units.largeSpacing
      Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
      Layout.rightMargin: Kirigami.Units.smallSpacing
      radius: width / 2
      color: isConnected ? "#4CAF50" : "#F44336" // Green if connected, red if disconnected
      opacity: isConnected ? 1.0 : 0.6

      // Pulsing animation for connected devices
      SequentialAnimation {
        running: isConnected
        loops: Animation.Infinite

        PropertyAnimation {
          target: connectionIndicator
          property: "opacity"
          from: 1.0
          to: 0.6
          duration: 1500
          easing.type: Easing.InOutQuad
        }

        PropertyAnimation {
          target: connectionIndicator
          property: "opacity"
          from: 0.6
          to: 1.0
          duration: 1500
          easing.type: Easing.InOutQuad
        }
      }
    }
  }

  // Tooltip with detailed device information
  PlasmaComponents.ToolTip {
    text: {
      let title = name || i18n("Unknown Device");
      let details = [];

      // Device address
      if (deviceAddress) {
        details.push(i18n("Address: %1", deviceAddress));
      }

      // Connection status
      details.push(i18n("Connected: %1", boolToYesNo(isConnected)));

      // Paired status
      details.push(i18n("Paired: %1", boolToYesNo(isPaired)));

      // Trusted status
      details.push(i18n("Trusted: %1", boolToYesNo(isTrusted)));

      // Battery level
      if (batteryLevel > 0) {
        details.push(i18n("Battery: %1%", batteryLevel));
      }

      // Device class
      if (deviceClass) {
        details.push(i18n("Class: %1", deviceClass));
      }

      return title + "\n\n" + details.join("\n");
    }
  }

  // separator
  Rectangle {
    id: headerSeparator
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 1 // Add a small margin to prevent overlap with next item
    width: parent.width
    height: 1
    color: Kirigami.Theme.textColor
    opacity: 0.15
    visible: true
  }
}
