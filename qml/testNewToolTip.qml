import QtQuick 2.5

Rectangle {

    height: 39;
    width: toollabel.implicitWidth + 20 + 2*8
//    color: 'blue'

    Row {
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        Image {
            source: "./macToolTip_left_s.png"
            width: 8
            height: 39
        }
        Image {
            source: "./macToolTip_center_s.png"
            width: (toollabel.implicitWidth-20-16*2)/2 + 2*8
            height: 39
        }

        Image {
            source: "./macToolTip_center.png"
            width: 20
            height: 39
        }
        Image {
            source: "./macToolTip_center_s.png"
            width: (toollabel.implicitWidth-20-16*2)/2 + 2*8
            height: 39
        }

        Image {
            source: "./macToolTip_right_s.png"
            width: 8
            height: 39
        }
    }
    Rectangle {
        color: 'green'
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
//            topMargin: 6
            bottom: parent.bottom
//            bottomMargin: 10 //eye-balled
        }

        Text {
            id: toollabel
            text: qsTr("Visual Studio Code")
            color: 'white'
            font.bold: true
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
        }
    }
}
