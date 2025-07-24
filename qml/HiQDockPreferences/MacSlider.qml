import QtQuick 2.5

Rectangle {
    id: topLevelView
    color: "transparent"
    y: 0;
    x: 0
    height: 22;
    width: 200;

    property bool   enabled        : true;
    property string minLabelString : "Min";
    property string maxLabelString : "Max"
    property int    smallLabelSize : 12
    property double disabledOpacity: 0.4
    property double valuePercent   : 0.5

    property string regularGrabberSVG: "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjxzdmcKICAgeG1sbnM6ZGM9Imh0dHA6Ly9wdXJsLm9yZy9kYy9lbGVtZW50cy8xLjEvIgogICB4bWxuczpjYz0iaHR0cDovL2NyZWF0aXZlY29tbW9ucy5vcmcvbnMjIgogICB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiCiAgIHhtbG5zOnN2Zz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciCiAgIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIKICAgd2lkdGg9IjE2NC42MDc0NyIKICAgaGVpZ2h0PSIxNzcuMTEyMDgiCiAgIHZpZXdCb3g9IjAgMCAxNjQuNjA3NDcgMTc3LjExMjA3IgogICBpZD0ic3ZnNDM2OCIKICAgdmVyc2lvbj0iMS4xIj4KICA8ZGVmcwogICAgIGlkPSJkZWZzNDM3MCIgLz4KICA8bWV0YWRhdGEKICAgICBpZD0ibWV0YWRhdGE0MzczIj4KICAgIDxyZGY6UkRGPgogICAgICA8Y2M6V29yawogICAgICAgICByZGY6YWJvdXQ9IiI+CiAgICAgICAgPGRjOmZvcm1hdD5pbWFnZS9zdmcreG1sPC9kYzpmb3JtYXQ+CiAgICAgICAgPGRjOnR5cGUKICAgICAgICAgICByZGY6cmVzb3VyY2U9Imh0dHA6Ly9wdXJsLm9yZy9kYy9kY21pdHlwZS9TdGlsbEltYWdlIiAvPgogICAgICAgIDxkYzp0aXRsZT48L2RjOnRpdGxlPgogICAgICA8L2NjOldvcms+CiAgICA8L3JkZjpSREY+CiAgPC9tZXRhZGF0YT4KICA8ZwogICAgIGlkPSJsYXllcjEiCiAgICAgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoLTg4LjMyNzczNCwtNjYuMDkwNjAxKSI+CiAgICA8cGF0aAogICAgICAgc3R5bGU9ImZpbGw6I2ZmZmZmZjtmaWxsLW9wYWNpdHk6MTtzdHJva2U6IzAwMDAwMDtzdHJva2Utd2lkdGg6NC4xOTk5OTk4MTtzdHJva2UtbGluZWpvaW46cm91bmQ7c3Ryb2tlLW1pdGVybGltaXQ6NDtzdHJva2UtZGFzaGFycmF5Om5vbmU7c3Ryb2tlLW9wYWNpdHk6MSIKICAgICAgIGQ9Im0gMTE5LjU1OTA3LDY5LjE5MDY0NSBjIC05LjY0NjU1LC0wLjAyOTUgLTI4LjEzMTMzNiwxNy44NTIzNTkgLTI4LjEzMTMzNiwyNy40OTg5NTMgbCAwLDYxLjExNzA0MiBjIDAsOC45MzkxMyA2LjYzNDAyNywxMy43OTY4MSA2LjYzNDAyNywxMy43OTY4MSBsIDcxLjczNDc0OSw2OC4zODE4OCAtMC4zNTQ4NiwwLjAyODEgMC4yMjgzLDAuMDg5NyAtMC4yMDk3NywtMC4xNzUwNCAtMC4wMzQ3LC0wLjMxNTIyIDAuMTA5MzgsMC4xOTkyMiA3NC4xMjcyOCwtNjkuMTQwMTkgMC44MDE5NywtMC45NzY5NCBjIDMuNDY4MzQsLTMuMTc4ODIgNC4wMDE5NiwtNi43OTIyIDQuMTA4MTksLTExLjg4ODM0IGwgMS4yNjA4NiwtNjAuNDg2NjE0IGMgMC4yMDEwNCwtOS42NDQ0OTkgLTE3LjUzOTE1LC0yNy43ODQ2NzEgLTI3LjE4NTcsLTI3LjgxNDE2NyB6IgogICAgICAgaWQ9InJlY3Q0Mzc2IiAvPgogIDwvZz4KPC9zdmc+Cg=="
    property string pressedGrabberSVG: "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjxzdmcKICAgeG1sbnM6ZGM9Imh0dHA6Ly9wdXJsLm9yZy9kYy9lbGVtZW50cy8xLjEvIgogICB4bWxuczpjYz0iaHR0cDovL2NyZWF0aXZlY29tbW9ucy5vcmcvbnMjIgogICB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiCiAgIHhtbG5zOnN2Zz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciCiAgIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIKICAgeG1sbnM6c29kaXBvZGk9Imh0dHA6Ly9zb2RpcG9kaS5zb3VyY2Vmb3JnZS5uZXQvRFREL3NvZGlwb2RpLTAuZHRkIgogICB4bWxuczppbmtzY2FwZT0iaHR0cDovL3d3dy5pbmtzY2FwZS5vcmcvbmFtZXNwYWNlcy9pbmtzY2FwZSIKICAgdmVyc2lvbj0iMS4xIgogICBpZD0ic3ZnNDM2OCIKICAgdmlld0JveD0iMCAwIDE2NC42MDc0NyAxNzcuMTEyMDciCiAgIGhlaWdodD0iMTc3LjExMjA4IgogICB3aWR0aD0iMTY0LjYwNzQ3IgogICBpbmtzY2FwZTp2ZXJzaW9uPSIwLjkxIHIxMzcyNSIKICAgc29kaXBvZGk6ZG9jbmFtZT0iZG93blNsaWRlclRodW1iM05ld19wcmVzc2VkLnN2ZyI+CiAgPHNvZGlwb2RpOm5hbWVkdmlldwogICAgIHBhZ2Vjb2xvcj0iI2ZmZmZmZiIKICAgICBib3JkZXJjb2xvcj0iIzY2NjY2NiIKICAgICBib3JkZXJvcGFjaXR5PSIxIgogICAgIG9iamVjdHRvbGVyYW5jZT0iMTAiCiAgICAgZ3JpZHRvbGVyYW5jZT0iMTAiCiAgICAgZ3VpZGV0b2xlcmFuY2U9IjEwIgogICAgIGlua3NjYXBlOnBhZ2VvcGFjaXR5PSIwIgogICAgIGlua3NjYXBlOnBhZ2VzaGFkb3c9IjIiCiAgICAgaW5rc2NhcGU6d2luZG93LXdpZHRoPSIxNDQwIgogICAgIGlua3NjYXBlOndpbmRvdy1oZWlnaHQ9Ijg1NSIKICAgICBpZD0ibmFtZWR2aWV3NDI1NCIKICAgICBzaG93Z3JpZD0iZmFsc2UiCiAgICAgaW5rc2NhcGU6em9vbT0iMy4xNzI0NDk0IgogICAgIGlua3NjYXBlOmN4PSI3OS42ODY0ODciCiAgICAgaW5rc2NhcGU6Y3k9IjEwMi4zMDIwNSIKICAgICBpbmtzY2FwZTp3aW5kb3cteD0iMzgiCiAgICAgaW5rc2NhcGU6d2luZG93LXk9IjAiCiAgICAgaW5rc2NhcGU6d2luZG93LW1heGltaXplZD0iMCIKICAgICBpbmtzY2FwZTpjdXJyZW50LWxheWVyPSJzdmc0MzY4IgogICAgIGZpdC1tYXJnaW4tdG9wPSIxIgogICAgIGZpdC1tYXJnaW4tbGVmdD0iMSIKICAgICBmaXQtbWFyZ2luLXJpZ2h0PSIxIgogICAgIGZpdC1tYXJnaW4tYm90dG9tPSIxIiAvPgogIDxkZWZzCiAgICAgaWQ9ImRlZnM0MzcwIiAvPgogIDxtZXRhZGF0YQogICAgIGlkPSJtZXRhZGF0YTQzNzMiPgogICAgPHJkZjpSREY+CiAgICAgIDxjYzpXb3JrCiAgICAgICAgIHJkZjphYm91dD0iIj4KICAgICAgICA8ZGM6Zm9ybWF0PmltYWdlL3N2Zyt4bWw8L2RjOmZvcm1hdD4KICAgICAgICA8ZGM6dHlwZQogICAgICAgICAgIHJkZjpyZXNvdXJjZT0iaHR0cDovL3B1cmwub3JnL2RjL2RjbWl0eXBlL1N0aWxsSW1hZ2UiIC8+CiAgICAgICAgPGRjOnRpdGxlIC8+CiAgICAgIDwvY2M6V29yaz4KICAgIDwvcmRmOlJERj4KICA8L21ldGFkYXRhPgogIDxnCiAgICAgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoLTg4LjMyNzczNCwtNjYuMDkwNjAxKSIKICAgICBpZD0ibGF5ZXIxIj4KICAgIDxwYXRoCiAgICAgICBpZD0icmVjdDQzNzYiCiAgICAgICBkPSJtIDExOS41NTkwNyw2OS4xOTA2NDUgYyAtOS42NDY1NSwtMC4wMjk1IC0yOC4xMzEzMzYsMTcuODUyMzU5IC0yOC4xMzEzMzYsMjcuNDk4OTUzIGwgMCw2MS4xMTcwNDIgYyAwLDguOTM5MTMgNi42MzQwMjcsMTMuNzk2ODEgNi42MzQwMjcsMTMuNzk2ODEgbCA3MS43MzQ3NDksNjguMzgxODggLTAuMzU0ODYsMC4wMjgxIDAuMjI4MywwLjA4OTcgLTAuMjA5NzcsLTAuMTc1MDQgLTAuMDM0NywtMC4zMTUyMiAwLjEwOTM4LDAuMTk5MjIgNzQuMTI3MjgsLTY5LjE0MDE5IDAuODAxOTcsLTAuOTc2OTQgYyAzLjQ2ODM0LC0zLjE3ODgyIDQuMDAxOTYsLTYuNzkyMiA0LjEwODE5LC0xMS44ODgzNCBsIDEuMjYwODYsLTYwLjQ4NjYxNCBjIDAuMjAxMDQsLTkuNjQ0NDk5IC0xNy41MzkxNSwtMjcuNzg0NjcxIC0yNy4xODU3LC0yNy44MTQxNjcgeiIKICAgICAgIHN0eWxlPSJmaWxsOiNkN2Q3ZDc7ZmlsbC1vcGFjaXR5OjE7c3Ryb2tlOiMwMDAwMDA7c3Ryb2tlLXdpZHRoOjQuMTk5OTk5ODE7c3Ryb2tlLWxpbmVqb2luOnJvdW5kO3N0cm9rZS1taXRlcmxpbWl0OjQ7c3Ryb2tlLWRhc2hhcnJheTpub25lO3N0cm9rZS1vcGFjaXR5OjEiCiAgICAgICBpbmtzY2FwZTpjb25uZWN0b3ItY3VydmF0dXJlPSIwIgogICAgICAgc29kaXBvZGk6bm9kZXR5cGVzPSJzc3NjY2NjY2NjY2Nzc3NzIiAvPgogIDwvZz4KPC9zdmc+Cg=="

    signal valueUpdated(double newValuePercent);
    signal dragingStarted(bool isDragging);

    Rectangle {
        id: gradientBackground
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: 8
        opacity: (topLevelView.enabled) ? 1 : disabledOpacity;
        smooth: true
        border.color: "gray"
        border.width: 1;
        gradient: Gradient {
            GradientStop { position: 0.0;  color: "#747474" }
            GradientStop { position: 0.75; color: "#cdcdcd" }
            GradientStop { position: 1.0;  color: "#aeaeae" }
        }
    }

    Rectangle
    {
        id: minMaxLabelContainer
        x: 0
        anchors.top: gradientBackground.bottom;
        anchors.topMargin: 9;
        width: parent.width
        height: 22
        color: "transparent";

        Rectangle {
            id: minlineMark
            anchors.left: parent.left
            anchors.leftMargin: grabber.width/2;
            height: 5
            width: 1
            color: "gray"
        }

        Rectangle {
            id: maxlineMark
            anchors.right: parent.right
            anchors.rightMargin: grabber.width/2-1;
            height: 5
            width: 1
            color: "gray"
        }

        Text {
            id: lblMinLabel
            anchors.left: parent.left
            anchors.top: minlineMark.bottom;
            anchors.topMargin: 3
            width: implicitWidth
            height: implicitHeight
            text: qsTr(minLabelString)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignBottom
//            font.family: "Helvetica"
//            font.family: "Humnst777 BT"
            font.family: "Noto Sans"
            font.pointSize: smallLabelSize
//            font.bold: false
        }

        Text {
            id: lblMaxLabel
            anchors.right: parent.right
            anchors.top: minlineMark.bottom;
            anchors.topMargin: 3
            width: implicitWidth
            height: implicitHeight
            text: qsTr(maxLabelString)
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignBottom
//            font.family: "Humnst777 BT"
            font.family: "Noto Sans"
            font.pointSize: smallLabelSize
        }
    }

    Rectangle {
        id: grabber

        property bool isPressed: false;


        onXChanged: {
            //todo: create a signal for this!
//            console.log("grabber percent = " + x/(topLevelView.width - grabber.width));
//            console.log("new grabber x = " + x);
//            valueUpdated(x/(topLevelView.width - grabber.width));
            valueUpdated(x/(topLevelView.width - grabber.width/2));
        }

        opacity: (topLevelView.enabled) ? 1 : disabledOpacity;

//        x: (topLevelView.width - grabber.width/2) * valuePercent; //0;
        x: (topLevelView.width - grabber.width) * valuePercent; //0;
//        x: {
//            //enforce correct x range
//
//            var rawX = (topLevelView.width - grabber.width/2) * valuePercent;
//            var normalizedX = Math.min(topLevelView.w,newValuePercent+0.05);
//Math.max(0,currentMagnificationSliderValue);
//
//
//        }
//        y: 0;
        width: 18;
        height: parent.height - 1;
        anchors.verticalCenter: gradientBackground.verticalCenter;
        anchors.verticalCenterOffset: 3

//        radius: 2
//        border.color: "black"
//        border.width: 1;
//        smooth: true
//        gradient: Gradient {
//            GradientStop { position: 0.0; color: "#f8f8f8" }
//            GradientStop { position: 0.8; color: "gray"    }
//            GradientStop { position: 1.0; color: "#ededed" }
//        }

        color: "transparent"
        Image {
            id: grabberImage
            smooth: true
            anchors.fill: parent
            anchors.margins: 1
            sourceSize.height: parent.height-2;
            sourceSize.width:  parent.width-2;
//            source: (grabber.isPressed) ? "downSliderThumb3New_pressed.svg" : "downSliderThumb3New.svg"
            source: (grabber.isPressed) ? pressedGrabberSVG : regularGrabberSVG;
        }

        MouseArea {
            id: grabberMouseArea
            enabled: topLevelView.enabled;
            anchors.fill: parent
            anchors.margins: -16 // Increase mouse area a lot outside the slider
            drag.target: parent; drag.axis: Drag.XAxis
            drag.minimumX: 0; drag.maximumX: topLevelView.width - grabber.width;

            onPressed: {
                dragingStarted(true);
                //console.log("draging Started");
                grabber.isPressed = true;
            }
            onReleased: {
                dragingStarted(false);
                //console.log("draging Ended");
                grabber.isPressed = false;
            }
        }

        Component.onCompleted: {
            //console.log("valuePercent = " + valuePercent);
            //console.log("grabber x = " + grabber.x);
            //console.log("parent.width = " + parent.width);
        }
    }
}
