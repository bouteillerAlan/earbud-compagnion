import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid
import org.kde.bluezqt as BluezQt

ColumnLayout {
  id: root

  property bool onRefresh: false
  property var audioDevices: []

  Connections {
    target: main

    function onIsUpdating(status) {
      onRefresh = status
    }

    function onNewDeviceData(data) {
      if (data.length > 0) {
        audioDevices = data
      }
    }
  }

  // Function to get Bluetooth status message
  function getBluetoothStatusMessage() {
    if (BluezQt.Manager.bluetoothBlocked) {
      return i18n("Bluetooth is disabled");
    }
    if (!BluezQt.Manager.bluetoothOperational) {
      if (BluezQt.Manager.adapters.length === 0) {
        return i18n("No adapters available");
      }
      return i18n("Bluetooth is offline");
    }
    return "";
  }

  ColumnLayout {
    id: mainLayout;
    Layout.topMargin: Kirigami.Units.gridUnit / 2
    Layout.leftMargin: Kirigami.Units.gridUnit / 2
    Layout.bottomMargin: Kirigami.Units.gridUnit / 2
    Layout.rightMargin: Kirigami.Units.gridUnit / 2

    PlasmaExtras.Heading {
      id: tooltipMaintext
      level: 3
      elide: Text.ElideRight
      text: {
        const statusMessage = getBluetoothStatusMessage();
        if (statusMessage) {
          return statusMessage;
        }
        return audioDevices.length > 0 ? audioDevices[0].name : "No device";
      }
    }

    RowLayout {
      visible: !getBluetoothStatusMessage() // Hide when there's a Bluetooth status message
      RowLayout {
        PlasmaComponents3.Label {
          text: "Bat:"
          opacity: 1
        }
        PlasmaComponents3.Label {
          text: audioDevices.length > 0 ? (audioDevices[0].data.batteryPercentage || "Not connected") : "Not connected"
          opacity: .7
        }
      }
      Item { Layout.fillWidth: true }
      // RowLayout {
      //   PlasmaComponents3.Label {
      //     text: "DS:"
      //     opacity: 1
      //   }
      //   PlasmaComponents3.Label {
      //     text: audioDevices.length > 0 && audioDevices[0].data.paired ? "●" : ""
      //     opacity: .7
      //   }
      //   PlasmaComponents3.Label {
      //     text: audioDevices.length > 0 && audioDevices[0].data.bonded ? "●" : ""
      //     opacity: .7
      //   }
      //   PlasmaComponents3.Label {
      //     text: audioDevices.length > 0 && audioDevices[0].data.trusted ? "●" : ""
      //     opacity: .7
      //   }
      // }
    }
  }
}
