import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

Kirigami.ScrollablePage {
  id: commandConfigPage

  property alias cfg_iconUseCustomColor: iconUseCustomColor.checked
  property alias cfg_iconColor: iconColor.color

  property alias cfg_mainDot: mainDot.checked
  property alias cfg_mainDotUseCustomColor: mainDotUseCustomColor.checked
  property alias cfg_mainDotColor: mainDotColor.color

  ColumnLayout {
    anchors {
      left: parent.left
      top: parent.top
      right: parent.right
    }

    Kirigami.FormLayout {
      Layout.alignment: Qt.AlignLeft
      wideMode: false

      Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Icon"
      }
    }

    Kirigami.FormLayout {
      Layout.alignment: Qt.AlignLeft
      RowLayout {
        Kirigami.FormData.label: "Custom icon color: "
        visible: true
        Controls.CheckBox {
          id: iconUseCustomColor
          checked: cfg_iconUseCustomColor
        }

        KQuickControls.ColorButton {
          id: iconColor
          enabled: iconUseCustomColor.checked
        }
      }
    }

    Kirigami.FormLayout {
      Layout.alignment: Qt.AlignLeft
      wideMode: false

      Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Display"
      }
    }

    Kirigami.InlineMessage {
      Layout.fillWidth: true
      text: "The dot is shown when a device is connected."
      visible: true
    }

    Kirigami.FormLayout {
      Layout.alignment: Qt.AlignLeft
      Controls.CheckBox {
        id: mainDot
        Kirigami.FormData.label: "Show dot: "
        checked: cfg_mainDot
      }

      RowLayout {
        Kirigami.FormData.label: "Custom dot color: "
        visible: mainDot.checked
        Controls.CheckBox {
          id: mainDotUseCustomColor
          checked: cfg_mainDotUseCustomColor
        }

        KQuickControls.ColorButton {
          id: mainDotColor
          enabled: mainDotUseCustomColor.checked
        }
      }
    }
  }
}
