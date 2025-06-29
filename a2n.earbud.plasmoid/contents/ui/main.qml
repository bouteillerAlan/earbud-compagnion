import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore

import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

import "../_toolbox" as Tb
import "../service" as Sv

PlasmoidItem {
  id: main

  property int intervalConfig: plasmoid.configuration.updateInterval
  property bool isOnUpdate: false

  // load one instance of each needed service
  Sv.Debug{ id: debug }
  Sv.Updater{ id: updater }
  Sv.Parser{ id: parser }

  // the brain of the widget
  Plasma5Support.DataSource {
      id: cmd
      engine: "executable"
      connectedSources: []

      onNewData: function (sourceName, data) {
        var exitCode = data["exit code"]
        var exitStatus = data["exit status"]
        var stdout = data["stdout"]
        var stderr = data["stderr"]
        exited(sourceName, exitCode, exitStatus, stdout, stderr)
        disconnectSource(sourceName)
      }

      onSourceConnected: function (source) {
        debug.log(`${plasmoid.id}: ${source}`, "onSourceConnected")
        isUpdating(true)
        connected(source)
      }

      onExited: function (cmd, exitCode, exitStatus, stdout, stderr) {
        debug.log(`${plasmoid.id}: ${JSON.stringify({cmd, exitCode, exitStatus, stdout, stderr})}`, "onExited")
        var parsedST = parser.parseBluetoothDevices(stdout)
        newStdoutData(parsedST)
        isUpdating(false)
      }

      // execute the given cmd
      function exec(cmd: string) {
          if (!cmd) return
          connectSource(cmd)
      }

      signal newStdoutData(var data)
      signal isUpdating(bool status)
      signal connected(string source)
      signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
  }

  // execute function count each updateInterval minutes
  Timer {
      id: timer
      interval: intervalConfig * 60000 // minute to milisecond
      running: true
      repeat: true
      triggeredOnStart: true // trigger on start for a first check
      onTriggered: updater.refresh()
  }

  // handle the "show when relevant" property for the systray
  function hasUpdate() {
      // todo true when we have a least one connection
      return true
  }
  Plasmoid.status: hasUpdate() ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus

  // map the UI
  compactRepresentation: Compact {}
  fullRepresentation: Full {}

  // map the context menu
  Plasmoid.contextualActions: [
      PlasmaCore.Action {
          text: i18n("Refresh")
          icon.name: "view-refresh-symbolic"
          onTriggered: {
              updater.refresh()
          }
      }
  ]

  // load the tooltip
  toolTipItem: Loader {
      id: tooltipLoader
      Layout.minimumWidth: item ? item.implicitWidth : 0
      Layout.maximumWidth: item ? item.implicitWidth : 0
      Layout.minimumHeight: item ? item.implicitHeight : 0
      Layout.maximumHeight: item ? item.implicitHeight : 0
      source: "Tooltip.qml"
  }

  Component.onCompleted: {}
}
