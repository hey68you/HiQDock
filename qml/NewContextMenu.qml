import QtQuick 2.5
import QtQuick.Controls
import QtQuick.Controls.Fusion

Rectangle {
    id: newContextMenuRect
    // width: 200
    // height: 600
    color: 'gray'

    Component.onCompleted: {
        newContextMenu.open()
    }

    Menu  {
        id: newContextMenu

        MenuItem {
            text: "show all"
        }
        MenuItem {
            text: "hide all"
        }
        MenuItem {
            text: "change icon"
        }
    }
}
