import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.active-window"

  // Polled from niri; `focusedWindow` is the raw JSON object (or null).
  property var focusedWindow: null
  readonly property string title: focusedWindow
    ? (focusedWindow.title || focusedWindow.app_id || "")
    : ""
  readonly property int maxLabelWidth: Number(setting("maxWidth", 280))

  function refresh() {
    if (queryProc.running) return
    queryProc.running = true
  }

  visible: title !== "" && !vertical
  implicitWidth: visible ? Math.min(maxLabelWidth, labelText.implicitWidth) + Style.spacing.controlPaddingX * 2 : 0
  implicitHeight: barSize

  Behavior on implicitWidth {
    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
  }

  Item {
    anchors.fill: parent
    anchors.leftMargin: Style.space(8)
    anchors.rightMargin: Style.space(8)
    clip: true

    Text {
      id: labelText
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      width: parent.width
      text: root.title
      color: root.bar ? root.bar.barForeground : Color.foreground
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.body
      elide: Text.ElideRight
      opacity: 0.85
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor

    onClicked: function(mouse) {
      if (!root.focusedWindow || root.focusedWindow.id === undefined || !root.bar) return
      var id = root.focusedWindow.id
      if (mouse.button === Qt.MiddleButton) {
        root.bar.run("niri msg action close-window " + id)
      } else if (mouse.button === Qt.RightButton) {
        root.bar.run("niri msg action close-window " + id)
      } else {
        root.bar.run("niri msg action focus-window " + id)
      }
    }
    onEntered: if (root.bar) root.bar.showTooltip(root, root.title)
    onExited: if (root.bar) root.bar.hideTooltip(root)
  }

  Process {
    id: queryProc
    command: ["niri", "msg", "--json", "focused-window"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var win = JSON.parse(text || "null")
          root.focusedWindow = (win && typeof win === "object" && win.id !== undefined) ? win : null
        } catch (e) {
          root.focusedWindow = null
        }
      }
    }
  }

  Timer {
    interval: 500
    repeat: true
    running: true
    onTriggered: root.refresh()
  }

  Component.onCompleted: root.refresh()
}
