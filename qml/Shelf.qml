import QtQuick 2.5

Rectangle {

    //color: (debugEnabled) ? "black" : "transparent";
    color: (debugEnabled)  ?  Qt.rgba(0,0,0,0.4) : "transparent";

    property string gradientStartColor:  (isDockOnSide() || (currentDockScreenPosition==screenPosition.top) || newYosemiteBottomStyle) ? "#686868" : "#908F90"
    property string gradientEndColor:    (isDockOnSide() || (currentDockScreenPosition==screenPosition.top) || newYosemiteBottomStyle) ? "#484C48" : "#D0D0D0"
    property string shelfBorderColor:    "#D8D8D8"

    property double lipFactor:    0.075;//0.1075;
    property double lipHeight:    itemWidth*lipFactor;  //*0.10

    height: itemWidth*1.15;

    smooth: true;

    Rectangle {

        color: "transparent" //"green"

        width: parent.width;
        height: lipHeight*(1+lipFactor); //1.15//1.10//16.5;
        clip: true;
        anchors.top: mainShelf.bottom;

//        visible: false

        Rectangle {

            id: lipRectangle

            x: 0
            height: parent.height*2;//16.5
            anchors.bottom: parent.bottom;
            anchors.left: parent.left;
            anchors.leftMargin: 2;
            anchors.right: parent.right;
            anchors.rightMargin: 2;

            color: gradientStartColor //"black" //"blue"//
            radius : 3 //6//3 //5
            opacity: 0.85 //1.0

            visible: (isDockOnSide() || (currentDockScreenPosition==screenPosition.top) || newYosemiteBottomStyle) ? false : true;
        }
    }

    Rectangle {

        id: mainShelf

//        visible: false

        x: 0;
//        width: parent.width - ((isDockOnSide() || newYosemiteBottomStyle) ? (2 * itemWidth) : itemWidth/2);
        // height: (isDockOnSide() || (currentDockScreenPosition==screenPosition.top)|| newYosemiteBottomStyle) ? parent.height + 25: parent.height;
        height: (isDockOnSide() || (currentDockScreenPosition==screenPosition.top)|| newYosemiteBottomStyle) ? parent.height + iconOnShelfPadding*1.3: parent.height;

        anchors.bottom: parent.bottom;
        // anchors.bottomMargin: (isDockOnSide() || (currentDockScreenPosition==screenPosition.top) || newYosemiteBottomStyle) ? -10 : lipHeight + 1;
        anchors.bottomMargin: (isDockOnSide() || (currentDockScreenPosition==screenPosition.top) || newYosemiteBottomStyle) ? 4 : lipHeight + 1;
////        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.left: parent.left
//        anchors.leftMargin: (isDockOnSide() || newYosemiteBottomStyle) ? itemWidth/2 : 0
        anchors.right: parent.right
//        anchors.rightMargin: (isDockOnSide() || newYosemiteBottomStyle) ? itemWidth/2 : 0

        transform : Rotation {
            origin.x : mainShelf.width / 2
            origin.y : mainShelf.height;
            axis { x: 1; y: 0; z: 0 }
            angle :  (isDockOnSide() || (currentDockScreenPosition==screenPosition.top) || newYosemiteBottomStyle) ? 0 : 40; //55//45
        }

        radius: (isDockOnSide() || (currentDockScreenPosition==screenPosition.top) || newYosemiteBottomStyle) ? 10 : 5

        border.color: "black"
        border.width: (isDockOnSide() || (currentDockScreenPosition==screenPosition.top) || newYosemiteBottomStyle) ? 1 : 0;

        smooth: true
        gradient: Gradient {
            GradientStop { position: 0.0; color: gradientStartColor }
//            GradientStop { position: 0.94; color: gradientEndColor   }
//            GradientStop { position: 0.99; color: "white" }
//            GradientStop { position: 1.0; color: "white" }
            GradientStop { position: 1.0; color: gradientEndColor }
        }
        opacity: (isDockOnSide() || newYosemiteBottomStyle) ? 0.6 : 0.85 //1.0

//        Rectangle
//        {
//            color: "red"//"white" //"#E1E1E1"//"white" //"red" //gradientStartColor //
//
//            anchors.top: parent.bottom;
//            anchors.topMargin: 1;
//            width: parent.width - parent.radius*2;
//            anchors.horizontalCenter: parent.horizontalCenter;
//            height: 1
//            z: 10
//        }
    }

    Rectangle
    {
        id: whiteThinLine
        visible: (isDockOnSide() || (currentDockScreenPosition==screenPosition.top) || newYosemiteBottomStyle) ? false : true

        color: "white" //"#E1E1E1"//"white" //"red" //gradientStartColor //

        anchors.top: mainShelf.bottom;
        anchors.topMargin: -1;
        width: mainShelf.width - mainShelf.radius*2;
        anchors.horizontalCenter: mainShelf.horizontalCenter;
        height: 1
        opacity: 0.85;
//        z: 10
    }
}
