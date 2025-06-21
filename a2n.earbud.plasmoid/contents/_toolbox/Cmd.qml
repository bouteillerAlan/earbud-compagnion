import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import "../service" as Sv

Plasma5Support.DataSource {
  id: executable
  engine: "executable"
  connectedSources: []
  property var isRunning: false
  property var queue: []

  Sv.Debug{ id: debug }

  function launchCmdInQueue() {
    debug.log(queue, "launchCmdInQueue()")
    isRunning = true
    connectSource(queue[0])
  }

  function closing() {
    isRunning = false; // Set isRunning to false after 1 second delay
    if (queue.length > 0) {
      launchCmdInQueue(); // If a cmd is still in queue launch it
    } else {
      debug.log("Queue empty", "closing()")
    }
  }

  onNewData: function (sourceName, data) {
    var exitCode = data["exit code"]
    var exitStatus = data["exit status"]
    var stdout = data["stdout"]
    var stderr = data["stderr"]
    exited(sourceName, exitCode, exitStatus, stdout, stderr)
    disconnectSource(sourceName)
  }

  onSourceConnected: function (source) {
    connected(source)
  }

  onExited: function (cmd, exitCode, exitStatus, stdout, stderr) {
    queue.shift() // delete the first value, so this exited cmd
    closing()
  }

  // execute the given cmd
  function exec(cmd: string) {
    if (!cmd) return
    debug.log(`Executing ${cmd}`, "exec()")
    queue.push(cmd)
    if (!isRunning) launchCmdInQueue()
  }

  signal connected(string source)
  signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
}
