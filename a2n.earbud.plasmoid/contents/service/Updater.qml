import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import "."

Item {
  Debug{ id: debug }

  /**
   * Executes a Bluetooth device refresh process. This method retrieves the list of Bluetooth devices,
   * extracts their identifiers, and retrieves detailed information about each device using system commands.
   *
   * @return {void} Does not return any value.
   */
  function refresh() {
    const command = plasmoid.configuration.updateCommand || "bluetoothctl devices | grep \"^Device\" | awk '{print $2}' | xargs -I {} sh -c 'echo \"#=== Device {} ===#\" && bluetoothctl info {}'"
    cmd.exec(command)
  }

  function killProcess(process) {
    cmd.exec("kill -9 " + process)
  }

}
