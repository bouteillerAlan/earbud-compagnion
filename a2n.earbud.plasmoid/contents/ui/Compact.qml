import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.workspace.components as WorkspaceComponents
import "components" as Components

Item {
  id: compact

  property string iconUpdate: "earbud.svg"

  Item {
    id: container
    //height: compact.itemSize
    height: 36 // todo fix me
    width: height

    anchors.centerIn: parent

    Components.PlasmoidIcon {
      id: updateIcon
      height: container.height
      width: height
      source: iconUpdate
    }

    WorkspaceComponents.BadgeOverlay {
      anchors {
        bottom: container.bottom
        right: container.right
      }
      text: "x"
      visible: false
      icon: updateIcon
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
