import QtQuick
import org.kde.plasma.plasmoid

Item {
    id: bluetoothService

    // Properties for the currently selected device (for backward compatibility)
    property string deviceName: ""
    property int batteryLevel: -1
    property bool isConnected: false
    property string bluetoothCommand: Plasmoid.configuration.bluetoothCommand

    // Reference to the command execution engine from main.qml
    property var cmd: null

    // List of all connected audio devices
    property var devices: []

    signal dataUpdated()

    // Function to execute the bluetoothctl command and parse the output
    function checkBluetoothStatus() {
        console.log("Checking Bluetooth status")

        // Check if cmd is available
        if (!cmd) {
            console.error("Error: cmd object is not available")
            return
        }

        // Reset the devices array
        devices = []
        // Reset values for backward compatibility
        deviceName = ""
        batteryLevel = -1
        isConnected = false

        // Use the configured command or fall back to direct info command
        if (bluetoothCommand && bluetoothCommand !== '') {
            console.log("Executing configured Bluetooth command: " + bluetoothCommand)
            cmd.exec(bluetoothCommand)
        } else {
            // Default to direct info command if no command is configured
            console.log("No command configured, using default 'bluetoothctl info'")
            cmd.exec("bluetoothctl info")
        }
    }

    // Process the list of devices and get info for each one
    function processDeviceList(output) {
        console.log("Processing device list: " + output)

        // Check if cmd is available
        if (!cmd) {
            console.error("Error: cmd object is not available in processDeviceList")
            dataUpdated() // Still emit the signal to update the UI
            return
        }

        // Parse the output to extract device IDs
        var lines = output.split('\n')
        var deviceCount = 0
        var pairedDevices = []

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()

            // Device lines have format: "Device XX:XX:XX:XX:XX:XX Name"
            if (line.indexOf("Device") === 0) {
                // Extract the device ID (MAC address)
                var macAddressMatch = line.match(/Device\s+([0-9A-F:]{17})/i)
                if (macAddressMatch && macAddressMatch[1]) {
                    var deviceId = macAddressMatch[1]
                    console.log("Found device ID: " + deviceId)
                    pairedDevices.push(deviceId)

                    // Get detailed info for this device
                    cmd.exec("bluetoothctl info " + deviceId)
                    deviceCount++
                }
            }
        }

        // If no devices were found, try a different approach
        if (deviceCount === 0) {
            console.log("No devices found with 'bluetoothctl devices', trying direct info command")

            // Try getting info for the default controller
            cmd.exec("bluetoothctl show")

            // Try a direct info command for a specific device if you know its MAC address
            // This is a fallback in case the user has a specific device they want to monitor
            // You can uncomment and modify this line with the MAC address of your device
            // cmd.exec("bluetoothctl info 50:5E:5C:F7:64:A1")

            // Make sure to emit the dataUpdated signal to update the UI
            dataUpdated()
        } else {
            console.log("Found " + deviceCount + " devices: " + pairedDevices.join(", "))
        }
    }

    // Parse the output of the bluetoothctl info command
    function parseBluetoothOutput(output) {
        console.log("Parsing Bluetooth output: " + output)

        // Check if this is a device list output
        if (output.indexOf("Device") === 0 && output.indexOf("devices") !== -1) {
            processDeviceList(output)
            return
        }

        // If this is a direct "bluetoothctl info" output without a device ID,
        // it should still contain device information for the currently connected device

        // Variables to store device information
        var device = {
            id: "",
            name: "",
            alias: "",
            batteryLevel: -1,
            isConnected: false,
            isAudioDevice: false,
            icon: ""
        }

        // Parse the output to extract device information
        var lines = output.split('\n')
        console.log("Number of lines in output: " + lines.length)

        // First line should contain the device ID
        if (lines.length > 0) {
            // Look for the device ID in the first line
            var macAddressMatch = lines[0].match(/Device\s+([0-9A-F:]{17})/i)
            if (macAddressMatch && macAddressMatch[1]) {
                device.id = macAddressMatch[1]
                console.log("Processing device ID: " + device.id)
            } else {
                // If not found in the first line, search through all lines
                for (var j = 0; j < lines.length; j++) {
                    var line = lines[j].trim()
                    if (line.indexOf("Device") === 0) {
                        macAddressMatch = line.match(/Device\s+([0-9A-F:]{17})/i)
                        if (macAddressMatch && macAddressMatch[1]) {
                            device.id = macAddressMatch[1]
                            console.log("Found device ID in line " + j + ": " + device.id)
                            break
                        }
                    }
                }
            }
        }

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()

            // Extract device name
            if (line.indexOf("Name:") !== -1) {
                device.name = line.substring(line.indexOf("Name:") + 5).trim()
                console.log("Found device name: " + device.name)
            } else if (line.indexOf("Alias:") !== -1) {
                // Some devices might use Alias instead of Name
                device.alias = line.substring(line.indexOf("Alias:") + 6).trim()
                console.log("Found device alias: " + device.alias)
            }

            // Check if it's an audio device
            if (line.indexOf("Icon:") !== -1) {
                device.icon = line.substring(line.indexOf("Icon:") + 5).trim()
                console.log("Found device icon: " + device.icon)

                // Check if it's an audio device based on the icon
                // Be more permissive with the icon check
                if (device.icon === "audio-headset" || device.icon === "audio-headphones" ||
                    device.icon === "audio-card" || device.icon.indexOf("audio") !== -1 ||
                    device.icon === "phone" || device.icon.indexOf("headset") !== -1 ||
                    device.icon.indexOf("headphone") !== -1) {
                    device.isAudioDevice = true
                    console.log("Device is an audio device based on icon: " + device.icon)
                }
            }

            // Check for audio-related UUIDs
            if (line.indexOf("UUID:") !== -1) {
                var uuidLine = line.toLowerCase()
                if (uuidLine.indexOf("audio") !== -1 ||
                    uuidLine.indexOf("handsfree") !== -1 ||
                    uuidLine.indexOf("headset") !== -1 ||
                    uuidLine.indexOf("a/v") !== -1 ||
                    uuidLine.indexOf("media") !== -1 ||
                    uuidLine.indexOf("sound") !== -1 ||
                    uuidLine.indexOf("speaker") !== -1 ||
                    uuidLine.indexOf("microphone") !== -1 ||
                    uuidLine.indexOf("phone") !== -1) {
                    device.isAudioDevice = true
                    console.log("Device has audio-related UUID: " + line.substring(line.indexOf("UUID:") + 5).trim())
                }
            }

            // Extract battery level - try different formats
            if (line.indexOf("Battery Percentage:") !== -1) {
                var batteryStr = line.substring(line.indexOf("Battery Percentage:") + 19).trim()
                console.log("Raw battery string: " + batteryStr)

                // Check for hexadecimal format with percentage in parentheses: "0x64 (100)"
                var percentInParentheses = batteryStr.match(/\((\d+)\)/)
                if (percentInParentheses && percentInParentheses[1]) {
                    device.batteryLevel = parseInt(percentInParentheses[1], 10)
                    console.log("Found battery level from parentheses: " + device.batteryLevel)
                }
                // Check for hexadecimal format (0xXX)
                else if (batteryStr.indexOf("0x") === 0) {
                    var hexValue = batteryStr.split(' ')[0]
                    // Convert hex to decimal
                    device.batteryLevel = parseInt(hexValue.substring(2), 16)
                    console.log("Found battery level from hex: " + device.batteryLevel)
                }
                // Check for direct percentage value
                else {
                    var directPercent = parseInt(batteryStr, 10)
                    if (!isNaN(directPercent)) {
                        device.batteryLevel = directPercent
                        console.log("Found battery level from direct value: " + device.batteryLevel)
                    }
                }

                if (isNaN(device.batteryLevel)) {
                    device.batteryLevel = -1
                    console.log("Battery level is not a number")
                }
            }
            // Check for "Battery:" format
            else if (line.indexOf("Battery:") !== -1) {
                var batteryStr = line.substring(line.indexOf("Battery:") + 8).trim()
                console.log("Raw battery string (alt format): " + batteryStr)

                // Try to extract percentage value
                var percentMatch = batteryStr.match(/(\d+)%/)
                if (percentMatch && percentMatch[1]) {
                    device.batteryLevel = parseInt(percentMatch[1], 10)
                    console.log("Found battery level from percentage: " + device.batteryLevel)
                }
            }

            // Check if connected
            if (line.indexOf("Connected:") !== -1) {
                device.isConnected = line.substring(line.indexOf("Connected:") + 10).trim().toLowerCase() === "yes"
                console.log("Device connected: " + device.isConnected)
            } else if (line.indexOf("Status:") !== -1) {
                // Some outputs might use Status instead of Connected
                var status = line.substring(line.indexOf("Status:") + 7).trim().toLowerCase()
                device.isConnected = status === "connected" || status === "yes"
                console.log("Device connected from Status: " + device.isConnected)
            }

            // Check for Class that indicates audio device
            if (line.indexOf("Class:") !== -1) {
                var classStr = line.substring(line.indexOf("Class:") + 6).trim()
                console.log("Device class: " + classStr)

                // Extract the major device class (bits 8-12) and minor device class (bits 2-7)
                // Audio devices have major class 0x04 (Audio/Video)
                if (classStr.indexOf("0x") === 0) {
                    var classValue = parseInt(classStr, 16)
                    var majorClass = (classValue >> 8) & 0x1F // Extract bits 8-12
                    var minorClass = (classValue >> 2) & 0x3F // Extract bits 2-7

                    console.log("Major class: 0x" + majorClass.toString(16) + ", Minor class: 0x" + minorClass.toString(16))

                    // Major class 0x04 is Audio/Video
                    if (majorClass === 0x04) {
                        device.isAudioDevice = true
                        console.log("Device has Audio/Video major class")

                        // Minor class for audio devices:
                        // 0x01 = Headset
                        // 0x02 = Hands-free
                        // 0x04 = Microphone
                        // 0x05 = Loudspeaker
                        // 0x06 = Headphones
                        // 0x07 = Portable Audio
                        // 0x08 = Car Audio
                        // 0x09 = Set-top box
                        // 0x0A = HiFi Audio
                        // 0x0B = VCR
                        // 0x0C = Video Camera
                        // 0x0D = Camcorder
                        // 0x0E = Video Monitor
                        // 0x0F = Video Display and Loudspeaker
                        // 0x10 = Video Conferencing
                        // 0x12 = Gaming/Toy

                        var deviceType = "Unknown Audio Device"
                        switch (minorClass) {
                            case 0x01: deviceType = "Headset"; break;
                            case 0x02: deviceType = "Hands-free"; break;
                            case 0x04: deviceType = "Microphone"; break;
                            case 0x05: deviceType = "Loudspeaker"; break;
                            case 0x06: deviceType = "Headphones"; break;
                            case 0x07: deviceType = "Portable Audio"; break;
                            case 0x08: deviceType = "Car Audio"; break;
                            case 0x09: deviceType = "Set-top box"; break;
                            case 0x0A: deviceType = "HiFi Audio"; break;
                            case 0x0B: deviceType = "VCR"; break;
                            case 0x0C: deviceType = "Video Camera"; break;
                            case 0x0D: deviceType = "Camcorder"; break;
                            case 0x0E: deviceType = "Video Monitor"; break;
                            case 0x0F: deviceType = "Video Display and Loudspeaker"; break;
                            case 0x10: deviceType = "Video Conferencing"; break;
                            case 0x12: deviceType = "Gaming/Toy"; break;
                        }

                        console.log("Device is a " + deviceType)
                    }
                }
            }
        }

        // Use alias as name if name is not available
        if (device.name === "" && device.alias !== "") {
            device.name = device.alias
        }

        // Check if the device has an ID
        if (device.id !== "") {
            console.log("Found device: " + device.name + ", isConnected: " + device.isConnected + ", isAudioDevice: " + device.isAudioDevice)

            // Add all devices, but mark them as audio devices if they match our criteria
            // This ensures we don't miss any potential audio devices
            if (!device.isAudioDevice) {
                // If not already identified as an audio device, check the name for audio-related terms
                var nameLower = (device.name || "").toLowerCase()
                if (nameLower.indexOf("earbud") !== -1 ||
                    nameLower.indexOf("headphone") !== -1 ||
                    nameLower.indexOf("headset") !== -1 ||
                    nameLower.indexOf("speaker") !== -1 ||
                    nameLower.indexOf("audio") !== -1 ||
                    nameLower.indexOf("sound") !== -1 ||
                    nameLower.indexOf("mic") !== -1) {
                    device.isAudioDevice = true
                    console.log("Device identified as audio device based on name: " + device.name)
                }
            }

            // Only add connected devices
            if (device.isConnected) {
                console.log("Adding connected device to list: " + device.name)

                // Check if this device is already in the list
                var exists = false
                for (var j = 0; j < devices.length; j++) {
                    if (devices[j].id === device.id) {
                        // Update the existing device
                        devices[j] = device
                        exists = true
                        break
                    }
                }

                // Add the device if it doesn't exist
                if (!exists) {
                    devices.push(device)
                }

                // Update the single device properties for backward compatibility
                // Use the first connected device that is identified as an audio device, if available
                if ((deviceName === "" || batteryLevel === -1 || !isConnected) && device.isAudioDevice) {
                    deviceName = device.name
                    batteryLevel = device.batteryLevel
                    isConnected = device.isConnected
                }
            } else {
                console.log("Device is not connected, skipping: " + device.name)
            }
        } else {
            console.log("Device has no ID, skipping")
        }

        console.log("Total audio devices found: " + devices.length)

        // If no audio devices were found but we processed at least one device,
        // make sure the UI shows "No audio devices connected"
        if (devices.length === 0 && device.id !== "") {
            console.log("No audio devices found among connected devices")
            deviceName = ""
            batteryLevel = -1
            isConnected = false
        }

        // Emit signal that data has been updated
        dataUpdated()
    }
}
