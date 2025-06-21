import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import "../service" as Sv

Item {
  Sv.Debug{ id: debug }

  function refresh() {
    debug.log("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    //cmd.exec("")
  }

  function killProcess(process) {
    cmd.exec("kill -9 " + process)
  }

}
