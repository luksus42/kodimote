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

import QtQuick 1.1
import com.nokia.meego 1.0
import Xbmc 1.0

Page {
    id: keyPad
    tools: toolBarKeypad
    orientationLock: PageOrientation.LockPortrait

    property QtObject player: xbmc.activePlayer
    property QtObject picturePlayer: xbmc.picturePlayer()

    property bool usePictureControls: xbmc.picturePlayerActive && !pictureControlsOverride
    property bool pictureControlsOverride: false

    ToolBarLayout {
        id: toolBarKeypad
        ToolIcon { platformIconId: "toolbar-column";
            anchors.left: parent===undefined ? undefined : parent.left
            onClicked: {
                pageStack.pop();
            }
        }
        ToolIcon { platformIconId: usePictureControls ? "toolbar-dialer" : "toolbar-image-edit";
            anchors.horizontalCenter: parent===undefined ? undefined : parent.horizontalCenter
            visible: xbmc.picturePlayerActive
            onClicked: {
                pictureControlsOverride = !pictureControlsOverride;
            }
        }
        ToolIcon {
            platformIconId: "toolbar-mediacontrol-play" + (enabled ? "" : "-dimmed");
            enabled: xbmc.activePlayer !== null
            anchors.right: parent===undefined ? undefined : parent.right
            onClicked: pageStack.replace(nowPlayingPage)
        }
    }

    property QtObject keys: xbmc.keys()

    Column {
        width: parent.width - 30
        anchors.centerIn: parent
        spacing: 30

        Item {
            width: parent.width
            height: jumpPointRow.height
            Rectangle { anchors.fill: parent; opacity: theme.inverted ? 0.1 : 0.05; radius: 20; color: theme.inverted ? "white" : "black" }
            Row {
                id: jumpPointRow
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: (width - musicButton.width * 5) / 4

                MediaControlButton {
                    source: "icons/pictures.png"
                    onClicked: xbmc.switchToWindow(Xbmc.GuiWindowPictures);
                }
                MediaControlButton {
                    id: musicButton
                    iconSource: "icon-m-music-video-all-songs"
                    onClicked: xbmc.switchToWindow(Xbmc.GuiWindowMusic);
                }
                MediaControlButton {
                    platformIconId: "toolbar-home"
                    onClicked: keys.home();
                }
                MediaControlButton {
                    source: "icons/videos.png"
                    onClicked: xbmc.switchToWindow(Xbmc.GuiWindowVideos);

                }
                MediaControlButton {
                    source: "icons/livetv.png"
                    onClicked: xbmc.switchToWindow(Xbmc.GuiWindowLiveTV);
                }
            }
        }

        GesturePad {
            id: gesturePad
            width: parent.width

            MediaControlButton {
                id: backButton
                anchors { left: parent.left; top: parent.top; margins: 10 }
                platformIconId: "toolbar-main-view"
                rotation: -90
                MouseArea {
                    width: parent.width * 2
                    height: parent.height * 1.2
                    anchors.centerIn: parent
                    rotation: 55
                    onClicked: {
                        rumbleEffect.start(2);
                        keys.back();
                    }
                }

            }

            MediaControlButton {
                anchors { right: parent.right; top: parent.top; margins: 10 }
                platformIconId: usePictureControls ? "" : "toolbar-main-view"
                iconSource: usePictureControls ? "icon-m-input-add" : ""
                rotation: usePictureControls ? 0 : 45
                MouseArea {
                    width: parent.width * 2
                    height: parent.height * 1.2
                    anchors.centerIn: parent
                    rotation: usePictureControls ? -145 : -190
                    onClicked: {
                        rumbleEffect.start(2);
                        if (usePictureControls) {
                            picturePlayer.zoomIn();
                        } else {
                            keys.fullscreen();
                        }
                    }
                }
            }
            MediaControlButton {
                anchors { left: parent.left; bottom: parent.bottom; margins: 10 }
                source: usePictureControls ? "" : "icons/icon-m-toolbar-info.png"
                iconSource: usePictureControls ? "icon-m-image-edit-rotate-right" : ""
                MouseArea {
                    width: parent.width * 2
                    height: parent.height * 1.2
                    anchors.centerIn: parent
                    rotation: -145
                    onClicked: {
                        rumbleEffect.start(2);
                        if (usePictureControls) {
                            picturePlayer.rotate();
                        } else {
                            keys.info();
                        }
                    }
                }
            }
            MediaControlButton {
                anchors { right: parent.right; bottom: parent.bottom; margins: 10 }
                platformIconId: usePictureControls ? "" : "toolbar-view-menu"
                iconSource: usePictureControls ? "icon-m-input-remove" : ""
                MouseArea {
                    width: parent.width * 2
                    height: parent.height * 1.2
                    anchors.centerIn: parent
                    onClicked: {
                        rumbleEffect.start(2);
                        if (usePictureControls) {
                            picturePlayer.zoomOut();
                        } else {
                            keys.osd();
                            keys.contextMenu();
                        }
                    }
                    rotation: 145
                }
            }
        }

        PlayerControls {
            id: controlButtons
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 20
            width: parent.width
            player: usePictureControls ? keyPad.picturePlayer : keyPad.player
            Rectangle { anchors.fill: controlButtons; opacity: theme.inverted ? 0.1 : 0.05; radius: 20; color: theme.inverted ? "white" : "black"; z: -1 }
        }

        Item {
            width: parent.width
            height: colorButtonRow.height
            Rectangle { anchors.fill: parent; opacity: theme.inverted ? 0.1 : 0.05; radius: 20; color: theme.inverted ? "white" : "black" }

            Row {
                id: colorButtonRow
                width: parent.width - spacing
                anchors.centerIn: parent
                height: controlButtons.height
                spacing: parent.width / 8
                Rectangle { height: 20; width: parent.spacing; color: "red"; anchors.verticalCenter: parent.verticalCenter; radius: 2
                    MouseArea { anchors.fill: parent; anchors.margins: -10; onClicked: { rumbleEffect.start(2); keys.red() } }
                }
                Rectangle { height: 20; width: parent.spacing; color: "green"; anchors.verticalCenter: parent.verticalCenter; radius: 2
                    MouseArea { anchors.fill: parent; anchors.margins: -10; onClicked: { rumbleEffect.start(2); keys.green() } }
                }
                Rectangle { height: 20; width: parent.spacing; color: "yellow"; anchors.verticalCenter: parent.verticalCenter; radius: 2
                    MouseArea { anchors.fill: parent; anchors.margins: -10; onClicked: { rumbleEffect.start(2); keys.yellow() } }
                }
                Rectangle { height: 20; width: parent.spacing; color: "blue"; anchors.verticalCenter: parent.verticalCenter; radius: 2
                    MouseArea { anchors.fill: parent; anchors.margins: -10; onClicked: { rumbleEffect.start(2); keys.blue() } }
                }
            }
        }
    }
}
