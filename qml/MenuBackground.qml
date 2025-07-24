import QtQuick 2.5

Rectangle {
    id: outermostRect
    width:  300
    height: 430

    color: "transparent"

    property double globalBorderWidth:       2;
    property double pointerWidth:            28;
    property double outmostMostBottomMargin: 60;
    property bool   showBorder:              true;
    property bool   showCallOutTriangle:     true;
//    property color  globalBackgroundColor:   (showBorder) ? Qt.rgba(0,0,0,0.75) : "transparent";
    property color  globalBackgroundColor:   Qt.rgba(0,0,0,0.75);
    property color  globalBorderColor:       (showBorder) ? Qt.rgba(1,1,1,0.5) : globalBackgroundColor;
    property double pointerSidesLength:      Math.sqrt(Math.pow(pointerWidth,2)/2); //a^2 + b^2 = c^2 (see: http://www.algebra.com/algebra/homework/Triangles/Triangles.faq.question.539395.html)

    Rectangle {
        id: topRect
//        height: 29
        color: "transparent"

        clip: true

        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: outmostMostBottomMargin;
//        height: 160;

        Rectangle
        {
            id: innerTopRect
            color: globalBackgroundColor;

            border.color: globalBorderColor;
            border.width: globalBorderWidth;

            radius: 12;
//            smooth: true;

            x: border.width-1;
            y: border.width-1;

            width:  parent.width-border.width*2;
            height: outermostRect.height;
        }
    }

    Rectangle
    {
        id: bottomLeftCorner

        color: "transparent"
//        smooth: true
        clip: true

        anchors.top: topRect.bottom
        anchors.topMargin: 0
//        anchors.right: parent.right
//        anchors.rightMargin: parent.width-anchors.bottomMargin/2;
        width: 18;
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: outmostMostBottomMargin/2;

        Rectangle
        {
            id: innerBottomLeftCorner
            color: globalBackgroundColor;

            border.color: globalBorderColor;
            border.width: globalBorderWidth;

            radius: 12;
//            smooth: true;

            x: border.width-1;
            y: -20;

            width: parent.width+20;
            height: 20 + parent.height - border.width - 1;
        }
    }

    Rectangle {
        id: areaAbovePointerContainer

        height: outermostRect.height - topRect.height;
        width: pointerWidth - 1;

        clip: true;

//        smooth: true;

        color: "transparent"
//        color: "blue"

        anchors.top: bottomRightCorner.top;
//        anchors.top: topRect.bottom
//        anchors.topMargin: 0

        anchors.left: bottomLeftCorner.right


        Rectangle {
            id: topInnerPointContainer

//            smooth: true;
            color: globalBackgroundColor

            x: -1;
//            y: -20;

            width: parent.width + 1

            anchors.top: parent.top;

            height: outmostMostBottomMargin/2 - globalBorderWidth*2 + (showCallOutTriangle ? 0 : 1) ;
        }

        Rectangle {
            id: bottomInnerPointerContainer

            color: "transparent"; //"green"

            width: parent.width

            anchors.top: topInnerPointContainer.bottom;

            height: 20;
            clip: true;
//            smooth: true;

            visible: showCallOutTriangle;

            Rectangle {

                id: pointerInsideWithBorder

                color: globalBackgroundColor
                border.color: globalBorderColor
                border.width: globalBorderWidth;

                smooth: true;

                height: pointerSidesLength;
                width: pointerSidesLength;

                y: -pointerWidth/2 + globalBorderWidth*2 + 0.5 //+ 1;
                x: globalBorderWidth*2 /*+ 0.75*/ ; ///0.75;

                rotation: -45;
            }
        }
    }

    Rectangle {
        id: bottomRightCorner

        clip: true;
//        smooth: true;

        color: "transparent"

        anchors.top: topRect.bottom
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.left: areaAbovePointerContainer.right;
        anchors.leftMargin: 0;
        anchors.bottom: parent.bottom
        anchors.bottomMargin: outmostMostBottomMargin/2;

//        z: 1

        Rectangle
        {
            id: innerBottomRightCorner
            color: globalBackgroundColor;

            border.color: globalBorderColor;
            border.width: globalBorderWidth;

            radius: 12;
//            smooth: true;

            x: -20;
            y: -20;

            width: parent.width + 20 - border.width - 1;
            height: 20 + parent.height - border.width - 1;
        }
    }
}
