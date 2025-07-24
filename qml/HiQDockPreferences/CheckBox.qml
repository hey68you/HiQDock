import QtQuick 2.5

Rectangle {
    id: topLevelView

    property bool   selected: true;
    property bool   enabled:  true;
    property double disabledOpacity: 0.4;
    property string checkColor: "white"
    property string labelString: "empty"
    property bool   isRadioType: false;
    property int    fixedWidth: 14;
    property int    checkBoxAnimationDuration: 450;

    signal radioClicked();

    width: fixedWidth
    height: fixedWidth

    color: "transparent"

    Rectangle {
        id: boxView
        border.color: "gray"
        border.width: 1;
        radius: (isRadioType) ? fixedWidth/2 : 2;
        opacity: (topLevelView.enabled) ? 1 : 0.4;

        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.verticalCenter: parent.verticalCenter;
        width: fixedWidth
        height: fixedWidth
//        color: (selected) ? "#99999e" : "white"
        color: (isRadioType && selected) ? "#99999e" : "white"
//        color: "#99999e"
        smooth: true

        Rectangle {
            id: radioInnerCircle

            property int innerMargin: 9

            color: "white"
            radius: width/2;

            width: parent.width-innerMargin
            height: parent.height-innerMargin
            smooth: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 1
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 1
            visible: (isRadioType && selected)

            Behavior on width {
                SmoothedAnimation{ velocity: 30 }
            }
            Behavior on height {
                SmoothedAnimation{ velocity: 30 }
            }

            onVisibleChanged: {
                innerMargin = (visible) ? 9 : 1;
            }
        }

        Rectangle {
            id: checkBoxBackground
            anchors.fill: parent
            border.color: "gray"
            border.width: 1;
//            anchors.margins: 1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            radius: boxView.radius
            visible: (!isRadioType)
            opacity: (topLevelView.selected) ? 1 : 0
            color: "#99999e"

            Behavior on opacity { PropertyAnimation { duration: checkBoxAnimationDuration} }
        }

        Image {
            id: checkboxImage
//            source: "checkbox.svgz"
            source: "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjxzdmcKICAgeG1sbnM6ZGM9Imh0dHA6Ly9wdXJsLm9yZy9kYy9lbGVtZW50cy8xLjEvIgogICB4bWxuczpjYz0iaHR0cDovL2NyZWF0aXZlY29tbW9ucy5vcmcvbnMjIgogICB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiCiAgIHhtbG5zOnN2Zz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciCiAgIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIKICAgdmVyc2lvbj0iMS4xIgogICBpZD0ic3ZnMiIKICAgdmlld0JveD0iMCAwIDk1LjQ5OTY2NCAxMTUuODA2MjciCiAgIGhlaWdodD0iMzIuNjgzMTAybW0iCiAgIHdpZHRoPSIyNi45NTIxMjdtbSI+CiAgPGRlZnMKICAgICBpZD0iZGVmczQiIC8+CiAgPG1ldGFkYXRhCiAgICAgaWQ9Im1ldGFkYXRhNyI+CiAgICA8cmRmOlJERj4KICAgICAgPGNjOldvcmsKICAgICAgICAgcmRmOmFib3V0PSIiPgogICAgICAgIDxkYzpmb3JtYXQ+aW1hZ2Uvc3ZnK3htbDwvZGM6Zm9ybWF0PgogICAgICAgIDxkYzp0eXBlCiAgICAgICAgICAgcmRmOnJlc291cmNlPSJodHRwOi8vcHVybC5vcmcvZGMvZGNtaXR5cGUvU3RpbGxJbWFnZSIgLz4KICAgICAgICA8ZGM6dGl0bGU+PC9kYzp0aXRsZT4KICAgICAgPC9jYzpXb3JrPgogICAgPC9yZGY6UkRGPgogIDwvbWV0YWRhdGE+CiAgPGcKICAgICB0cmFuc2Zvcm09InRyYW5zbGF0ZSgtMjYuNjAyMjY1LC0yMzEuNDkwNzgpIgogICAgIGlkPSJsYXllcjEiPgogICAgPHBhdGgKICAgICAgIGlkPSJwYXRoNDEzOCIKICAgICAgIGQ9Im0gMzcuMDM2MDQ4LDI5Ni43MTQ2OCBjIDI1LjgyMTA5NSw0MS4zNjE4MSAyNi4zNjUxMDYsMzguMTkyOCAyNi4zNjUxMDYsMzguMTkyOCBsIDQ2LjQwODczNiwtOTAuMDE5MDkgLTEuMjM4NDYsMS43NTk1MyAwLjcwNDIzLC0wLjcwNDIzIDIuMTUyOTEsLTIuMTUyOTEgMCwwIgogICAgICAgc3R5bGU9ImZpbGw6bm9uZTtmaWxsLXJ1bGU6ZXZlbm9kZDtzdHJva2U6I2ZmZmZmZjtzdHJva2Utd2lkdGg6MTI7c3Ryb2tlLWxpbmVjYXA6YnV0dDtzdHJva2UtbGluZWpvaW46cm91bmQ7c3Ryb2tlLW1pdGVybGltaXQ6NDtzdHJva2UtZGFzaGFycmF5Om5vbmU7c3Ryb2tlLW9wYWNpdHk6MSIgLz4KICA8L2c+Cjwvc3ZnPgo="
            smooth: true
            visible: (!isRadioType)
            opacity: (topLevelView.selected) ? 1 : 0
            width: parent.width-4
            height: parent.height-4
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            sourceSize.height: height;
            sourceSize.width:  width;

            Behavior on opacity { PropertyAnimation { duration: checkBoxAnimationDuration} }
        }

        MouseArea {
            enabled: topLevelView.enabled;
            anchors.fill: parent

            onPressed: {
                boxView.opacity = 0.6;
            }
            onReleased: {
                boxView.opacity = 1;
            }

            onClicked:
            {
                if (isRadioType)
                {
                    radioClicked();
                    return;
                }
                topLevelView.selected = !topLevelView.selected;
            }
        }
    }

    Text {
        id: lblCheckBoxLabel
        x: 0
        y: 0
        width: implicitWidth
        height: implicitHeight
        text: labelString;
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignBottom
//        font.family: "Helvetica"
//        font.family: "Humnst777 BT"
        font.family: "Noto Sans"
        font.pointSize: 15
//        font.bold: false

        anchors {
            left: (isRadioType) ? undefined : parent.right
            leftMargin: (isRadioType) ? 0 : 5
            horizontalCenter: (isRadioType) ? parent.horizontalCenter : undefined;
            top: (isRadioType) ? parent.bottom : undefined;
            topMargin: (isRadioType) ? 8 : 0;
        }
    }
}
