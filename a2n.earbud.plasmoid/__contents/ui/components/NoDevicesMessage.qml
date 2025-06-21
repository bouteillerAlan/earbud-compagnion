import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami

// A reusable component for displaying a message when no devices are connected
ColumnLayout {
    id: root
    Layout.alignment: Qt.AlignHCenter
    visible: true
    spacing: 5

    // Properties
    property string title: i18n("No audio devices connected")
    property string subtitle: i18n("Make sure your Bluetooth device is:")
    property var steps: [
        i18n("1. Turned on and in pairing mode"),
        i18n("2. Paired with your computer"),
        i18n("3. Connected (not just paired)")
    ]

    Label {
        Layout.alignment: Qt.AlignHCenter
        text: root.title
        font.bold: true
    }

    Label {
        Layout.alignment: Qt.AlignHCenter
        text: root.subtitle
        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
    }

    // Create labels for each step
    Repeater {
        model: root.steps
        delegate: Label {
            Layout.alignment: Qt.AlignHCenter
            text: modelData
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
        }
    }
}
