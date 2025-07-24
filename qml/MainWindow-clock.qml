/****************************************************************************
**
** Code based on: http://code.google.com/p/nokia-screensaver/source/browse/branches/minimal/qtscreensaver/qml/qtscreensaver/main.qml?r=28
** License: Apache License 2.0: http://www.apache.org/licenses/LICENSE-2.0
** Modified by me for use on Haiku: hey68you@gmail.com (January 2013).
**
****************************************************************************/

import QtQuick 2.5
import QtQuick.Window

Rectangle {

    id: fullAppWindow

    // width: 600
    // height: 480
    visible: true
    // title: qsTr("DigiClock")
    ////////////////////////////////////////////////
    // Edit settings
    //  1. Colors
    //  2. Show Seconds
    //  3. 12 or 24 hours
    ////////////////////////////////////////////////
    property bool   showSeconds: true //false
    property bool	twelveHours: true
    // property string foregroundTextColor: "#373634" //"#80C1FF" //"#00FF00"
    // property string gradientStartColor:  "#99B0A0" //"#424242"
    // property string gradientEndColor:    "#737F78" //"black"


    property string foregroundTextColor: "#FA0901"
    // property string gradientStartColor:  "#211E27"
    property string gradientStartColor:  "#ffffff"

    // property string gradientEndColor:    "#211E27"
    property string gradientEndColor:    "#ffffff"


    ////////////////////////////////////////////////
    ////////////////////////////////////////////////


    ////////////////////////////////////////////////
    // I don't think you should need to change
    //  these values...
    ////////////////////////////////////////////////
    property int    winWidth:  (showSeconds) ? 500 : 180
    property int    winHeight: (showSeconds) ? 130 : 75

    property int    upperMargin: 10
    property int    sideMargin:  15

    property real   fontProportion: (showSeconds) ? 0.27 : 0.40
    ////////////////////////////////////////////////


    width:   winWidth
    height:  winHeight

    Rectangle {
        id: screen


        anchors.fill: parent

        FontLoader {
            //id: fixedFont; name: "Digi7"; source: "digital_7_mono.ttf"
            id: fixedFont; source: "digital_7_mono.ttf"
        }

        Rectangle {
            id: backgroundGradient
            anchors.fill: parent
            smooth: true
            gradient: Gradient {
                GradientStop { position: 0.0; color: gradientStartColor }
                GradientStop { position: 1.0; color: gradientEndColor   }
            }
            opacity: 1.0
        }

        Text {
            id: timeTextBackground
            text: (showSeconds) ? "88:88:88" : "88:88"
            anchors.fill: parent
            anchors.topMargin: upperMargin
            anchors.leftMargin: sideMargin
            // anchors.verticalCenter: parent.verticalCenter
            color: foregroundTextColor
            opacity: 0.15
            font.family: fixedFont.name
            font.pointSize: 62
            //font.bold: true
        }

        Text {
            id: timeText
            text: "88:88:88"
            anchors.fill: parent
            anchors.topMargin: upperMargin
            anchors.leftMargin: sideMargin
            anchors.verticalCenter: parent.verticalCenter
            color: foregroundTextColor
            opacity: 0.85
            font.family: fixedFont.name
            font.pointSize: 62
            // font.bold: true

            function updateFontSize() {
                font.pointSize = width * fontProportion;
                timeTextBackground.font.pointSize = width * fontProportion;
                anchors.topMargin = upperMargin * fontProportion;
                anchors.leftMargin = sideMargin * fontProportion;
                timeTextBackground.anchors.topMargin = upperMargin * fontProportion;
                timeTextBackground.anchors.leftMargin = sideMargin * fontProportion;
            }

            onWidthChanged: updateFontSize()
        }

        Timer {
            id:clocktimer
            triggeredOnStart: true
            running: true
            repeat: true
            onTriggered: {
                //console.log(runtime.isActiveWindow);
                var date = new Date();

                var th = date.getHours();
                var tm = date.getMinutes();
                var ts = date.getSeconds();

                function formatHours(hrs) {
                    if ((twelveHours) && (hrs !== 12)) {
                        return hrs % 12;
                    }
                    return hrs;
                }

                function format(x) {
                    if (x < 10){
                        return '0' + x;
                    }
                    return x;
                }

                var secondsString = (showSeconds) ? ':' + format(ts) : "";
                timeText.text = format(formatHours(th)) + ':' + format(tm) + secondsString;

                /* To show a date string ...
            var day = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'][date.getDay()];
            var td = format(date.getDate());

            var tM = format(date.getMonth() + 1);
            var ty = format(date.getFullYear());
            */

                clocktimer.interval = 1000;
            }
        }
    }
}
