import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "components" as Components

// Compact representation for the plasmoid when shown in the panel
MouseArea {
    id: compactRoot

    Layout.minimumWidth: root.iconSize
    Layout.minimumHeight: root.iconSize
    Layout.preferredWidth: root.iconSize
    Layout.preferredHeight: root.iconSize

    property bool wasExpanded
    onPressed: wasExpanded = root.expanded
    onClicked: root.expanded = !wasExpanded

    Components.EarbudIcon {
        anchors.fill: parent
        customColor: root.customColor
        earbudColor: root.earbudColor
        opacityValue: root.opacityValue
        source: "audio-headset" // Fallback to system icon if needed
    }
}
