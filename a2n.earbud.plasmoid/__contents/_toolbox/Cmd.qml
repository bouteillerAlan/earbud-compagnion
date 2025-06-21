import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

// A utility component for executing shell commands
Item {
    id: cmdRoot

    // Signal emitted when a command has completed execution
    signal commandCompleted(string command, var stdout, var stderr, int exitCode, string exitStatus)

    // Command execution engine
    Plasma5Support.DataSource {
        id: cmd
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]

            console.log("Command executed: " + sourceName)
            console.log("Exit code: " + exitCode)
            console.log("Exit status: " + exitStatus)
            console.log("Stdout length: " + stdout.length)

            // Only log the first 200 characters of stdout to avoid flooding the console
            if (stdout.length > 200) {
                console.log("Stdout (truncated): " + stdout.substring(0, 200) + "...")
            } else {
                console.log("Stdout: " + stdout)
            }

            // Log errors
            if (stderr !== '') {
                console.log("Error executing command: " + stderr)
            }

            // Emit the commandCompleted signal
            cmdRoot.commandCompleted(sourceName, stdout, stderr, exitCode, exitStatus)

            // Disconnect the source
            disconnectSource(sourceName)
        }

        onSourceConnected: function(source) {
            console.log("Command started: " + source)
        }
    }

    // Execute the given command
    function exec(command) {
        if (!command) return
        console.log("Executing command: " + command)
        cmd.connectSource(command)
    }
}
