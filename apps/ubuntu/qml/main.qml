/*****************************************************************************
 * Copyright: 2011-2013 Michael Zanetti <michael_zanetti@gmx.net>            *
 *                                                                           *
 * This file is part of Xbmcremote                                           *
 *                                                                           *
 * Xbmcremote is free software: you can redistribute it and/or modify        *
 * it under the terms of the GNU General Public License as published by      *
 * the Free Software Foundation, either version 3 of the License, or         *
 * (at your option) any later version.                                       *
 *                                                                           *
 * Xbmcremote is distributed in the hope that it will be useful,             *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of            *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
 * GNU General Public License for more details.                              *
 *                                                                           *
 * You should have received a copy of the GNU General Public License         *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.     *
 *                                                                           *
 ****************************************************************************/

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

MainView {
    id: appWindow

    tools: mainLoader.item.tools

    property int pageMargins: units.gu(2)

    Rectangle {
        anchors.fill: parent
        color: "#ebebeb"
    }

    Loader {
        id: mainLoader
        anchors.fill: parent
        sourceComponent: xbmc.connected ? tabsComponent : noConnectionComponent
    }

    FocusScope {
        focus: true
        Keys.onVolumeUpPressed: xbmc.volume += 5
        Keys.onVolumeDownPressed: xbmc.volume -= 5
    }

    Component {
        id: noConnectionComponent

        Item {
            Label {
                id: connectionLabel
                anchors.centerIn: parent
                text: "Not connected"
            }
            Button {
                id: connectButton
                anchors.top: connectionLabel.bottom
                anchors.topMargin: units.gu(1)
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Connect"
                width: units.gu(15)
                onClicked: {
                    var sheet = Qt.createComponent("ConnectionSheet.qml");
                    var obj = PopupUtils.open(sheet, connectButton);
                    obj.hostSelected.connect(function connectToHost(index) {
                                                 xbmc.hostModel().connectToHost(index)
                                                 PopupUtils.close(sheet);
                                               })
                }
            }
        }
    }

    Component {
        id: tabsComponent

        Tabs {
            id: tabs
            anchors.fill: parent
            parent: leftPane
            ItemStyle.class: "new-tabs"

            property ActionList tools: selectedTab.page.tools

            Tab {
                id: mainTab
                title: "Media"
                page: PageStack {
                    id: pageStack

                    Component.onCompleted: pageStack.push(mainPage)

                    function home() {
                        pageStack.clear();
                        pageStack.push(mainPage)
                    }

                    ToolbarActions {
                        id: browsingTools
                        Action {
                            text: "home"
                            onTriggered: {
                                pageStack.home();
                            }
                        }
                    }

                    ToolbarActions {
                        id: mainTools
                        Action {
                            text: "settings"
                //            iconSource: Qt.resolvedUrl("1.png")
                            onTriggered: print("First action")
                         }

                        Action {
                            text: "Connect..."
                            onTriggered: {
                                var sheet = Qt.createComponent("ConnectionSheet.qml");
                                PopupUtils.open(sheet);
                            }
                        }
                    }


                    MainPage {
                        id: mainPage
                    }
                }
            }

            Tab {
                id: nowPlayingTab
                title: "Now Playing"
                page: NowPlayingPage {
                    id: nowPlayingPage
                    timerActive: tabs.currentIndex === 1
                }
            }

            Tab {
                id: keypadTab

                title: "Keypad"

                page: Keypad {
                }
            }
        }
    }
}
