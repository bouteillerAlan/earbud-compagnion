import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

PlasmaComponents.ItemDelegate {
  id: listItem

  // stdoutDataLine has sent via Full.qml/injectList()
  property string stdoutData: stdoutDataLine

  width: parent.width // throw a warning but work anyway

  contentItem: RowLayout {
    ColumnLayout {
      spacing: 2

      Kirigami.Heading {
        id: itemHeading
        level: 3
        width: parent.width
        text: "something"
      }

      Controls.Label {
        id: itemLabel
        width: parent.width
        wrapMode: Text.Wrap
        text: stdoutData
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
