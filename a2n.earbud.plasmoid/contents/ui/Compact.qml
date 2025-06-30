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
  property string iconUpdate: "earbud.svg"
  property var stdoutData: []

  Connections {
    target: cmd

    function onNewStdoutData(data) {
      if (data.length > 0) stdoutData = data
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
      visible: plasmoid.configuration.mainDot && stdoutData.length > 0 && stdoutData[0].data.connected
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
