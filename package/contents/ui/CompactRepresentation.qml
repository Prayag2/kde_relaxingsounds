// QT/QML
import QtQuick 2.14
import QtGraphicalEffects 1.0

// PLASMA
import org.kde.plasma.core 2.0 as PlasmaCore

// MAIN
Item {
    id: compactRep
    signal middleClick

    PlasmaCore.IconItem {
        id: icon
        anchors.fill: parent
        source: "emblem-music-symbolic"

        // To expand the applet and mute/unmute the sounds
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton

            onClicked: {
                if (mouse.button == Qt.LeftButton) {
                    plasmoid.expanded = !plasmoid.expanded
                } else if (mouse.button == Qt.MiddleButton){
                    compactRep.middleClick()
                }
            }
        }
    }
    ColorOverlay {
        anchors.fill: parent
        source: icon
        color: root.playing && root.source? PlasmaCore.Theme.highlightColor : "transparent"
    }
}
