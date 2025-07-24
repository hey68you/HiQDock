import QtQuick 2.5
//import Effects 1.0

Component
{
    id: launcherCellComponent;

    Rectangle {

        id: oneItem;

        property double              originalX:      model.index * itemWidth
        property bool                isPressed:      false;
        property bool                isRunningApp:   false;
//        property bool                showIndicator:  true;
        property bool                showIndicator:  showRunningIndicators;

        property int                 index:          model.index
        property int                 itemsPadding:   2

        property double              currentLiftOffSet: upperRect.anchors.bottomMargin;

        property SequentialAnimation fadeAndRemoveAnimation: fadeAndRemoveAnimation_;

        signal setChangingIcon(bool changingIcon);
        signal triggerLaunchApp();

        onTriggerLaunchApp:
        {
            mainWin.launch(appsModel.get(model.index)[appStringKey]);
            bounceAnimation.start();
        }

        onSetChangingIcon:
        {
            if (changingIcon) {
                blinkingBorderAnimation.start();
                //console.log("blinkingBorderAnimation start called");
                isChangingIcon = true;
            }
            else {
                //console.log("blinkingBorderAnimation stop called");
                blinkingBorderAnimation.stop();
                changingIconIndicator.opacity = 0;
                isChangingIcon = false;
            }
        }

        SequentialAnimation
        {
            id: blinkingBorderAnimation;
            running: false;
            loops: Animation.Infinite;

//            NumberAnimation { target: upperRect; property: "border.width"; to: 0; duration: 800; }
//            PauseAnimation {duration: 100; }
//            NumberAnimation { target: upperRect; property: "border.width"; to: 3; duration: 800; }
            NumberAnimation { target: changingIconIndicator; property: "opacity"; to: 1; duration: 800; }
            PauseAnimation {duration: 200; }
            NumberAnimation { target: changingIconIndicator; property: "opacity"; to: 0; duration: 800; }
        }

        SequentialAnimation on opacity
        {
            id: fadeAndRemoveAnimation_

            running: false;

            NumberAnimation { target: oneItem; property: "opacity"; to: 0; duration: 750 }
            NumberAnimation { target: oneItem; property: "width";   to: 0; duration: 350 }

            onRunningChanged: {
                if (!running)
                {
                    //console.log("2nd stage width animation finishd: Destroy myself now ! index = " + index);
                    var indexOfItemToRemove = index;
                    appsModel.remove(indexOfItemToRemove);
                    mainWin.itemRemoved(indexOfItemToRemove);
                    calculateTotalWidthNeeded();
                }
            }
        }

        anchors.left: {
            if (cellsLoaded)
            {
                if (oneItem.isPressed)
                {
                    return undefined;
                }

                return anchoredRepeater.itemAt(model.index).left;
            }
            else
            {
                return undefined;
            }
        }

        anchors.leftMargin: {

//                    if (cellPressed)
//                    {
//                        oneItem.anchors.leftMargin;
//                    }

            if (cellsLoaded)
            {
                return leftMarginForItem(oneItem);
            }
            else
            {
                return 0;
            }
        }

        anchors.bottom: parent.bottom;
        anchors.bottomMargin: iconOnShelfPadding;

        LayoutMirroring.enabled: isItemLessThanCurrentHovered(oneItem);

        width:  height;
        height: parabolicHeightForItemAt(oneItem);

        color: "transparent"
//        border.color: "green"
//        border.width: 2

        opacity: (isPressed) ? 0.4 : (debugEnabled) ? 0.75 : 1;

        onXChanged: {
            if (cellMouseArea.drag.active) {
                //fish-eye parabolic animation with will work as this cell is dragged
                currentX = x + cellMouseArea.mouseX;
                if (oneItem.isPressed)
                {
                    cellBeingDragged = yes;

                    moveToIndex = indexForAnchoredItemAtX(currentX);
//                    //console.log("updated: moveToIndex = " + moveToIndex + ": cell being dragged = " + oneItem.index + ": cell is pressed: " + oneItem.isPressed);
                    if (moveToIndex > oneItem.index)
                    {
//                        //console.log("shift hovered cell leftward");
                        //repeaterContainer.itemAt(moveToIndex).opacity = 0;
                    }
                    else if (moveToIndex < oneItem.index)
                    {
//                        //console.log("shift hovered cell rightward");
                    }
                }
            }
        }
//                onYChanged: {
//                    if (cellMouseArea.drag.active) {
//                        //console.log("me: " + model.index + " is moving y= " + y);
//                        if ( y < -oneItem.height)
//                        {
//                            anchorAnimation.enabled = yes;
//                            for (var i=oneItem.index+1; i<appsModel.count; i++)
//                            {
//                                repeaterContainer.itemAt(i).anchors.left = anchoredRepeater.itemAt(i-1).left;
//                            }
//                            repeaterContainer.itemAt(oneItem.index+1).leftMargin = repeaterContainer.itemAt(oneItem.index).leftMargin;
//                        }
//                    }
//                }

        function getImage () {

            var imageName = appsModel.get(model.index)[iconImageKey];
            if (imageName == "")
            {
                return mainWin.getIconBase64UriForFile(appsModel.get(model.index)[appStringKey]);
            }
            else if (imageName.indexOf("qrc:///defaultLauncherIcons/") > -1)
            {
                return appsModel.get(model.index)[iconImageKey];
            }
            else
            {
                var storedImagePath = appsModel.get(model.index)[iconImageKey];
//                console.log("storedImagePath.indexOf('file:')", storedImagePath.indexOf('file:'));

                if (storedImagePath.indexOf('file:') === 0) {
                    return storedImagePath;
                }
                else {
//                    return "file://" + iconPath + "/" + appsModel.get(model.index)[iconImageKey];
                    return "file://" + iconPath + "/" + storedImagePath;
                }
            }
        }


        Rectangle
        {
            id: upperRect

            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.bottom: parent.bottom;
            anchors.bottomMargin: 0;

            width:  parent.width - itemsPadding;
            height: width;

//            color: (index % 2) ? "blue" : "transparent"// "transparent";
            color: "transparent";

            rotation: {
                if (isDockOnSide()) {
                    return -90;
                }
                else if (currentDockScreenPosition==screenPosition.top) {
                    return 180;
                }
                else {
                    return 0;
                }
            }

            transform: Rotation {

                origin.x: (currentDockScreenPosition==screenPosition.top)   ? width/2 : 0;
                origin.y: (currentDockScreenPosition==screenPosition.right) ? width/2 : 0;
                axis     {
                            x: (currentDockScreenPosition==screenPosition.right) ? 1 : 0;
                            y: (currentDockScreenPosition==screenPosition.right) ? 0 : 1;
                            z: 0
                }
                angle:   (currentDockScreenPosition==screenPosition.right || currentDockScreenPosition==screenPosition.top) ? 180 : 0;
            }

            Rectangle
            {
                id: changingIconIndicator
                anchors.fill: parent;
                color: "transparent"
                border.color: "#AC1307"
                border.width: 2;
                radius: 5;
                opacity: 0;
                smooth: true;
            }

            SequentialAnimation
            {
                id: bounceAnimation;
                running: false;


                ParallelAnimation {
                    NumberAnimation {target: upperRect; property: "anchors.bottomMargin";
                        from: 0; to: bounceHeight;
                        easing.type: Easing.OutExpo; duration: 300}

                    NumberAnimation {target: lowerRect; property: "anchors.topMargin";
                        from: 0; to: bounceHeight;
                        easing.type: Easing.OutExpo; duration: 300}
                }

                ParallelAnimation {
                    NumberAnimation {target: lowerRect; property: "anchors.topMargin";
                        from: bounceHeight; to: 0;
                        easing.type: Easing.OutBounce; duration: 700 /*1000*/}

                    NumberAnimation {target: upperRect; property: "anchors.bottomMargin";
                        from: bounceHeight; to: 0;
                        easing.type: Easing.OutBounce; duration: 700 /*1000*/}
                }

                onRunningChanged:
                {
                    if (!running)
                    {
                        //console.log("bounceAnimation finished");
                    }
                }
            }


//********************not as good performance********************\\
//            Image
//            {
//                id: imageInRect
//                anchors.fill: parent;
//
//                source: getImage();
//
//                smooth: true
//                fillMode: Image.PreserveAspectFit
//
//                sourceSize.height: getSourceSize();
//                sourceSize.width:  getSourceSize();
//            }
//****************************************************************\\

            Image
            {
                id: imageInRect
                anchors.fill: parent;

                source: getImage();

                smooth: true
                fillMode: Image.PreserveAspectFit

                visible: (oneItem.height == itemWidth);

                sourceSize.height: (iconResizingInProgress) ?  48 : itemWidth;
                sourceSize.width:  (iconResizingInProgress) ?  48 : itemWidth;
            }

            Image
            {
                id: imageInRectHiRes
                anchors.fill: parent;

                source: getImage();

                smooth: true
                fillMode: Image.PreserveAspectFit

                visible: (!imageInRect.visible);

                sourceSize.height: (iconResizingInProgress) ?  48 : itemWidth*maxGlobalItemScale;
                sourceSize.width:  (iconResizingInProgress) ?  48 : itemWidth*maxGlobalItemScale;
            }
        }

        Rectangle
        {
            id: lowerRect

            anchors.top: upperRect.bottom;
            anchors.horizontalCenter: parent.horizontalCenter;

            width: parent.width - itemsPadding;
            height: iconOnShelfPadding-backgroundShelf.lipHeight; //width; //width/2;

            color: "transparent";
            //@TODO: optimize - use loader tonly this component if position on screen is bottom (and themed).
            visible: ((currentDockScreenPosition!=screenPosition.bottom) || newYosemiteBottomStyle) ? false : true;


            clip: true;

            Image
            {
                id: reflectedImage

//                asynchronous: true;

                visible: !cellMouseArea.drag.active

                opacity: 0.25;
//                effect: Blur {
//                    blurRadius: 10.0
//                }
                // with the clipping this width+height accomplishes making sure the reflected icon only is seen on the top of the shelf and not on the edge (aka lip)
                width: parent.width
                height: upperRect.height;

                source: ((currentDockScreenPosition!=screenPosition.bottom) || newYosemiteBottomStyle) ? "" : getImage();
//                smooth: true
                fillMode: Image.PreserveAspectFit

                transform : Rotation {
                    origin.x : reflectedImage.width / 2
                    origin.y : reflectedImage.height / 2
                    axis.x : 1; axis.y : 0; axis.z : 0
                    angle : 180
                }
            }
        }

        Rectangle
        {
            id: runningIndicator

            anchors.horizontalCenter: parent.horizontalCenter;

            anchors.bottom: parent.bottom;
            anchors.bottomMargin: ((currentDockScreenPosition!=screenPosition.bottom) || newYosemiteBottomStyle) ? -iconOnShelfPadding/2 - 2 : -iconOnShelfPadding+1;
            radius : ((currentDockScreenPosition!=screenPosition.bottom) || newYosemiteBottomStyle) ? 2 : 0;

//            visible: isRunningApp && !cellMouseArea.drag.active && showIndicator;
            opacity: (isRunningApp && !cellMouseArea.drag.active && showIndicator) ? 1 : 0;

            Behavior on opacity { NumberAnimation {duration: 550}}

            color:  Qt.rgba(1,1,1,0.75)
            width:  ((currentDockScreenPosition!=screenPosition.bottom) || newYosemiteBottomStyle) ? 4 : itemWidth/5;
            height: ((currentDockScreenPosition!=screenPosition.bottom) || newYosemiteBottomStyle) ? 4 : backgroundShelf.lipHeight
        }

        MouseArea {

            id: cellMouseArea

//            hoverEnabled: (!isChangingIcon); //true;
            enabled: (!isChangingIcon);

            acceptedButtons: Qt.LeftButton | Qt.RightButton

            anchors.fill: parent

            drag.target: /********************************************************************
                             Tracker/Finder first cell will not be draggable or removable!
                              Also last cell is trash which will not be draggable or removable!
                          *********************************************************************/
            {
                ((model.index == 0) || (model.index == appsModel.count-1) || rightPressOnCell) ? undefined : parent;
            }

            drag.axis: Drag.XandYAxis
            drag.minimumX: 0
//            drag.maximumX: rowContainer.width - 3*itemWidth
            drag.maximumX: rowContainer.width

            drag.minimumY: parent.height - innerMainRotationContainerRect.height
            drag.maximumY: innerMainRotationContainerRect.height

            onCanceled:{
                //console.log("cellMouseArea canceled");
                contextMenuWasShown = yes;
            }

            onClicked:
            {
                //console.log("click on index: " + model.index);

//                if (isChangingIcon)
//                {
//                    //console.log("click not allowed when changingIcon: " + model.index);
//                    return;
//                }
                if (rightPressOnCell)
                {
                    //console.log("launch/activate click not allowed when contextMenu is showing: " + model.index);
                    return;
                }

                //console.log("onClicked: contextMenuWasShown = " + contextMenuWasShown);

//                onExitedDockIcons();

                if (contextMenuWasShown)
                {
                    var newHeight = dockMouseField.height + ((isDockOnSide()) ? toolTip.width :  toolTip.height) + toolTipBottomMargin;

                    if (isDockOnSide()) {
                        mainWin.notifyWidthChanged(newHeight);
                    }
                    else  {
                        mainWin.notifyHeightChanged(newHeight);
                    }
                    return;
                }
                if (isRunningApp)
                {
                    //console.log("app is already running calling show all");
                    doShowHideCloseForTeam(showAll);
                    if (autoHideEnabled)
                    {
                        //console.log("app is already running when autoHideEnabled, isMouseInsideDock = " + isMouseInsideDock);
                        onExitedDockIcons();
//                        updateAutoHide_SLOT(true);
                    }

                    return;
                }

                //console.log("onClicked: " + model.index + " appSig = " + appsModel.get(model.index)[appStringKey]);

                mainWin.launch(appsModel.get(model.index)[appStringKey]);
                bounceAnimation.start();
            }

            function showContextMenu() {

                //console.log("right click do menu for item " + model.index);
                rightPressOnCell = yes;

                var newHeight = dockMouseField.height + ((isDockOnSide()) ? contextMenu.width :  contextMenu.height) + toolTipBottomMargin;

                if (isDockOnSide()) {
                    mainWin.notifyWidthChanged(newHeight);
                }
                else  {
                    mainWin.notifyHeightChanged(newHeight);
                }

                contextMenuWasShown = yes;
            }


            onPressed: {

                //console.log("onPressed");

                if (mouse.button == Qt.RightButton)
                {
                    showContextMenu();
                    return;
                }
                else if (mouse.button != Qt.RightButton)
                {
                    rightPressOnCell = no;
                }

                oneItem.isPressed = true;
                cellPressed = true;
                parent.anchors.bottom = undefined;
                parent.z = appsModel.count + 1;
            }

            onPressAndHold: {
                    showContextMenu();
                    return;
            }

            onReleased:
            {
                oneItem.isPressed = false;
                cellPressed = false;
                parent.anchors.bottom = parent.parent.bottom;
                parent.z = appsModel.count - 1;

                cellBeingDragged = no;

                //console.log("cell mouse onReleased = " + model.index + ": moveToIndex = " + moveToIndex);

                // Don't allow moves to first or last cell (which are static Finder and Trash)
                if ((moveToIndex > 0) && (moveToIndex < appsModel.count-1))
                {
                    var oldIndex = model.index;
                    var newIndex = moveToIndex;

//                    //console.log("b4 move: " + masterAppsModel);

                    appsModel.move(oldIndex, newIndex, 1);
                    mainWin.moveItems(oldIndex, newIndex);

//                    //console.log("after move: " + masterAppsModel);
                }

                moveToIndex = -1;
            }
        }
    }
}
