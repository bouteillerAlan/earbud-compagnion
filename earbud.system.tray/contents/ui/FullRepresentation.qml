import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "components" as Components

Item {
    id: fullRep

    property bool customColor: false
    property color earbudColor: "#ffffff"
    property int iconSize: 24
    property int opacityValue: 100

    Layout.minimumWidth: iconSize +10
    Layout.minimumHeight: iconSize
    Layout.preferredWidth: iconSize + 10
    Layout.preferredHeight: iconSize

    Components.EarbudIcon {
        id: iconContainer
        anchors.fill: parent
        customColor: fullRep.customColor
        earbudColor: fullRep.earbudColor
        opacityValue: fullRep.opacityValue
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            // You can add functionality here if needed
            console.log("Earbud icon clicked in full representation")
        }
    }
}
