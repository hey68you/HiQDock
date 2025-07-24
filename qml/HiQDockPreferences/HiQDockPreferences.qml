import QtQuick 2.5

Rectangle {
    id: topLevelRect

    width: 670
    height: 338
    color: "#ededed"

    signal showHideRunningIndicators(bool show);
    signal setAutoHide(bool shouldAutoHide);
    signal setMagnificationEnabled(bool magnificationEnabled);
    signal valueForSizeUpdated(double percent);
    signal valueForMagnificationUpdated(double percent);
    signal sizeDraggingInProgress(bool isDragging);
    signal setNewScreenPosition(int newScreenPosition);
    signal useNewYosemiteBottomStyle(bool useNewStyle);

    property alias screenPosition: screenPosition;

    QtObject {
        id: screenPosition;

        property int left :  0;  //SCREEN_POSITION_LEFT   0
        property int bottom: 1;  //SCREEN_POSITION_BOTTOM 1
        property int right:  2;  //SCREEN_POSITION_RIGHT  2
        property int top:    3;  //SCREEN_POSITION_TOP    3
    }

    Rectangle {
        id: leftPane
        width: 200//265
        color: "transparent"
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        Text {
            id: lblSize
            x: 0
            y: 18
            width: implicitWidth
            height: 18
            text: qsTr("Size:")
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignBottom
//            font.family: "Helvetica"
//            font.family: "Humnst777 BT"
            font.family: "Noto Sans"
            font.pointSize: 15
            font.bold: false
            anchors.right: parent.right
            anchors.rightMargin: 0
        }

        Text {
            id: lblMagnification
            x: 230
            y: 75
            width: implicitWidth
            height: 18
            text: qsTr("Magnification:")
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignBottom
//            font.family: "Helvetica"
//            font.family: "Humnst777 BT"
            font.family: "Noto Sans"
            font.pointSize: 15
            font.bold: false
//            font.bold: true
            anchors.right: parent.right
            anchors.rightMargin: 0
        }

        CheckBox {
            id: chckBoxMagnification
            anchors.right: lblMagnification.left
            anchors.rightMargin: 4;
            anchors.verticalCenter: lblMagnification.verticalCenter;
            labelString: "";
            selected: magnificationEnabled

            onSelectedChanged: {
                setMagnificationEnabled(selected);
                sliderMagnification.enabled = selected;
            }
        }

        Text {
            id: lblScreenPosition
            x: 230
            y: 130
            width: implicitWidth
            height: 18
            text: qsTr("Position on screen:")
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignBottom
//            font.family: "Helvetica"
//            font.family: "Humnst777 BT"
            font.family: "Noto Sans"
            font.pointSize: 15
            font.bold: false
            anchors.right: parent.right
            anchors.rightMargin: 0
        }

        Text {
            id: lblOtherOptions
            x: 230
            y: 182
            width: implicitWidth
            height: 18
            text: qsTr("Other options:")
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignBottom
//            font.family: "Helvetica"
//            font.family: "Humnst777 BT"
            font.family: "Noto Sans"
            font.pointSize: 15
            font.bold: false
            anchors.right: parent.right
            anchors.rightMargin: 0
        }
    }

    Rectangle {
        id: rightPane
        color: "transparent"
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: leftPane.right
        anchors.leftMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        MacSlider
        {
            id: sliderSize
            y: lblSize.y + (lblSize.height-height)/2;
            x: 0
            height: 22;
            width: 200
            minLabelString: qsTr("Small");
            maxLabelString: qsTr("Large");
            //set this based on last saved setting
//            valuePercent: 64/96; //0.8;
            valuePercent: itemWidth/maxItemSize; //0.8;

            onValueUpdated: {
                //console.log("new Size should be (percent): " + newValuePercent);
                valueForSizeUpdated(newValuePercent);
            }
            onDragingStarted: {
                //console.log("notify dragging (started): " + isDragging);
                sizeDraggingInProgress(isDragging);
            }
        }

        MacSlider
        {
            id: sliderMagnification
            y: lblMagnification.y + (lblMagnification.height-height)/2;
            x: 0
            height: 22;
            width: 200;

            valuePercent: (currentMagnificationIndex/9);
//            valuePercent: (currentMagnificationIndex/9) - 0.05;
//            valuePercent: {
//                var rawValue = (currentMagnificationIndex/9);
//                var correctedPercentage = Math.min(1,rawValue);
//            }

            property double currentMagnificationSliderValue: 0;

            onValueUpdated: {
                //console.log("new Magnification should be (percent): " + newValuePercent);
                //round up trick; in c++ this is cast to an integer
                currentMagnificationSliderValue = newValuePercent+0.05;
                //enforce range to be between 0 to 1:
//                currentMagnificationSliderValue = Math.min(1,newValuePercent+0.05);
//                currentMagnificationSliderValue = Math.max(0,currentMagnificationSliderValue);
            }

            onDragingStarted: {
                //console.log("sliderMagnification: notify dragging (started): " + isDragging + ", currentMagnificationSliderValue = " + currentMagnificationSliderValue);
                if (isDragging == false) {
                    valueForMagnificationUpdated(currentMagnificationSliderValue);
                }
            }
        }

        RadioGroupBox
        {
            id: screenPosRadioBox

            ListModel
            {
                id: radioButtonsModel
//                 QT BUG:  ListElement: cannot use script for property value
//                     ListElement {label: "Left";    isSelected: (currentDockScreenPosition==screenPosition.left); }
            }

            x: 0;
            y: lblScreenPosition.y
            width: 200
            height: 50
            radioButtonValues: radioButtonsModel

            onNewOptionSelected: {
                //console.log("newOptionSelected = " + selectedIndex + ": " + radioButtonsModel.get(selectedIndex).label);
                setNewScreenPosition(selectedIndex);
            }

            Component.onCompleted: {
                radioButtonsModel.append({"label": "Left",   "isSelected":   (currentDockScreenPosition==screenPosition.left)});
                radioButtonsModel.append({"label": "Bottom", "isSelected":   (currentDockScreenPosition==screenPosition.bottom)});
                radioButtonsModel.append({"label": "Right",  "isSelected":   (currentDockScreenPosition==screenPosition.right)});
                radioButtonsModel.append({"label": "Top",    "isSelected":   (currentDockScreenPosition==screenPosition.top)});
             }
        }

        CheckBox {
            id: chckBoxAutoHide
            anchors.left: parent.left
            y: lblOtherOptions.y + (lblOtherOptions.height-height)/2;
            labelString: qsTr("Automatically hide and show the Dock");
            selected: autoHideEnabled;

            onSelectedChanged: {
                //console.log("chckBoxAutoHide " + (selected) ? "selected" : "un-selected");
                setAutoHide(selected);
            }
        }

        CheckBox {
            id: chckShowIndicators
            anchors.left: parent.left
            anchors.top: chckBoxAutoHide.bottom
            anchors.topMargin: 8;
            labelString: qsTr("Show indicator lights for open applications");
            selected: showRunningIndicators;

            onSelectedChanged: {
                if (selected == true)
                {
                    //console.log("chckShowIndicators selected")
                }
                else
                {
                   //console.log("chckShowIndicators un-selected")
                }
                showHideRunningIndicators(selected);
            }
        }

        CheckBox {
            id: chckUseOld3dShelfAndReflectiveIcons
            anchors.left: parent.left
            anchors.top: chckShowIndicators.bottom
            anchors.topMargin: 8;
            labelString: qsTr("Reflecting Icons on 3d Shelf when on Bottom of Screen");
            selected: !newYosemiteBottomStyle;

            onSelectedChanged: {
                useNewYosemiteBottomStyle(!selected);
            }
        }

    }
}
