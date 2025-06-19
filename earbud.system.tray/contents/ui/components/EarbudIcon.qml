import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Item {
    id: iconContainer

    property bool customColor: false
    property color earbudColor: "#ffffff"
    property int opacityValue: 100

    Kirigami.Icon {
        id: earbudIcon
        anchors.fill: parent
        source: Plasmoid.icon
        color: customColor ? earbudColor : Kirigami.Theme.textColor
        opacity: opacityValue / 100
        isMask: true
    }
}
