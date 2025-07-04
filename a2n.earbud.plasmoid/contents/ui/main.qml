import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore

import org.kde.plasma.plasmoid
import org.kde.bluezqt as BluezQt
import org.kde.plasma.private.bluetooth as PlasmaBt

import "../_toolbox" as Tb
import "../service" as Sv

PlasmoidItem {
    id: main

    property var audioDevices: []

    // load one instance of each needed service
    Sv.Debug { id: debug }

    // Signal handlers to notify UI components
    signal newDeviceData(var data)
    signal isUpdating(bool status)

    // Filter for audio devices
    function isAudioDevice(device) {
        if (!device) return false;

        // Check device type
        if (device.type === BluezQt.Device.Headset ||
            device.type === BluezQt.Device.Headphones ||
            device.type === BluezQt.Device.OtherAudio) {
            return true;
        }

        // Check UUIDs for audio services
        const audioUUIDs = [
            BluezQt.Services.AdvancedAudioDistribution,
            BluezQt.Services.AudioSink,
            BluezQt.Services.AudioSource,
            BluezQt.Services.AVRemoteControl,
            BluezQt.Services.AVRemoteControlTarget,
            BluezQt.Services.HandsfreeAudioGateway,
            BluezQt.Services.Headset,
            BluezQt.Services.HeadsetAudioGateway
        ];

        for (let i = 0; i < audioUUIDs.length; i++) {
            if (device.uuids.indexOf(audioUUIDs[i]) !== -1) {
                return true;
            }
        }

        // Check name for audio keywords
        const name = device.name.toLowerCase();
        const audioKeywords = ['headset', 'headphone', 'earbud', 'speaker', 'audio', 'soundbar', 'airpods', 'beats', 'jbl', 'sony', 'bose'];

        for (let i = 0; i < audioKeywords.length; i++) {
            if (name.indexOf(audioKeywords[i]) !== -1) {
                return true;
            }
        }

        return false;
    }

    // Update the list of audio devices
    function updateAudioDevices() {
        isUpdating(true);
        debug.log(`${plasmoid.id}: Updating audio devices`, "updateAudioDevices");

        const devices = BluezQt.Manager.devices;
        const audioDevicesList = [];

        for (let i = 0; i < devices.length; i++) {
            const device = devices[i];
            if (isAudioDevice(device)) {
                audioDevicesList.push({
                    name: device.name,
                    data: {
                        address: device.address,
                        name: device.name,
                        alias: device.name,
                        icon: device.icon,
                        paired: device.paired,
                        trusted: device.trusted,
                        connected: device.connected,
                        batteryPercentage: device.battery ? device.battery.percentage : 0
                    }
                });
            }
        }

        audioDevices = audioDevicesList;
        newDeviceData(audioDevicesList);
        isUpdating(false);

        debug.log(`${plasmoid.id}: Found ${audioDevicesList.length} audio devices`, "updateAudioDevices");
    }

    // Connect to BluezQt signals to update when devices change
    Connections {
        target: BluezQt.Manager

        function onDeviceAdded() {
            updateAudioDevices();
        }

        function onDeviceRemoved() {
            updateAudioDevices();
        }

        function onDeviceChanged() {
            updateAudioDevices();
        }

        function onBluetoothBlockedChanged() {
            updateAudioDevices();
        }

        function onBluetoothOperationalChanged() {
            updateAudioDevices();
        }
    }

    // handle the "show when relevant" property for the systray
    function hasUpdate() {
        return audioDevices.length > 0 && audioDevices[0].data.connected;
    }

    Plasmoid.status: hasUpdate() ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus

    // map the UI
    compactRepresentation: Compact {}
    fullRepresentation: Full {}

    // Create refresh action
    PlasmaCore.Action {
        id: refreshAction
        text: i18n("Refresh")
        icon.name: "view-refresh-symbolic"
        onTriggered: function() {
            updateAudioDevices();
        }
    }

    // load the tooltip
    toolTipItem: Loader {
        id: tooltipLoader
        Layout.minimumWidth: item ? item.implicitWidth : 0
        Layout.maximumWidth: item ? item.implicitWidth : 0
        Layout.minimumHeight: item ? item.implicitHeight : 0
        Layout.maximumHeight: item ? item.implicitHeight : 0
        source: "Tooltip.qml"
    }

    Component.onCompleted: {
        // Add refresh action to context menu
        Plasmoid.setAction("refresh", refreshAction);

        // Initial update
        updateAudioDevices();
    }
}
