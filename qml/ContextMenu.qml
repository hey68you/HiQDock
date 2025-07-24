import QtQuick 2.5

Rectangle
{
    /*MenuBackground*//*Rectangle*/ //contextMenu

    id: contextMenuContainer

    signal   triggerOptionsDialog();

    property int sideMargin: 24//20;
    property int topMargin:  15;
//    property int internalSideMargin: globalBorderWidth+4;
    property int globalBorderWidth:  2;
    property int internalSideMargin: globalBorderWidth+8;

    property NumberAnimation fadeOutAnimation: fadeOutAnimation_;

    property string strRemoveFromDock:    "Remove from Dock";
    property string strMoreOptions:       "Dock Options...";
    property string strLaunchNewInstance: "Launch New Instance";
    property string strQuit:              "Close All (Quit)";
    property string strShowAll:           "Show All";
    property string strHideAll:           "Hide All";
    property string strShowInTracker:     "Show in Tracker";

    property int calculatedHeight:        Math.ceil((menuColumn.height + topMargin + menuColumn.spacing*3 + ((isDockOnSide()) ? 5 : 35) ));
    property int calculatedWidth:         Math.ceil((itemWidth * globalItemScale));
//    property int calculatedWidth:         Math.ceil((itemWidth * maxGlobalItemScale));

    anchors.left: (repeaterContainer.itemAt(indexForAnchoredItemAtX(currentX))) ? repeaterContainer.itemAt(indexForAnchoredItemAtX(currentX)).left : undefined;
    anchors.leftMargin: Math.ceil((itemWidth*globalItemScale)/2 - 60/2); //30;// - 28/2;

    color:  (isDockOnSide()) ? Qt.rgba(0,0,0,0.75) : "transparent" //"green";
    radius: (isDockOnSide()) ? 12 : 0;
//    color:  Qt.rgba(0,0,0,0.75)
//    radius: 12

    height: calculatedHeight
    width:  calculatedWidth

//    smooth: true;

    rotation: (isDockOnSide()) ? -90 : 0;
    transformOrigin: Item.Bottom

    transform : Rotation {
        origin.x : 0
        origin.y : height /*width/2*/
        axis { x: 1; y: 0; z: 0 }
        angle :  (currentDockScreenPosition==screenPosition.right) ? 180 : 0;
    }


    NumberAnimation on opacity {
        id: fadeOutAnimation_;
        from: 1;
        to: 0;
        duration: 300;
        running: false;

        onRunningChanged: {
            if (!running)
            {
                //console.log("context menu fadeout finished, isMouseInsideDock = " + isMouseInsideDock);
                rightPressOnCell = false;
                onExitedDockIcons();
            }
        }
    }

    NumberAnimation on opacity {
        id: fadeInAnimation
        from: 0;
        to: 1;
        duration: 200;
        running: false;
    }

    onVisibleChanged: {
        //console.log ("visible changed = " + visible);
        if (visible)
        {
            var launcherCellItem = repeaterContainer.itemAt(indexForAnchoredItemAtX(currentX));

            if (launcherCellItem.isRunningApp)
            {
                var appSigString = appsModel.get(indexForAnchoredItemAtX(currentX))[appStringKey];
                var canBeMultiLaunched = mainWin.isMultiLaunch(appSigString);
                //console.log("appSigString = " + appSigString + "; canBeMultiLaunched = " + canBeMultiLaunched);
                if (canBeMultiLaunched)
                {
                    //menuItems.append({ "menuTextString" : "--" });
                    menuItems.append({ "menuTextString" : strLaunchNewInstance });
                }

                if (menuItems.count > 0) {
                    menuItems.append({ "menuTextString" : "--" });
                }
            }

//            menuItems.append({ "menuTextString" : "More options ▷" });
            menuItems.append({ "menuTextString" : strMoreOptions });
//            menuItems.setProperty(menuItems.count()-1,"menuTextString", strMoreOptions);
            menuItems.append({ "menuTextString" : "Change Icon Image" });

            if ((indexForAnchoredItemAtX(currentX) > 0) && indexForAnchoredItemAtX(currentX) < (appsModel.count - 1))
            {
                menuItems.append({ "menuTextString" : strShowInTracker});
                menuItems.append({ "menuTextString" : "--" });
                menuItems.append({ "menuTextString" : "Add new Launcher here" });
                menuItems.append({ "menuTextString" : strRemoveFromDock });
            }

            if (launcherCellItem.isRunningApp)
            {
                menuItems.append({ "menuTextString" : "--" });
                menuItems.append({ "menuTextString" : strShowAll });
                menuItems.append({ "menuTextString" : strHideAll });
                menuItems.append({ "menuTextString" : strQuit });
            }
            fadeInAnimation.start();
        }
        else
        {
            menuItems.clear();
        }
    }

    Component {
        id: menuBackgroundComponent
        MenuBackground {
            showBorder: (newYosemiteBottomStyle || currentDockScreenPosition==screenPosition.top) ? false : true;
        }

//        BorderImage {
//            id: myBorderImageTest
//            smooth: true
//            source: "myCallOut.svg"
//            border.left: 75; border.top: 75
//            border.right: 75; border.bottom: 75
//        }
    }

    Loader {

        id: backgroundViewLoader //Don't load for vertical dock
        sourceComponent: (isDockOnSide()) ? undefined : menuBackgroundComponent
//        width:  (isDockOnSide()) ? parent.height : parent.width;
//        height: (isDockOnSide()) ? parent.width :parent.height;
        anchors.fill: parent
        anchors.bottomMargin: (isDockOnSide()) ? -30 : 0;
        rotation: (isDockOnSide()) ? 90 : 0;
        transformOrigin: Item.BottomLeft
    }

    ListModel {
        //Menu Items are added dynamically when menu becomes visible;

        id: menuItems
    }

    Column {

        id: menuColumn

        spacing: 5

        anchors.top: (currentDockScreenPosition==screenPosition.top) ? parent.bottom : parent.top;
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.margins: 10;
        anchors.leftMargin: 24; //enough room for an icon to left of text
        anchors.topMargin:  14;

        transform: Rotation {

            origin.x: 0;

            //START HERE FIGURE OUT THIS -32 EYEBALL FACTOR!!!!
            origin.y: -32;
            axis     {
                        x: (currentDockScreenPosition==screenPosition.top) ? 1 : 0;
                        y: 0;
                        z: 0;
            }
            angle:   (currentDockScreenPosition==screenPosition.top) ? 180 : 0;
        }

        clip: false;

        Repeater {
            model: menuItems

            Text {

                id: menuTextItem

                property string thisItemMenuTextString: (menuItems.get(model.index) != undefined) ? menuItems.get(model.index).menuTextString : "";
//                property bool   isSeparator:   (menuItems.get(model.index).menuTextString == "--");
//                property string stringForItem:  menuItems.get(model.index).menuTextString;
                property bool   isSeparator:   (thisItemMenuTextString == "--");
                property string stringForItem: thisItemMenuTextString;

                text: (isSeparator) ? "" : stringForItem; //menuItems.get(model.index).menuTextString; //"I'm item " + index;
                font.pixelSize: 16
//                font.family: "Humnst777 BT"//"Century Gothic"
                font.family: "Noto Sans"

//                style: Text.Raised;
//                styleColor: "black";
                color: "white ";
                height: (isSeparator) ? 4 : Math.ceil(implicitHeight);
//                smooth: true;

                width: Math.ceil(menuColumn.width);

                Component.onCompleted: {

                    if ((implicitWidth + sideMargin*2) > contextMenuContainer.width)
                    {
                        contextMenuContainer.width = Math.ceil(implicitWidth + sideMargin*2);
                    }
                }

                MouseArea
                {
                    id: contextMenuMouseArea

                    anchors.fill: parent;
                    hoverEnabled: yes;

                    enabled: !isSeparator;

                    onClicked:
                    {
                        //console.log("context menu click = " + menuTextItem.text);
//                        fadeOutAnimation_.start();

                        if (menuTextItem.text == "Remove from Dock")
                        {
                            var indexOfItemToRemove = indexForAnchoredItemAtX(currentX);

                           // console.log("call remove from dock here for index = " + indexOfItemToRemove);

                            var itemToFade = repeaterContainer.itemAt(indexForAnchoredItemAtX(currentX));
                           // console.log("itemToFade = " + itemToFade);

                            // at the end of this fade animation, remove is triggered (see LauncherCellComponent)
                            itemToFade.fadeAndRemoveAnimation.start();
                        }

                        if (menuTextItem.text == "Add new Launcher here")
                        {
                            var indexOfItemToAdd = indexForAnchoredItemAtX(currentX);

                            //console.log("call add new to dock here for index = " + indexOfItemToAdd);

                            mainWin.addNewItemAt(indexOfItemToAdd);
                        }

                        if (menuTextItem.text == "Change Icon Image")
                        {
                            var indexOfItem = indexForAnchoredItemAtX(currentX);

                            var itemToHighlight = repeaterContainer.itemAt(indexOfItem);
                            itemToHighlight.setChangingIcon(yes);

                            //console.log("call change icon here for index = " + indexOfItem);

                            mainWin.setIconImageForItemAt(indexOfItem);

//                            var itemToHighlight = repeaterContainer.itemAt(indexForAnchoredItemAtX(currentX));
//                            itemToHighlight.setChangingIcon(yes);
                        }
                        if (menuTextItem.text == strShowInTracker)
                        {
                            var indexOfItem = indexForAnchoredItemAtX(currentX);
                            var appSigString = appsModel.get(indexOfItem)[appStringKey];
                           // console.log("call openParentFolder for app: " + appSigString);
                            mainWin.openParentFolder(appSigString);
                        }

                        if (menuTextItem.text == strHideAll)
                        {
                            doShowHideCloseForTeam(hideAll);
                        }
                        if (menuTextItem.text == strShowAll)
                        {
                            doShowHideCloseForTeam(showAll);
                        }
                        if (menuTextItem.text == strQuit)
                        {
                            doShowHideCloseForTeam(closeAll);
                        }
                        if (menuTextItem.text == strLaunchNewInstance)
                        {
                            var itemToMultiLaunch = repeaterContainer.itemAt(indexForAnchoredItemAtX(currentX));
                            itemToMultiLaunch.triggerLaunchApp();
                        }
                        if (menuTextItem.text == strMoreOptions)
                        {
                            /*contextMenuContainer.*/triggerOptionsDialog();
                        }

                        isMouseInsideDock = no;
                        fadeOutAnimation_.start();
                    }
                }

                Rectangle {
                    id: separatorLine

                    anchors {
                        left: parent.left;
                        leftMargin:  Math.ceil(-menuColumn.anchors.leftMargin + globalBorderWidth + 2);
                        right: parent.right;
                        rightMargin: Math.ceil(-(globalBorderWidth*2) + 1);
                        verticalCenter: parent.verticalCenter;
                    }

                    height: 1
                    color: "gray"
                    opacity: 0.65;
                    visible: isSeparator;
                }

                Rectangle {
                    id: innerMenuRect
//                    z: -1;
                    z: parent.z - 1;

                    height: Math.ceil(menuTextItem.height) + 4;

                    anchors {
                        left: parent.left;
                        leftMargin:  Math.ceil(-menuColumn.anchors.leftMargin + globalBorderWidth + 2);
                        right: parent.right;
                        rightMargin: Math.ceil(-(globalBorderWidth*2) + 1);
                        verticalCenter: parent.verticalCenter;
                    }

                    gradient: Gradient {

                        GradientStop {
                            position: 0.00;
                            color: "#cbe8ec";
                        }
                        GradientStop {
                            position: 1.00;
                            color: "#1333d1";
                        }
                    }

                    visible: contextMenuMouseArea.containsMouse;
                }
            }
        }
    }
}



