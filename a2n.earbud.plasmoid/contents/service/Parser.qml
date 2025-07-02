import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

Item {
  Debug {id: debug}

  /**
   * Cleans up a string by replacing escaped newlines with actual newlines,
   * removing ANSI color codes, trimming whitespace, and filtering out empty lines.
   *
   * @param {string} input - The input string to be cleaned.
   * @return {string[]} An array of cleaned, non-empty lines.
   */
  function cleanLines(input) {
    return input.replace(/\\n/g, '\n')
      .replace(/\u001b\[[0-9;]*m/g, '') // Remove ANSI color codes
      .split('\n')
      .map(line => line.trim())
      .filter(line => line.length > 0);
  }

  /**
   * Saves the current device information into the list of devices.
   *
   * @param {Object} currentDevice - The current device object to be saved. It should include device information like name or alias.
   * @param {Array} devices - The array of devices where the current device is to be saved.
   * @return {void} This function does not return a value.
   */
  function saveCurrentDevice(currentDevice, devices) {
    debug.log(`Device saved ::: ${currentDevice} in ${devices}`, "saveCurrentDevice()")
    devices.push({
      name: currentDevice.name || currentDevice.alias || 'Unknown Device',
      data: currentDevice
    });
  }

  /**
   * Determines if the given line is a property of a device based on a specific regex pattern.
   *
   * @param {string} line - The line to be checked against the property pattern.
   * @return {string[] | null} - Returns an array of matched groups if the line matches the property pattern, or null if it does not match.
   */
  function lineIsPropertyDevice(line) {
    const regex = /(Name|Alias|Class|Icon|Paired|Bonded|Trusted|Blocked|Connected|LegacyPairing|CablePairing|UUID|Modalias|Battery Percentage|Appearance|WakeAllowed):(.*)/
    const lSw = line.match(regex)
    debug.log(`Checking if ${line} is a property: ${lSw}`, "lineIsPropertyDevice")
    return lSw
  }

  /**
   * Parses the input string containing Bluetooth device information and extracts device details.
   *
   * @param {string} input The raw input string listing Bluetooth devices and their properties to be processed.
   * @return {Array<Object>} An array of objects representing parsed Bluetooth devices with their attributes, including address, name, paired status, supported UUIDs, and other properties.
   */
  function parseBluetoothDevices(input) {
    debug.log("Start parsing devices", "parseBluetoothDevices()")
    const devices = [];
    let currentDevice = null; // currently processed device
    let isParsingDevice = false; // flag if we are in the middle of parsing

    const lines = cleanLines(input);

    for (let i = 0; i < lines.length; i++) {
      debug.log(`Start parsing lines ${i}/${lines.length-1}`, "parseBluetoothDevices()")
      const line = lines[i];
      const startOfDeviceLine = line.startsWith('#=== Device')
      const endOfLoop = i === lines.length-1

      debug.log(`New device line found? ${startOfDeviceLine}`, "startOfDeviceLine")

      // if the loop is finish save the device
      if (endOfLoop && currentDevice && isAudioDevice(currentDevice)) {
        debug.log("Loop ended stop parsing devices", "parseBluetoothDevices()")
        saveCurrentDevice(currentDevice, devices)
      }

      if (startOfDeviceLine) {
        debug.log("New device found", "startOfDeviceLine")
        // if we were parsing a previous device, save it
        // before starting another one and reset flags
        if (currentDevice && isAudioDevice(currentDevice)) {
          saveCurrentDevice(currentDevice, devices)
          currentDevice = null;
          isParsingDevice = false;
        }

        // parse the name of the new detected device
        const deviceMatch = line.match(/Device ([A-Fa-f0-9:]+)/);
        if (deviceMatch) {
          currentDevice = {
            address: deviceMatch[1],
            uuids: [],
            supportedUUIDs: []
          };
          isParsingDevice = true;
        }
      } else if (isParsingDevice && lineIsPropertyDevice(line)) {
        debug.log("Start parsing device property", "parseBluetoothDevices()")
        const propertyMatch = lineIsPropertyDevice(line);
        if (propertyMatch && currentDevice) {
          const key = propertyMatch[1].trim();
          const value = propertyMatch[2].trim();

          switch (key) {
            case 'Name':
              currentDevice.name = value;
              break;
            case 'Alias':
              currentDevice.alias = value;
              break;
            case 'Class':
              currentDevice.class = value;
              break;
            case 'Icon':
              currentDevice.icon = value;
              break;
            case 'Paired':
              currentDevice.paired = value === 'yes';
              break;
            case 'Bonded':
              currentDevice.bonded = value === 'yes';
              break;
            case 'Trusted':
              currentDevice.trusted = value === 'yes';
              break;
            case 'Blocked':
              currentDevice.blocked = value === 'yes';
              break;
            case 'Connected':
              currentDevice.connected = value === 'yes';
              break;
            case 'LegacyPairing':
              currentDevice.legacyPairing = value === 'yes';
              break;
            case 'UUID':
              // Parse UUID with description
              const uuidMatch = value.match(/(.+?)\s+\(([^)]+)\)/);
              if (uuidMatch) {
                currentDevice.uuids.push({
                  description: uuidMatch[1].trim(),
                  uuid: uuidMatch[2].trim()
                });
              }
              break;
            case 'Modalias':
              currentDevice.modalias = value;
              break;
            case 'Battery Percentage':
              const batteryMatch = value.match(/0x([0-9A-Fa-f]+)\s+\((\d+)\)/);
              if (batteryMatch) {
                currentDevice.batteryPercentage = parseInt(batteryMatch[2]);
              }
              break;
            default:
              // Store any other properties
              currentDevice[key.toLowerCase().replace(/\s+/g, '_')] = value;
              break;
          }
        }
      }
      // Check for Media/Transport/Endpoint lines or other non-device lines
      else if (line.startsWith('[NEW]') || line.startsWith('Missing device')) {
        debug.log("Doing nothing because of non-device lines", "parseBluetoothDevices()")
        // do nothing
      }
    }
    return devices;
  }

  /**
   * Determines whether the given device is an audio device based on its properties such as icon, class, UUIDs, or name.
   *
   * @param {Object} device - The device object to evaluate. Expected properties include `icon`, `class`, `uuids`, and `name`.
   * @return {boolean} Returns `true` if the device is identified as an audio device, otherwise `false`.
   */
  function isAudioDevice(device) {

    debug.log(`Checking an new device ${JSON.stringify(device)}`, "isAudioDevice")

    // 1. Check icon
    if (device.icon && (
      device.icon.includes('audio') ||
      device.icon.includes('headset') ||
      device.icon.includes('headphone') ||
      device.icon.includes('speaker')
    )) {
      return true;
    }

    // 2. Check device class (audio devices typically have specific class values)
    if (device.class) {
      const classMatch = device.class.match(/0x([0-9A-Fa-f]+)/);
      if (classMatch) {
        const classValue = parseInt(classMatch[1], 16);
        // Audio device classes (major device class = 0x04, minor classes for audio)
        const majorClass = (classValue >> 8) & 0x1F;
        const minorClass = (classValue >> 2) & 0x3F;

        if (majorClass === 0x04) { // Audio/Video major class
          return true;
        }
      }
    }

    // 3. Check UUIDs for audio-related services
    const audioUUIDs = [
      '0000110a-0000-1000-8000-00805f9b34fb', // Advanced Audio Distribution Profile (A2DP) Source
      '0000110b-0000-1000-8000-00805f9b34fb', // Audio Sink (A2DP)
      '0000110c-0000-1000-8000-00805f9b34fb', // A/V Remote Control Target
      '0000110d-0000-1000-8000-00805f9b34fb', // Advanced Audio Distribution
      '0000110e-0000-1000-8000-00805f9b34fb', // A/V Remote Control
      '0000111e-0000-1000-8000-00805f9b34fb'  // Handsfree
    ];

    if (device.uuids && device.uuids.length > 0) {
      return device.uuids.some(uuid =>
        audioUUIDs.includes(uuid.uuid.toLowerCase()) ||
        uuid.description.toLowerCase().includes('audio') ||
        uuid.description.toLowerCase().includes('handsfree') ||
        uuid.description.toLowerCase().includes('headset')
      );
    }

    // 4. Check device name for audio-related keywords
    const name = (device.name || device.alias || '').toLowerCase();
    const audioKeywords = ['headset', 'headphone', 'earbud', 'speaker', 'audio', 'soundbar', 'airpods', 'beats', 'jbl', 'sony', 'bose'];

    return !!audioKeywords.some(keyword => name.includes(keyword));
  }
}
