import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtWebKit 3.0

import org.kde.kube.mail 1.0 as Mail

Item {
    id: root
    property variant message;
    property string html;

    WebView {
        id: webview
        anchors.fill: parent
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

    onHtmlChanged: {
        // console.warn("HTML is ", html);
        // The file:/// argument is necessary so local icons are found
        webview.loadHtml(html, "file:///");
    }

    Mail.MessageParser {
        id: messageParser
        message: root.message
    }
    html: messageParser.html
}
