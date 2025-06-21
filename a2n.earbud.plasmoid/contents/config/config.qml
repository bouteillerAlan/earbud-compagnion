import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
         name: i18nc("@title", "General")
         icon: "applications-development-relative"
         source: "config/configGeneral.qml"
    }
}
