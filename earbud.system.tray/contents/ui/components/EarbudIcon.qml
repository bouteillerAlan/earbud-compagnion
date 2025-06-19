import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Item {
    id: iconContainer

    property bool customColor: false
    property color earbudColor: "#ffffff"
    property int opacityValue: 100
    property string source: "earbud" // Default source name

    Kirigami.Icon {
        id: earbudIcon
        anchors.fill: parent
        source: "audio-headset" // Default system icon as fallback
        color: customColor ? earbudColor : Kirigami.Theme.textColor
        opacity: opacityValue / 100
        isMask: true
    }

    Component.onCompleted: {
        // Try to load the icon from different sources in order of preference
        if (plasmoid.file("icons", "earbud.svg")) {
            // If the SVG file exists in the plasmoid's icons directory
            earbudIcon.source = "file://" + plasmoid.file("icons", "earbud.svg");
            console.log("Loaded icon from plasmoid icons directory: " + earbudIcon.source);
        } else if (source) {
            // If a source is provided, try to use it
            earbudIcon.source = source;
            console.log("Using provided source for icon: " + source);
        } else {
            // Fallback to system icon
            earbudIcon.source = "audio-headset";
            console.log("Using fallback system icon: audio-headset");
        }
    }
}
