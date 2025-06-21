import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

// A reusable component for consistent tooltips
ToolTip {
    id: tooltip

    // Properties
    property string tooltipText: ""
    property int delayTime: 500
    property bool showOnHover: true

    // Set tooltip text
    text: tooltipText

    // Set delay before showing tooltip
    delay: delayTime

    // Show tooltip when parent is hovered
    visible: showOnHover ? parent.hovered : false

    // Style
    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9

    // Function to show tooltip programmatically
    function show() {
        visible = true
    }

    // Function to hide tooltip programmatically
    function hide() {
        visible = false
    }
}
