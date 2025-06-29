import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

ColumnLayout {
  id: root

  property bool onRefresh: false
  property bool onError: false
  property string errorMessage: ""
  property var stdoutData: []

  Connections {
    target: cmd

    function onConnected(source) {
      onError = false
    }

    function onIsUpdating(status) {
      onRefresh = status
    }

    function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
      if (stderr !== '') {
        onError = true
        errorMessage = stderr
      }
    }

    function onNewStdoutData(data) {
      if (data.length > 0) {
        stdoutData = data
      }
    }
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
          text: stdoutData[0].name || "No device"
      }

      RowLayout {
          RowLayout {
              PlasmaComponents3.Label {
                  text: "Bat:"
                  opacity: 1
              }
              PlasmaComponents3.Label {
                  text: stdoutData[0].data.batteryPercentage
                  opacity: .7
              }
          }
          Item { Layout.fillWidth: true }
          // RowLayout {
          //     PlasmaComponents3.Label {
          //         text: "AUR:"
          //         opacity: 1
          //     }
          //     PlasmaComponents3.Label {
          //         text: totalAur
          //         opacity: .7
          //     }
          // }
      }
  }
}
