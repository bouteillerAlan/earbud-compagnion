import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

Item {
    function log(message: string, scope: string) {
        let hour = Qt.formatTime(new Date(), "hh:mm:ss")
        console.log(`A2N.EARBUD: ${hour}: on ${scope}: ${message}`)
    }
}
