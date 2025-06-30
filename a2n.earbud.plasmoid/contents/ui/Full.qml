import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

import "components" as Components
import "../service" as Sv

PlasmaExtras.Representation {
  id: full

  focus: true
  anchors.fill: parent

  Layout.minimumHeight: 200
  Layout.minimumWidth: 200
  Layout.maximumWidth: 400

  property bool onRefresh: false
  property bool onError: false
  property string errorMessage: ""
  property var stdoutData: []

  // list of the devices
  Sv.Parser{ id: parser }
  Sv.Debug{ id: debug }
  ListModel { id: devicesListModel }

  function refresh() {
    if (!onRefresh) updater.refresh()
  }

  // each line should be one bluetooth device
  function injectList(data) {
    if (data.length === 0) return;
    data.forEach((value) => {
      devicesListModel.append({ stdoutDataLine: value });
    })
  }

  // map the cmd signal
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
        devicesListModel.clear()
        injectList(data)
      }
    }
  }

  // topbar
  RowLayout {
    id: header
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    width: parent.width

    RowLayout {
      Layout.alignment: Qt.AlignLeft
      spacing: 0

      Controls.Label {
        height: Kirigami.Units.iconSizes.medium
        text: 'Earbud companion'
      }
    }

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: 0

      PlasmaComponents.BusyIndicator {
        id: busyIndicatorCheckUpdatesIcon
        visible: onRefresh
      }

      PlasmaComponents.ToolButton {
        id: checkUpdatesIcon
        height: Kirigami.Units.iconSizes.medium
        icon.name: "view-refresh-symbolic"
        display: PlasmaComponents.AbstractButton.IconOnly
        text: i18n("Refresh")
        visible: !onRefresh
        onClicked: refresh()
        PlasmaComponents.ToolTip {
          text: parent.text
        }
      }
    }
  }

  // separator
  Rectangle {
    id: headerSeparator
    anchors.top: header.bottom
    width: parent.width
    height: 1
    color: Kirigami.Theme.textColor
    opacity: 0.25
    visible: true
  }

  // page view for the list
  Kirigami.ScrollablePage {
    id: scrollView
    visible: !onRefresh && !onError
    background: Rectangle {
      anchors.fill: parent
      color: "transparent"
    }
    anchors.top: headerSeparator.bottom
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    ListView {
      id: packageView
      anchors.rightMargin: Kirigami.Units.gridUnit
      model: devicesListModel
      delegate: Components.ListItem {} // automatically inject the data from the model
      spacing: Kirigami.Units.smallSpacing // Add spacing between list items
    }
  }

  // no data detected
  PlasmaExtras.PlaceholderMessage {
    id: listEmptyMessage
    text: i18n("No earbud detected!")
    anchors.centerIn: parent
    visible: !onRefresh && !onError && stdoutData.length === 0
  }

  // if an error happend
  Controls.Label {
    id: errorLabel
    width: parent.width
    text: i18n("Hu ho something is wrong\n" + errorMessage)
    anchors.centerIn: parent
    visible: onError
    wrapMode: Text.Wrap
  }

  // loading indicator
  PlasmaComponents.BusyIndicator {
    id: busyIndicator
    anchors.centerIn: parent
    visible: onRefresh  && !onError
  }

  Component.onCompleted: {
    refresh()
  }
}
