import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

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

  contentItem: RowLayout {
    ColumnLayout {
      spacing: 2

      Kirigami.Heading {
        id: itemHeading
        level: 3
        width: parent.width
        text: stdoutDataLine.name
      }

      Controls.Label {
        id: itemLabel
        width: parent.width
        wrapMode: Text.Wrap
        text: stdoutDataLine.data.batteryPercentage
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
    opacity: 0.25
    visible: true
  }

}
