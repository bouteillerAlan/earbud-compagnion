import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

import org.kde.kirigami as Kirigami

Item {
    function log(message: string, scope: string) {
        let date = Qt.formatTime(new Date(), "hh:mm:ss")
        console.log(`A2N.EARBUD: ${date}: on ${scope}: ${message}`)
    }
}
