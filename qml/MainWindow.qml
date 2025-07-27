import QtQuick 2.5

Rectangle {

    id: fullAppWindow

    x: 0;
    y: 0;
    width: 30; //adjusted dynamically based on itemWidth and number of launchers
    //approx = itemWidth*globalItemScale + 2*left or right margins + top space for the context menu
    height: itemWidth * 2.5 + 60 + 200 + 30;// + (rightPressOnCell) ? 200 : 0; //TODO: move this in on component Completed: //itemWidth*globalItemScale + 60; //600

//    anchors.bottom: parent.bottom;

    //color: (debugEnabled) ? "#3a585a" : "transparent";
    color: "transparent";

//    color: "#306498"//"gray";

    property bool    yes:                  true;
    property bool    no:                   false;

    property double  currentX:             0;
                                           // ACCEPTABLE RANGE of item width (32 px - 96 px).

    property int     range:                maxItemSize - minItemSize;

    property double  iconOnShelfPadding:   itemWidth*0.33;
    property double  totalWidthCalc:       0;

    property int     mouseInOutAnimationDuration:  200;  //100; //1000;// 70; //100;
    property int     toolTipFadeDuration:  300;  //100; //1000;// 70; //100;
    property int     bounceHeight:         50;

                                           // ACCEPTABLE RANGE of globalItemScale 1 - 3 or  4.25
    property double  globalItemScale:      1;


    //Magnification
    property variant availableMagnifications: [ /*0*/ {scale: 1.25, curve: 0.12},
                                                /*1*/ {scale: 1.75, curve: 0.095},
                                                /*2*/ {scale: 2,    curve: 0.099},
                                                /*3*/ {scale: 2.25, curve: 0.145},
                                                /*4*/ {scale: 2.5,  curve: 0.15},
                                                /*5*/ {scale: 2.75, curve: 0.1733},
                                                /*6*/ {scale: 3,    curve: 0.2},
                                                /*7*/ {scale: 3.25, curve: 0.225},
                                                /*8*/ {scale: 3.75, curve: 0.2793},
                                                /*9*/ {scale: 4.25, curve: 0.333}]

//    property int     currentMagnificationIndex: 7;
    property double  selectedItemScale:    availableMagnifications[currentMagnificationIndex].scale;
    property double  selectedCurve:        availableMagnifications[currentMagnificationIndex].curve;
//    property string  newMagnificationIndex: currentMagnificationIndex
//    property double  selectedItemScale:    availableMagnifications[newMagnificationIndex].scale;
//    property double  selectedCurve:        availableMagnifications[newMagnificationIndex].curve;

    property double  maxGlobalItemScale:   (magnificationEnabled) ? selectedItemScale : 1;
    property double  curve:                selectedCurve;

    property int     toolTipBottomMargin:  18;
    property double  sidePadding:          itemWidth*0.25;

    property double  origGlobalItemScale:  1;

    property Repeater anchoredRepeater:    anchorDebugLinesRepeater;

    property bool    cellsLoaded:          no;
    property bool    cellPressed:          no;
    property bool    rightPressOnCell:     no;
    property bool    cellBeingDragged:     no;
    property bool    isChangingIcon:       no;

    property bool    debugEnabled:         /*yes; //*/no;

    property bool    isMouseInsideDock:    no;

    property bool    contextMenuWasShown:  no;

    property int     moveToIndex:          -1;

//    property bool    newYosemiteBottomStyle: yes//no;

    /*********************************************************************************\
    //== These are defined in the mainWindow.cpp and passed into the QML from the c++:
            property string  appStringKey:   "appString";
            property string  toolTipKey:     "toolTipText";
            property string  iconImageKey:   "iconImage";

            property int     hideAll:         HIDE_ALL  //0;
            property int     showAll:         SHOW_ALL  //1;
            property int     closeAll:        CLOSE_ALL //2;
            property double  itemWidth:       36
            property bool    autoHideEnabled: yes;
            property bool    magnificationEnabled: yes;
            property bool    showRunningIndicators: yes;
            property int     minItemSize:          16;//24-4; //32-4;
            property int     maxItemSize:          128;//96+4;
            property bool    newYosemiteBottomStyle: yes//no;


            property string  iconPath:        "HiQDockIcons";

            property bool    iconResizingInProgress:  no;


    \**********************************************************************************/

    property alias mouseState: mouseState;

    QtObject {
        id: mouseState;
        property int inside:        0;
        property int outside:       1;
        property int inContextMenu: 2;
        property int unknown:       3;
    }

    property alias screenPosition: screenPosition;

    QtObject {
        id: screenPosition;

        property int left :  0;  //SCREEN_POSITION_LEFT   0
        property int bottom: 1;  //SCREEN_POSITION_BOTTOM 1
        property int right:  2;  //SCREEN_POSITION_RIGHT  2
        property int top:    3;  //SCREEN_POSITION_TOP    3
    }

//    Image {
//        id: backgroundImage;
//        fillMode: Image.Tile;
//        source: "natfl027.jpg"; //"enlightenment-N3.png"
//        anchors.fill: parent;
//    }

    //called from cpp main window
    function addLauncher_SLOT(jsonDataString, index) // slot
    {
        //console.log("addLauncher received in QML function: " + jsonDataString + " at index = " + index);

        var jsonObj = JSON.parse (jsonDataString);
        //console.log("jsonObj[appStringKey] = " + jsonObj[appStringKey] + "; jsonObj[iconImageKey] = " + jsonObj[iconImageKey] + "; jsonObj[toolTipKey] = " + jsonObj[toolTipKey]);

        //*******************************************************************************************************
        // this insert doesn't work: for some reason I must move newly added item to get it to anchor correctly,
        // but I don't understand yet why
        //
        //  appsModel.insert(index, jsonObj);
        //
        //*******************************************************************************************************

        appsModel.append(jsonObj);
//        // plus one becaue we just added one to the count
        appsModel.move(appsModel.count - 1, index, 1);

        var appSigString = appsModel.get(index)[appStringKey];
        var isRunning = mainWin.isAppRunning(appSigString);
        repeaterContainer.itemAt(index).isRunningApp = isRunning;

        calculateTotalWidthNeeded();
    }

    //called from cpp main window
    function updateToNewIconImageForItemAt_SLOT(pathToIcon, indexOfItem)
    {
        //console.log("updateToNewIconImageForItemAt received in QML function: " + pathToIcon + " at index = " + indexOfItem);
        if (pathToIcon.length > 0)
        {
            //optional syntax:
            //   appsModel.setProperty(indexOfItem, iconImageKey, pathToIcon);
            appsModel.get(indexOfItem)[iconImageKey] = pathToIcon;
            var jsonDataString = JSON.stringify (appsModel.get(indexOfItem));
            mainWin.updateIconImageInMasterListForItemAt(indexOfItem, jsonDataString);
        }

        var itemToUnHighlight = repeaterContainer.itemAt(indexOfItem);
        //console.log("updateToNewIconImageForItemAt_SLOT: itemToUnHighlight = " + itemToUnHighlight);
        itemToUnHighlight.setChangingIcon(no);
    }

    //called by cpp main window
    function appLaunched_SLOT(appSigString)
    {
        //console.log("in QML app was launched: " + appSigString);
        for (var i=0; i<appsModel.count; i++)
        {
            var oneAppSigString = appsModel.get(i)[appStringKey];

            if (oneAppSigString.toUpperCase() == appSigString.toUpperCase())
            {
                //console.log("in QML app setting to running app: " + appSigString);

                repeaterContainer.itemAt(i).isRunningApp = yes;
                break;
            }
        }
    }

    //called by cpp main window
    function appQuit_SLOT(appSigString)
    {
        //console.log("in QML: app quit: " + appSigString + "; but might still have more running instances (teams)");
        for (var i=0; i<appsModel.count; i++)
        {
            var oneAppSigString = appsModel.get(i)[appStringKey];

            if (oneAppSigString.toUpperCase() == appSigString.toUpperCase())
            {
                //console.log("in QML app querying cpp to find out if other instances are still running: " + appSigString);

                var isRunning = mainWin.isAppRunning(appSigString);
                repeaterContainer.itemAt(i).isRunningApp = isRunning;
                break;
            }
        }
    }

    function dockWasActivated_SLOT()
    {
        //console.log("in QML: got notification that dock was activated autoHideEnabled = " + autoHideEnabled + ", isMouseInsideDock = " +isMouseInsideDock);
        if (autoHideEnabled && !isMouseInsideDock)
        {
            //console.log("autoHideEnabled && !isMouseInsideDock");

            onEnteredDockIcons();
            enteredAnimation.start();
            toolTipeFadeInAnimation.start();
        }
    }

    function dockWasDeactivated_SLOT()
    {
        //console.log("in QML: got notification that dock was deactivated");
        onExitedDockIcons();
        exitedAnimation.start();
        toolTipeFadeAnimation.start();
    }

    function updateAutoHide_SLOT(autoHide)
    {
        //console.log("in QML: got notification to change autoHideEnabled to: " + autoHide);
        if (!autoHideEnabled)
        {
            mainWin.notifyInsideDock(true);

            rowContainer.newBottomMargin = rowContainer.showingMargin;
            rowContainer.showHide.start();
        }
        else
        {
//            rowContainer.showHide.complete();
            rowContainer.newBottomMargin = rowContainer.hiddenMargin;
            rowContainer.showHide.start();
        }
    }

    function updateMagnificationEnabled_SLOT(enable)
    {
//        console.log("updateMagnificationEnabled_SLOT: " + enable);
        calculateTotalWidthNeeded();
    }

    function notifyQMLValueForSizeUpdated_SLOT(newPercent)
    {
        var newItemSize = Math.floor(newPercent*range + minItemSize);
//        if (Math.abs(newItemSize-itemWidth) > 1)
        if ((Math.abs(newItemSize-itemWidth) > 1) && ((newItemSize % 2) == 0))
        {
            var currentMaxWidth = (isDockOnSide()) ? windowMaxHeight : windowMaxWidth;

            if (newItemSize*appsModel.count > currentMaxWidth)
            {
                //console.log("newItemSize too big for screen width");
                var maxNewItemWidth = currentMaxWidth/appsModel.count;
                if (newItemSize >= maxNewItemWidth) {
                    return;
                }
                else
                {
                    newItemSize = maxNewItemWidth;
                }
            }

            iconResizingInProgress = yes;

            mainWin.notifyNewItemWidth(newItemSize);
            //console.log("new itemWidth = " + itemWidth);
            //console.log("backgroundShelf height = " + backgroundShelf.height);
            calculateTotalWidthNeeded();

            if (isDockOnSide())
            {
                mainWin.notifyWidthChanged(dockMouseField.height);
            }
            else  {
                mainWin.notifyHeightChanged(dockMouseField.height);
            }
        }

        iconResizingInProgress = no;
    }

    function updateNewScreenPosition_SLOT(newScreenPosition)
    {
        //console.log("updateNewScreenPosition_SLOT = " + newScreenPosition);
    }

    function isDockOnSide()
    {
        return ((currentDockScreenPosition == screenPosition.left) || (currentDockScreenPosition == screenPosition.right));
    }

    function doShowHideCloseForTeam(task)
    {
        var indexOfItem = indexForAnchoredItemAtX(currentX);

        var appSigString = appsModel.get(indexOfItem)[appStringKey];
        //console.log("do 'hideShowQuit' task: " + task + " for app = " + appSigString);
        mainWin.hideShowQuitApp(appSigString, task);
    }

    function parabolicHeightForItemAt(thisItem)
    {
        var calculatedHeight = 0;

        if (thisItem.isPressed)
        {
            return thisItem.height;
        }

        if (currentX <= 0)
        {
            return itemWidth;
        }

        /* -----------------------------------------------------------------------------------------------
        //
        // parabolic y=ax^2
        //
        //      see: http://www.mathsisfun.com/geometry/parabola.html
        //      and see: http://www.mathsteacher.com.au/year9/ch10_quadratic/04_graphs/parabolic.htm
        //
        //  currentX is the vertex (focal point) which will move with the mouse horizontally
        //
        //----------------------------------------------------------------------------------------------- */

        var x = Math.abs(thisItem.originalX + itemWidth/2 - currentX)/itemWidth;

        calculatedHeight = itemWidth*globalItemScale - itemWidth * curve * Math.pow(x,2);

        return Math.max(itemWidth,calculatedHeight);
    }


    function calculateTotalWidthNeeded()
    {

//        console.log("calculateTotalWidthNeeded->entered");

        totalWidthCalc = 0;

        if (magnificationEnabled) {
            for (var i=0; i<(appsModel.count*itemWidth); i+=itemWidth)
            {
    //            var nextAmount = itemWidth*globalItemScale - itemWidth * curve * Math.pow(i/itemWidth,2);
                var nextAmount = itemWidth*maxGlobalItemScale - itemWidth * curve * Math.pow(i/itemWidth,2);
    //            //console.log("i = " + i + ": itemWidth = " + itemWidth + "nextAmount = " + nextAmount.toFixed(2));
                if (nextAmount > itemWidth)
                {
                    totalWidthCalc += (nextAmount-itemWidth);
                }
                else
                {
                    break;
                }
            }
            // now substract from the total, the amount from "panning" the currently hovered item
            totalWidthCalc -= (itemWidth*maxGlobalItemScale - itemWidth)/2;
        }

//        console.log("totalWidthCalc = " + totalWidthCalc.toFixed(2));

        fullAppWindow.width = totalWidthCalc*2 + itemWidth*appsModel.count + sidePadding*2 + contextMenu.sideMargin*6;

//        console.log("setting fullAppWindow.width to " + fullAppWindow.width);

        if (isDockOnSide())
        {
//            console.log("dock on side calling mainWin.notifyHeightChanged: fullAppWindow.width" + fullAppWindow.width);

            mainWin.notifyHeightChanged(fullAppWindow.width);
        }
        else {
            mainWin.notifyWidthChanged(fullAppWindow.width);
        }
    }

    function indexForAnchoredItemAtX(xPos)
    {
        return (Math.floor(xPos/itemWidth));
    }


    function isItemLessThanCurrentHovered(thisItem)
    {
        return (currentX > (thisItem.originalX + itemWidth)) ? yes : no;
    }


    function isItemCurrentHovered(thisItem)
    {
       return ((currentX >= thisItem.originalX) && (currentX <= thisItem.originalX + itemWidth)) ? yes : no;
    }


    function leftMarginForItem(thisItem)
    {
        if (isItemCurrentHovered(thisItem))
        {
            var x = 0 - (thisItem.width - itemWidth) * (currentX - thisItem.originalX)/itemWidth;
            return x;
        }
        else if (isMouseInsideDock && (thisItem.width == itemWidth))
        {
            return totalWidthCalc;
        }
        else if  ((thisItem.index > 0) && (thisItem.index < appsModel.count))
        {
            if (thisItem.LayoutMirroring.enabled == false)
            {
                var prevItem = repeaterContainer.itemAt(thisItem.index - 1);
                return prevItem.width - itemWidth + prevItem.anchors.leftMargin;
            }
            else
            {
                var nextItem = repeaterContainer.itemAt(thisItem.index + 1);

                //(thisItem.index == currentHoveredIndex - 1)
                if (((currentX - itemWidth) >= thisItem.originalX) && ((currentX - itemWidth) <= (thisItem.originalX+itemWidth)))
                {
                    return 0 - nextItem.anchors.leftMargin;
                }
                else
                {
                    return nextItem.width - itemWidth + nextItem.anchors.leftMargin;
                }
            }
        }
        else if (thisItem.index == 0)
        {
            var nextItem = repeaterContainer.itemAt(thisItem.index + 1);

            // (currentHoveredIndex == 1)
            if ((currentX >= itemWidth) && (currentX <= itemWidth*2))
            {
                return 0-nextItem.anchors.leftMargin;
            }
            else if (currentX > 0) //(currentHoveredIndex > 0)
            {
                return nextItem.width - itemWidth + nextItem.anchors.leftMargin;
            }
        }
        return 0;
    }


    function onEnteredDockIcons()
    {
//        console.log("onEnteredDockIcons-->");
        if (autoHideEnabled && !contextMenu.visible && !rowContainer.showHide.running && !isChangingIcon)
        {
            rowContainer.newBottomMargin = rowContainer.showingMargin;
            //console.log("onEnteredDockIcons autoHideEnabled, newBottomMargin: " + rowContainer.newBottomMargin);
            rowContainer.showHide.start();
        }
        else
        {
//            console.log("onEnteredDockIcons - skipping un-hide animation");
        }

        rowContainer.height = itemWidth * maxGlobalItemScale;

        var newHeight = dockMouseField.height + ((isDockOnSide()) ? (contextMenu.height+bounceHeight) :  toolTip.height) + toolTipBottomMargin;

        if (isDockOnSide())
        {
            mainWin.notifyWidthChanged(newHeight);
        }
        else  {
            mainWin.notifyHeightChanged(newHeight);
        }

        mainWin.notifyInsideDock(true);
    }

    function onExitedDockIcons()
    {
//        console.log("onExitedDockIcons-->");

        if (autoHideEnabled && !contextMenu.visible && !rowContainer.showHide.running && !isChangingIcon)
        {
            rowContainer.newBottomMargin = rowContainer.hiddenMargin;
//            console.log("onExitedDockIcons autoHideEnabled, newBottomMargin: " + rowContainer.newBottomMargin);
            rowContainer.showHide.start();
        }
        else
        {
//            console.log("onExitedDockIcons - skipping hide animation");
        }

        rowContainer.height = itemWidth;
        exitedAnimation.start();
    }

    function loadMasterAppsListToModel()
    {
        for (var i=0; i<masterAppsModel.length; i++)
        {
            var jsonObj = JSON.parse (masterAppsModel[i]);
//            //console.log("jsonObj[appStringKey] = " + jsonObj[appStringKey] + "; jsonObj[iconImageKey] = " + jsonObj[iconImageKey] + "; jsonObj[toolTipKey] = " + jsonObj[toolTipKey]);
            appsModel.append(jsonObj);
        }

        // Check for already-running apps on startup
        for (var i=0; i<appsModel.count; i++)
        {
            var appSigString = appsModel.get(i)[appStringKey];

            // new API
            var isRunning = mainWin.isAppRunning(appSigString);
//            //console.log(appSigString + " in QML isRunning = " + isRunning);


            //isRunningApp signals the indicator to be visible
            repeaterContainer.itemAt(i).isRunningApp = isRunning;
        }
    }

//    onContextMenuWasShownChanged: {
//        //console.log("onContextMenuWasShown changed = " + onContextMenuWasShown);
//    }

    ListModel  {
        id: appsModel;
    }

    focus: true;
    Keys.onPressed: {

        if (event.key == Qt.Key_Escape) {
            if (contextMenu.visible) {
                contextMenu.fadeOutAnimation.start();
            }
            else {
                mainWin.notifyDockHidden(no); //"no" means not showing :)
            }
        }
    }

//    states: State {
//        name: "reanchored"
//
//        AnchorChanges {
//            target: innerMainRotationContainerRect
//            anchors.bottom: (isDockOnSide()) ? parent.top : parent.bottom;
//            anchors.horizontalCenter: (isDockOnSide()) ? undefined : parent.horizontalCenter;
//        }
//    }

    Rectangle {

        id: innerMainRotationContainerRect //to allow rotation without screwing up main window layout logic I hope :)

        anchors.bottom: (isDockOnSide()) ? parent.top : parent.bottom;
        anchors.horizontalCenter: (isDockOnSide()) ? undefined : parent.horizontalCenter;

        anchors.left: {
          switch (currentDockScreenPosition) {
                case screenPosition.left:
                    return parent.left;
                    break;
                case screenPosition.right:
                    return parent.right;
                    break;
                default:
                    return undefined;
                    break;
            }
        }

        height: (isDockOnSide()) ? parent.width  : parent.height;
        width:  (isDockOnSide()) ? parent.height : parent.width;

        color: (debugEnabled) ? "blue" : "transparent"

        rotation: {
            if (isDockOnSide()) {
                return 90;
            }
            else if (currentDockScreenPosition==screenPosition.top) {
                return 180;
            }
            else {
                return 0;
            }
        }

        transformOrigin: (currentDockScreenPosition==screenPosition.top) ? Item.Center : Item.BottomLeft

        transform : Rotation {
            origin.x : (currentDockScreenPosition==screenPosition.top) ? width/2 : 0;
            origin.y : 0
//            origin.y : (currentDockScreenPosition==screenPosition.top) ? width/2: 0;
            axis    {
                x: 0;
//                y: (currentDockScreenPosition==screenPosition.right) ? 1 : 0;
                y: ((currentDockScreenPosition==screenPosition.right) || (currentDockScreenPosition==screenPosition.top)) ? 1 : 0;
                z: 0
            }
//            angle :  (currentDockScreenPosition==screenPosition.right) ? 180 : 0;
            angle :  ((currentDockScreenPosition==screenPosition.right) || (currentDockScreenPosition==screenPosition.top)) ? 180 : 0;

//            angle : {
//              switch (currentDockScreenPosition) {
//                case screenPosition.top:
//                    return 180; //-180;
//                    break;
//                case screenPosition.right:
//                    return 180;
//                    break;
//                default:
//                    return 0;
//                    break;
//                }
//            }
        }



        MouseArea //windowMouseField
        {
            id: windowMouseField;

            hoverEnabled: (!isChangingIcon); //true;
            enabled: (!isChangingIcon);
            anchors.fill: parent;

            onEntered: {//console.log("windowMouseField-->onEntered: isMouseInsideDock = " + isMouseInsideDock);
    //            mainWin.notifyInsideDock(false);
            }

            onExited: {
                //console.log("windowMouseField-->onExited: " + mouseX + "," + mouseY + ": dock area = " + rowContainer.x + "," + rowContainer.y + "," + rowContainer.width + "," + rowContainer.height);

                //First check that the mouse isn't going away from the dock icons, e.g. perhaps it's leaving the window altogether.
                // but ... dockMouseField.containsMouse doesn't work so have to do it the hard way :(
                if (mouseX < rowContainer.x - 10) {return;}
                if (mouseX > rowContainer.x + rowContainer.width + 10) {return;}
    //            if (mouseY < rowContainer.y - 10) {return;}
    //            if (mouseY > rowContainer.y + rowContainer.height + 10) {return;}
                if (mouseY < rowContainer.y - 10 - iconOnShelfPadding) {return;}
                if (mouseY > rowContainer.y + rowContainer.height + 10 + iconOnShelfPadding*2) {return;}

                if (rightPressOnCell) {return;}

                //console.log("windowMouseField-->onExited: calling onEnteredDockIcons");
                onEnteredDockIcons();
                enteredAnimation.start();
                toolTipeFadeInAnimation.start();
            }
            onClicked: {
                //console.log("windowMouseField clicked");
                isMouseInsideDock = no;
                contextMenu.fadeOutAnimation.start();
            }
        }

        Rectangle //rowContainer
        {
            id: rowContainer;

    //        property bool showingState: yes;

    //        property double newBottomMagin: 0;

            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.bottom: parent.bottom;

            anchors.bottomMargin: 0;

            width: appsModel.count * itemWidth;
            height: itemWidth;
            color: (debugEnabled) ? "yellow" : "transparent";
            border.color: (debugEnabled) ?  "black" : "transparent";

            property double hiddenMargin:    (0 - (itemWidth+iconOnShelfPadding-1));
            property double showingMargin:   0;
            property double newBottomMargin: (0 - (itemWidth+iconOnShelfPadding-1));

            property PropertyAnimation showHide: showHideAnimation_;

            PropertyAnimation on anchors.bottomMargin
    //        PropertyAnimation on newBottomMagin
            {
                id: showHideAnimation_;
                running: false; //autoHideEnabled; //true;//false;
    //            enabled: false;
    //            from: anchors.bottomMargin;
    //            to: (rowContainer.showingState) ? -(itemWidth+iconOnShelfPadding-1) : 0;
    //            to: (anchors.bottomMargin == 0) ? -(itemWidth+iconOnShelfPadding-1) : 0;
    //            to: (newBottomMagin == 0) ? -(itemWidth+iconOnShelfPadding-1) : 0;
                to: rowContainer.newBottomMargin;

                duration: 300;

                onRunningChanged: {
                    if (!running)
                    {
                        //console.log("finished hide/un-hide from newBottomMargin =" + rowContainer.newBottomMargin);

    //                    //console.log("finished hide/un-hide was:" + rowContainer.showingState + " current margin = " + rowContainer.anchors.bottomMargin);
    //
    //                    rowContainer.showingState = !rowContainer.showingState;
    //                    mainWin.notifyDockHidden(rowContainer.showingState);
                        mainWin.notifyDockHidden((rowContainer.newBottomMargin == rowContainer.showingMargin));
                    }
                }
            }

            Shelf
            {
                id: backgroundShelf

                anchors.leftMargin:  (newYosemiteBottomStyle || (currentDockScreenPosition!=screenPosition.bottom)) ? -itemWidth/4 : -itemWidth/2;
                anchors.rightMargin: (newYosemiteBottomStyle || (currentDockScreenPosition!=screenPosition.bottom)) ? -itemWidth/4 : -itemWidth/2;
            }

            MouseArea //dockMouseField
            {
                id: dockMouseField;
                x: 0
                y: -iconOnShelfPadding; //Expanded mouse area height and y negative offset
                width: parent.width;
                height: parent.height + iconOnShelfPadding*2;

                hoverEnabled: (!isChangingIcon);

                drag.filterChildren: true;
                enabled: (!rightPressOnCell && !isChangingIcon)

                PropertyAnimation { id: enteredAnimation;
                                    easing.type: Easing.OutQuad/*Easing.Linear*/;
                                    running: false; target: fullAppWindow; property: "globalItemScale";
                                        from: 1; to: maxGlobalItemScale; duration: mouseInOutAnimationDuration;
                    onRunningChanged: {
                        if (!running) {
                            isMouseInsideDock = yes;
                        }
                    }
                }

                PropertyAnimation { id: exitedAnimation;
                                    easing.type: Easing.OutQuad/*Easing.Linear*/;
                                    running: false; target: fullAppWindow; property: "globalItemScale";
                                        from: maxGlobalItemScale; to: 1; duration: mouseInOutAnimationDuration;
                    onRunningChanged: {
                        if (!running) {

                            isMouseInsideDock = no;
                            mainWin.notifyInsideDock(false);
                        }
                    }
                }

                onPositionChanged:
                {
                    currentX = mouseX;
                    contextMenuWasShown = no;
                }

                onEntered: {

                    if (!rightPressOnCell)
                    {
                        //console.log("dockMouseField-->onEntered: calling onEnteredDockIcons");
                        onEnteredDockIcons();
                        enteredAnimation.start();
                        toolTipeFadeInAnimation.start();
                    }
                }

                onExited: {
                    isMouseInsideDock = no;
                    onExitedDockIcons();
                    exitedAnimation.start();
                    toolTipeFadeAnimation.start();
                }

                onCanceled:
                {
                    //console.log("dockMouseField onCanceled");
                }
            }

            ContextMenu
            {
                id: contextMenu
                visible: rightPressOnCell;

                anchors {
                    bottom: (isDockOnSide()) ? rowContainer.top : repeaterContainer.top
//                    bottomMargin: toolTipBottomMargin/2 + ((isDockOnSide()) ? contextMenu.width/2 + 5 : 0);
                    bottomMargin: (isDockOnSide()) ? (toolTipBottomMargin/2 +contextMenu.width/2 + 5) : 0;//toolTipBottomMargin/2 + ((isDockOnSide()) ? contextMenu.width/2 + 5 : 0);
                }

                onTriggerOptionsDialog:
                {
                    //console.log("in Main Window got signal to open options dialog!");
                    mainWin.showPreferencesDialog();
                }
            }

            ToolTip
            {
                id: toolTip

                function getBouncingTopOffset ()
                {
                    var currentLauncherCell = (repeaterContainer.itemAt(indexForAnchoredItemAtX(currentX))) ?  repeaterContainer.itemAt(indexForAnchoredItemAtX(currentX)) : undefined;
                    if (currentLauncherCell != undefined)
                    {
                        return currentLauncherCell.currentLiftOffSet;
                    }
                    return 0;
                }
                anchors {
                    bottom: (repeaterContainer.itemAt(indexForAnchoredItemAtX(currentX))) ?  repeaterContainer.itemAt(indexForAnchoredItemAtX(currentX)).top : undefined; //rowContainer.top;
                    bottomMargin: getBouncingTopOffset() + ((isDockOnSide()) ? toolTip.width/2 : toolTipBottomMargin);
                    horizontalCenter: (repeaterContainer.itemAt(indexForAnchoredItemAtX(currentX))) ? repeaterContainer.itemAt(indexForAnchoredItemAtX(currentX)).horizontalCenter : undefined;
    //                horizontalCenterOffset: 100;
                }

                tipString: {
                    var cellData = appsModel.get(indexForAnchoredItemAtX(currentX));

                    if (cellData == undefined)
                    {
                        return "";
                    }
                    return cellData[toolTipKey];
                }

    //            visible: dockMouseField.containsMouse && !rightPressOnCell && !contextMenuWasShown && !cellBeingDragged && (tipString.length > 0);
                visible: /*isMouseInsideDock &&*/ !rightPressOnCell && !contextMenuWasShown && !cellBeingDragged && (tipString.length > 0);

                onVisibleChanged: {
                    //console.log("toolTip visible change = " + visible);

                    if (visible) {
                        //opacity = 1;
    //                    toolTipeFadeInAnimation.start();
                    }
                }
                PropertyAnimation { id: toolTipeFadeInAnimation; target: toolTip; property: "opacity"; from:0; to: 1; duration: toolTipFadeDuration/*mouseInOutAnimationDuration*0.75*/;
                    onRunningChanged: {
                        if (!running) {
                            //console.log("finished toolTipeFadeInAnimation!");
    //                        toolTip.visible = no;
    //                        toolTip.opacity = 1;
    //                        toolTip.opacity = (toolTip.visible) ? 1 : 0;
                        }
                    }
                }
                PropertyAnimation { id: toolTipeFadeAnimation; target: toolTip; property: "opacity"; from:1; to: 0; duration: toolTipFadeDuration /*mouseInOutAnimationDuration*0.75*/;
                    onRunningChanged: {
                        if (!running) {
                            //console.log("finished toolTipeFadeAnimation!");
    //                        toolTip.visible = no;
    //                        toolTip.opacity = 1;
    //                        toolTip.opacity = (toolTip.visible) ? 1 : 0;
                        }
                    }

                }
            }

            Repeater //anchorDebugLinesRepeater
            {

                //@TODO: loader: only load this if debugEnabled

                id: anchorDebugLinesRepeater;
                model: appsModel

                Rectangle {
                    color: (debugEnabled) ? "red" : "transparent";
                    opacity: 0.3;
                    border.color: (model.index % 2) ? "black" : "blue"
                    border.width: (debugEnabled) ? 1 : 0;
                    width: itemWidth;
                    x: model.index * itemWidth;
                    height: itemWidth*globalItemScale;
                    anchors.bottom: parent.bottom;
                }
            }

            Repeater //repeaterContainer
            {
                id: repeaterContainer;
                model: appsModel;

                Component.onCompleted: {
//                    //console.log("currentMagnificationIndex = " + currentMagnificationIndex);
//                    var newMagnificationIndex = currentMagnificationIndex;
//                    //console.log("availableMagnifications[newMagnificationIndex].scale = " + availableMagnifications[newMagnificationIndex].scale);
//                    //console.log("availableMagnifications[newMagnificationIndex].curve = " + availableMagnifications[newMagnificationIndex].curve);
//                    selectedItemScale = availableMagnifications[newMagnificationIndex].scale;
//                    selectedCurve     = availableMagnifications[newMagnificationIndex].curve;
                    //console.log("repeaterContainer loaded --> masterAppsModel.length = " + masterAppsModel.length);
                    loadMasterAppsListToModel();
                    calculateTotalWidthNeeded();

                    if (isDockOnSide()) {
                        mainWin.notifyWidthChanged(dockMouseField.height);
                    }
                    else  {
                        mainWin.notifyHeightChanged(dockMouseField.height);
                    }
                    cellsLoaded = true;
                    origGlobalItemScale = globalItemScale;

                    backgroundShelf.anchors.left = repeaterContainer.itemAt(0).left;
//                    backgroundShelf.anchors.leftMargin = -(backgroundShelf.height-iconOnShelfPadding);
                    backgroundShelf.anchors.right = repeaterContainer.itemAt(appsModel.count-1).right;
//                    backgroundShelf.anchors.rightMargin = -(backgroundShelf.height-iconOnShelfPadding);
                    backgroundShelf.anchors.bottom = parent.bottom;
                }

                delegate: launcherCell
            }

            LauncherCellComponent
            {
                 id: launcherCell
            }
        }
    }
}
