import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtWebKit 3.0

Item {
    id: root
    property int nestingLevel;
    property bool isHtml;
    property string content;
    property string contentType;
    height: contentRect.height
    Rectangle {
        id: contentRect
        border.width: 2
        border.color: "black"
        anchors.leftMargin: nestingLevel * 5
        // color: Qt.rgba(Math.random(),Math.random(),Math.random(),1)
        color: "green"
        height: contentLoader.height
        width: root.width

        Loader {
            id: contentLoader
            anchors.top: contentRect.top
            anchors.left: contentRect.left
            width: contentRect.width
            sourceComponent: isHtml ? htmlComponent : textComponent
            //The webview doesn't resize to the content, so set a fixed size
            height: isHtml ? item.flickableItem.contentHeight : text.height
            onStatusChanged: {
                if (isHtml) {
                    item.flickableItem.loadHtml(root.content, "file:///");
                }
            }
        }

        Component {
            id: textComponent
            Text {
                id: text
                text: content
            }
        }
        Component {
            id: htmlComponent
            //We need the scrollview so the WebView can fully expand so we have access to the contentHeight
            //Otherwise it would just scale the content.
            ScrollView {
                horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                WebView {
                    id: htmlView
                    onNavigationRequested: {
                        // detect URL scheme prefix, most likely an external link
                        var schemaRE = /^\w+:/;
                        if (schemaRE.test(request.url)) {
                            request.action = WebView.AcceptRequest;
                        } else {
                            request.action = WebView.IgnoreRequest;
                            // delegate request.url here
                        }
                    }
                    onLoadingChanged: {
                        console.warn("Error is ", loadRequest.errorString);
                        console.warn("Status is ", loadRequest.status);
                    }
                }
            }
        }
    }
    onContentChanged: {
        if (isHtml) {
            contentLoader.item.flickableItem.loadHtml(content, "file:///");
        }
    }
}