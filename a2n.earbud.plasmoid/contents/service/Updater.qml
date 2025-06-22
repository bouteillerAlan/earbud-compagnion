import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import "."

Item {
  Debug{ id: debug }

  function refresh() {
    cmd.exec("bluetoothctl info")
  }

  function killProcess(process) {
    cmd.exec("kill -9 " + process)
  }

}
