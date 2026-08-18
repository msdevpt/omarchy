import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  // Polled from niri so the widget tracks focus/occupancy without the
  // (unavailable) Quickshell.Niri module.
  property var workspaces: []

  function refresh() {
    if (queryProc.running) return
    queryProc.running = true
  }

  function workspaceById(id) {
    for (var i = 0; i < root.workspaces.length; i++) {
      if (root.workspaces[i].id === id) return root.workspaces[i]
    }

    return null
  }

  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5]
    for (var i = 0; i < root.workspaces.length; i++) {
      var id = root.workspaces[i].id
      if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("niri msg action focus-workspace " + id)
    root.refresh()
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.active_window_id !== null
        readonly property bool focused: workspace !== null && workspace.is_focused === true

        bar: root.bar
        text: focused ? "\uDB85\uDCFB" : (modelData === 10 ? "0" : String(modelData))
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }

  Process {
    id: queryProc
    command: ["niri", "msg", "--json", "workspaces"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          root.workspaces = JSON.parse(text || "[]")
        } catch (e) {
          root.workspaces = []
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
