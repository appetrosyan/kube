/*
  Copyright (C) 2016 Michael Bohlender, <michael.bohlender@kdemail.net>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
*/

import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1

import org.kube.framework 1.0 as Kube

Rectangle {
    id: root

    property variant accountId

    color: Kube.Colors.textColor

    TreeView {
        id: treeView

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        height: parent.height

        TableViewColumn {
            title: "Name"
            role: "name"
        }

        model: Kube.FolderListModel {
            id: folderListModel
            accountId: root.accountId
        }

        onCurrentIndexChanged: {
            model.fetchMore(currentIndex)
            Kube.Fabric.postMessage(Kube.Messages.folderSelection, {"folder":model.data(currentIndex, Kube.FolderListModel.DomainObject),
                                                           "trash":model.data(currentIndex, Kube.FolderListModel.Trash)})
            Kube.Fabric.postMessage(Kube.Messages.synchronize, {"folder":model.data(currentIndex, Kube.FolderListModel.DomainObject)})
            console.error(model.data)
        }

        alternatingRowColors: false
        headerVisible: false

        style: TreeViewStyle {

            rowDelegate: Rectangle {
                color: styleData.selected ? Kube.Colors.highlightColor : Kube.Colors.textColor

                height: Kube.Units.gridUnit * 1.5
                width: 20

            }

            frame: Rectangle {
                color: Kube.Colors.textColor
            }

            branchDelegate: Item {

                width: 16; height: 16

                Kube.Label  {
                    anchors.centerIn: parent

                    color: Kube.Colors.viewBackgroundColor
                    text: styleData.isExpanded ? "-" : "+"
                }

                //radius: styleData.isExpanded ? 0 : 100
            }

            itemDelegate: Rectangle {

                color: styleData.selected ? Kube.Colors.highlightColor : Kube.Colors.textColor

                DropArea {
                    anchors.fill: parent

                    Rectangle {
                        anchors.fill: parent
                        color: Kube.Colors.viewBackgroundColor

                        opacity: 0.3

                        visible: parent.containsDrag
                    }
                    onDropped: {
                        Kube.Fabric.postMessage(Kube.Messages.moveToFolder, {"mail": drop.source.mail, "folder":model.domainObject})
                        drop.accept(Qt.MoveAction)
                        drop.source.visible = false
                    }
                }

                Row {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                    }
                    Kube.Label {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            leftMargin: Kube.Units.smallSpacing
                        }

                        text: styleData.value

                        color: Kube.Colors.viewBackgroundColor
                    }
                    Kube.Icon {
                        id: statusIcon
                        visible: false
                        iconName: ""
                        states: [
                            State {
                                name: "busy"; when: model.status == Kube.FolderListModel.InProgressStatus
                                PropertyChanges { target: statusIcon; iconName: Kube.Icons.busy_inverted ; visible: styleData.selected }
                            },
                            State {
                                name: "error"; when: model.status == Kube.FolderListModel.ErrorStatus
                                //The error status should only be visible for a moment, otherwise we'll eventually always show errors everywhere.
                                PropertyChanges { target: statusIcon; iconName: Kube.Icons.error_inverted; visible: styleData.selected }
                            },
                            State {
                                name: "checkmark"; when: model.status == Kube.FolderListModel.SuccessStatus
                                //The success status should only be visible for a moment, otherwise we'll eventually always show checkmarks everywhere.
                                PropertyChanges { target: statusIcon; iconName: Kube.Icons.success_inverted; visible: styleData.selected}
                            }
                        ]
                    }
                }
            }

            backgroundColor: Kube.Colors.textColor
            highlightedTextColor: Kube.Colors.highlightedTextColor
        }
    }
}
