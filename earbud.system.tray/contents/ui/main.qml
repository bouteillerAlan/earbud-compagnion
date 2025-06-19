import QtQuick
import QtQuick.Layouts 1.2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "components" as Components

PlasmoidItem {
    id: root

    property bool customColor: Plasmoid.configuration.customColor
    property color earbudColor: Plasmoid.configuration.earbudColor
    property int iconSize: Plasmoid.configuration.iconSize
    property int opacityValue: Plasmoid.configuration.opacity

    toolTipMainText: i18n("Earbud")

    Layout.minimumWidth: iconSize
    Layout.minimumHeight: iconSize
    Layout.preferredWidth: iconSize
    Layout.preferredHeight: iconSize

    compactRepresentation: MouseArea {
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
        }
    }

    fullRepresentation: FullRepresentation {
        customColor: root.customColor
        earbudColor: root.earbudColor
        iconSize: root.iconSize
        opacityValue: root.opacityValue
    }
}
