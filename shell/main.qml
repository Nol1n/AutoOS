import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: win
    width: 600
    height: 80
    visible: true
    title: "OpenClaw"

    Rectangle {
        anchors.fill: parent
        color: "#222"
    }

    Row {
        anchors.fill: parent
        spacing: 8
        anchors.margins: 8
        TextField {
            id: input
            anchors.verticalCenter: parent.verticalCenter
            placeholderText: "Type a command or 'create_folder /tmp/x'"
            width: parent.width - 120
            onAccepted: sendBtn.clicked()
        }
        Button {
            id: sendBtn
            text: "Send"
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                backend.sendText(input.text)
                input.text = ""
            }
        }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Space && event.modifiers === Qt.ControlModifier) {
            win.forceActiveFocus()
            input.forceActiveFocus()
        }
    }
}
