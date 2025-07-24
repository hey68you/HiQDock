/****************************************************************************
**
** Code based on: http://code.google.com/p/nokia-screensaver/source/browse/branches/minimal/qtscreensaver/qml/qtscreensaver/main.qml?r=28
** License: Apache License 2.0: http://www.apache.org/licenses/LICENSE-2.0
** Modified by me for use on Haiku: hey68you@gmail.com (January 2013).
**
****************************************************************************/

import QtQuick 2.5
//import QtQuick.Window

Rectangle {
    width: 600
    height: 480
    visible: true
    //title: qsTr("Hello World")
    Text {
        id: first
        text: qsTr("Hello World")
    }

    Component.onCompleted: {
        console.log("component on completed");
    }
}


