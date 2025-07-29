/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.5
import Qt.labs.folderlistmodel

Rectangle {

    id: iconPickerTopLevelView
    width: 1200; height: 800
    color: "#808088"

    property int    gridItemSize: 128;
    property double iconItemSize: gridItemSize*0.75;

    property string launcherName: "StyledEdit"
    property string gradientStartColor: "#D0D0D0"
    property string gradientEndColor:   "#908F90"

    signal iconSelected (string filePathAndName);

    focus: true;
    Keys.onPressed: {
        if (event.key === Qt.Key_Escape) {
            iconSelected("");
        }
    }

    //http://stackoverflow.com/questions/11359854/update-listview-showin-in-tab-bar-layout-qml
    property variant folderModel
    function updateModel() {
        var currentFolder = ""
        if (folderModel) {
            currentFolder = folderModel.folder
            folderModel.destroy();
        }
        folderModel = modelComponent.createObject(iconPickerTopLevelView, {"folder": ((currentFolder == "") || (currentFolder == undefined)) ? "file://" + iconPickerInitialFolder : currentFolder})
    }

    Component {
        id: modelComponent

        FolderListModel {
            id: origFolderModel

            folder: iconPickerInitialFolder;

            nameFilters: ["*.svg" , "*.png", "*.jpg", "*.bmp"];

            showDirs: true;

            showDotAndDotDot: false;

            onFolderChanged: {
//                console.log("on folder change signal-handler in QML! new folder = " + folderModel.folder);
//                console.log("on folder change signal-handler in QML! starting = " + iconPickerInitialFolder);
//                showDotAndDotDot =  (folderModel.folder == ("file://" + iconPickerInitialFolder)) ? false : true;
                showDotAndDotDot = ((folderModel === undefined) || (folderModel.folder === undefined) || (folderModel.folder === ("file://" + iconPickerInitialFolder))) ? false : true;
            }
        }
    }

    Component {
        id: appDelegate

        Rectangle {

            id: itemContainer;

            radius: 5
            border.width: 2
            border.color: (mouseArea.containsMouse) ? "white" : "transparent";

            color: (mouseArea.containsMouse) ? "#1B68A9" : "transparent";

            width: gridItemSize; height: gridItemSize

            Image {
                id: myIcon
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: iconItemSize
                height: iconItemSize
                sourceSize.width: iconItemSize;
                sourceSize.height: iconItemSize;
                smooth: true;
                fillMode: Image.PreserveAspectFit

//                source: (folderModel.isFolder(model.index)) ? "" : filePath;
                source: (folderModel.isFolder(model.index)) ? "" : (filePath != undefined) ? filePath : "";
                
            }

            Text {
                anchors {
                    top: (folderModel.isFolder(model.index)) ? dirIndicator.bottom : myIcon.bottom;
                    horizontalCenter: parent.horizontalCenter
                }

                text: (folderModel.isFolder(model.index)) ? "/"+fileName : fileName;
                visible: (folderModel.isFolder(model.index)) ? true : (mouseArea.containsMouse);
//                smooth: true;
                font.bold: true;
                font.pointSize: (folderModel.isFolder(model.index)) ? 12 : 8;
                style: Text.Raised;
                styleColor: "black"
                color: "white"
                clip: true;
            }
            Text
            {
                id: dirIndicator
                text: "Folder"
                visible: folderModel.isFolder(model.index);
                font.bold: true;
                font.pointSize: 14;
                style: Text.Sunken;
                styleColor: "black"
                color: "lightsteelblue"
                anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
            }

            MouseArea
            {
                id: mouseArea
                anchors.fill: parent;
                hoverEnabled: true;

                onClicked: {
//                    console.log("clicked = " + filePath /*folderModel.folder + fileName*/);
                    if (false == folderModel.isFolder(model.index))
                    {
//                        console.log("clicked-> filePath = " + filePath /*folderModel.folder + fileName*/);
//                        console.log("clicked->folderModel.folder " + folderModel.folder);
//                        console.log("clicked->folderModel.parentFolder " + folderModel.parentFolder);
//                        console.log("clicked-> folderModel.folder.filePath = " + folderModel.folder.filePath /*folderModel.folder + fileName*/);
//                        console.log("clicked-> folderModel.folder.fileName = " + folderModel.folder.fileName /*folderModel.folder + fileName*/);


                        var fullPathURL = folderModel.folder + "/" + fileName;
                        var stringToRemoveFromURL = "file://" + iconPickerInitialFolder + "/";
//                        console.log("stringToRemoveFromURL = " + stringToRemoveFromURL);
                        var normalizedFilePath = fullPathURL.split(stringToRemoveFromURL).pop();

//                        console.log("normalizedFilePath = " + normalizedFilePath);
                        iconSelected(normalizedFilePath);

                    }
                    if (folderModel.isFolder(model.index))
                    {
                        folderModel.folder = filePath;
                    }
                }
            }
        }
    }

    Rectangle {

        id: topBar
        height: 40

        anchors {
            top:   parent.top
            topMargin: -1
            right: parent.right
            rightMargin: -1
            left:  parent.left
            leftMargin: -1
        }

        gradient: Gradient {
            GradientStop { position: 0.0; color: gradientStartColor }
            GradientStop { position: 1.0; color: gradientEndColor }
        }
        border.color: "black"
        border.width: 1

        Text
        {
            id: topBarText
            text: "Please select an icon for the launcher: "

            font.pointSize: 16;
            font.family: "Noto Sans";

            anchors {
                verticalCenter: parent.verticalCenter;
                left:       parent.left
                leftMargin: 5
            }
        }

        Text
        {
            id: topBarLauncherToolTipText
            text: launcherToolTip

            font.pointSize: 16;
            font.bold: true;

            anchors {
                verticalCenter: parent.verticalCenter;
                left:       topBarText.right
                leftMargin: 5
            }
        }

        Image {
            id: testIcon

            source: originalIconImageSource
            width:  32
            height: 32
            anchors {
                verticalCenter: parent.verticalCenter;
                left:           topBarLauncherToolTipText.right
                leftMargin:     5
            }
        }

        Rectangle
        {
            id: closeButton;

            color: "lightGray"

            width: closeButtonLabel.implicitWidth+12;

            border.width: 1; //2;
            border.color: "black";

            anchors {
                right:          parent.right;
                top:            parent.top
                bottom:         parent.bottom
                margins:        6
            }

            Text
            {
                id: closeButtonLabel
                text: "Cancel"
                font.bold: true;
                font.pointSize: 12;
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter

                anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
            }

            MouseArea
            {
                id: closeButtonMouseArea
                anchors.fill: parent;
                hoverEnabled: true;

                onClicked: {
                    //console.log("closeButtonMouseArea clicked");
                    //empty string will be a sign to close the window
                    iconSelected("");
                }
                onPressed:
                {
                    closeButton.color = "darkGray"
                    closeButtonLabel.color = "gray"
                }
                onReleased:
                {
                    closeButton.color = "lightGray"
                    closeButtonLabel.color = "black"
                }
            }
        }
        Rectangle
        {
            id: refreshButton
            color: "lightGray"

            border.width: 1;
            border.color: "black";

            width: closeButton.width
            height: closeButton.height

            anchors {
                right:          closeButton.left
                top:            parent.top
                bottom:         parent.bottom
                margins:        6
            }

            Text
            {
                id: refreshButtonLabel
                text: "Refresh"
                font.bold: true;
                font.pointSize: 12;
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter

                anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
            }

            MouseArea
            {
                id: refreshtButtonMouseArea
                anchors.fill: parent;
                hoverEnabled: true;

                onClicked: {
                    //console.log("refreshtButtonMouseArea clicked");
                    updateModel();
                }
                onPressed:
                {
                    refreshButton.color = "darkGray"
                    refreshButtonLabel.color = "gray"
                }
                onReleased:
                {
                    refreshButton.color = "lightGray"
                    refreshButtonLabel.color = "black"
                }
            }
        }
    }

    GridView {

        anchors {
            top:    topBar.bottom
            right:  parent.right
            left:   parent.left
            bottom: parent.bottom
        }

        anchors.margins: 10

        cellWidth: gridItemSize; cellHeight: gridItemSize
//        focus: true
//        model: folderModel
        model: iconPickerTopLevelView.folderModel

        clip: true;

        delegate: appDelegate

    }

    Component.onCompleted: {
        updateModel()
    }
}
