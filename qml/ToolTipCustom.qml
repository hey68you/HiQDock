import QtQuick 2.5

Rectangle
{
    id: toolTipParent

    color: (isDockOnSide()) ? Qt.rgba(0,0,0,0.65) : "transparent";
    radius: (isDockOnSide() || newYosemiteBottomStyle) ? 4 : 12;
//    smooth: true;

    property string tipString: "-";
    property Text toolTipTextLabel: toolTipTextLabel_;
    property int topBottomPadding: 6;
    property int sidesPadding:     20;

    height: toolTipTextLabel.implicitHeight+topBottomPadding;
    width: toolTipTextLabel.implicitWidth+sidesPadding;

    rotation: (isDockOnSide()) ? -90 : 0;

    transform : Rotation {
        origin.x : 0
        origin.y : toolTipBottomMargin/2
        axis { x: 1; y: 0; z: 0 }
        angle :  (currentDockScreenPosition==screenPosition.right) ? 180 : 0;
    }


//==============


    Row {
        visible: (!isDockOnSide())

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter:   parent.verticalCenter;
            verticalCenterOffset: 4
        }
        Image {
            source: "./macToolTip_left_s.png"
            width: 8
            height: 39
        }
        Image {
            source: "./macToolTip_center_s.png"
            width: Math.floor((toolTipParent.width - 20 - 16*2)/2 + 2*8)
            height: 39
        }

        Image {
            source: "./macToolTip_center.png"
            width: 20
            height: 39
        }
        Image {
            source: "./macToolTip_center_s.png"
            width: Math.floor((toolTipParent.width - 20 - 16*2)/2 + 2*8)
            height: 39
        }

        Image {
            source: "./macToolTip_right_s.png"
            width: 8
            height: 39
        }
    }



//==============





    Text {

        id: toolTipTextLabel_;
        anchors {
            horizontalCenter: parent.horizontalCenter;
            verticalCenter:   parent.verticalCenter;
//            verticalCenterOffset: 10
        }
//        smooth: true;
        text: parent.tipString;
        font.bold: true;

        font.pixelSize: 15;
        font.family: "Humnst777 BT"//"Century Gothic"

        style: Text.Raised;
        styleColor: "black"
        color: "white"

        transform : Rotation {
            origin.x: 0
            origin.y: height/2 - topBottomPadding/2;
            axis { x: 1; y: 0; z: 0 }
            angle :  (currentDockScreenPosition==screenPosition.top) ? 180 : 0;
        }
    }

/*    Text {
        id: bottomArrowPoint
        anchors {
            horizontalCenter: parent.horizontalCenter;
            top: toolTipTextLabel_.bottom;
            topMargin: -2;
        }
        text: "▼";
        font.pointSize: 16;
        font.family: "Noto Sans";
        font.bold: true;

        color: parent.color;

        visible: (isDockOnSide()) ? false : true;
    }
*/
}
