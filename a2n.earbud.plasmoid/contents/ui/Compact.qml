import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.workspace.components as WorkspaceComponents
import "components" as Components

Item {
  id: compact

  property real itemSize: Math.min(compact.height, compact.width)
  property string iconUpdate: "earbud_icon.svg"
  property var audioDevices: []

  Connections {
    target: main

    function onNewDeviceData(data) {
      if (data.length > 0) audioDevices = data
    }
  }

  Item {
    id: container
    height: compact.itemSize
    width: height

    anchors.centerIn: parent

    Components.PlasmoidIcon {
      id: updateIcon
      height: container.height
      width: height
      source: iconUpdate
    }

    Rectangle {
      visible: plasmoid.configuration.mainDot && audioDevices.length > 0 && audioDevices[0].data.connected
      height: container.height / 2.5
      width: height
      radius: height / 2
      color: plasmoid.configuration.mainDotUseCustomColor ? plasmoid.configuration.mainDotColor : "#4CAF50"
      anchors {
        right: container.right
        bottom: container.bottom
      }
    }

    MouseArea {
      anchors.fill: container // cover all the zone
      cursorShape: Qt.PointingHandCursor // give user feedback
      property bool wasExpanded
      onPressed: wasExpanded = main.expanded
      onClicked: main.expanded = !wasExpanded
    }
  }
}
