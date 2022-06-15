// QT/QML
import QtQml 2.0
import QtQuick 2.14
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import Qt.labs.folderlistmodel 2.0
import QtMultimedia 5.15
import QtQuick.Dialogs 1.3

// PLASMA
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

// ROOT
Item {
    id: root
    property bool playing: false;
    property string source;
    property var volume: plasmoid.configuration.default_volume

    // PLASMOID
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.compactRepresentation: CompactRepresentation {
        onMiddleClick: {
            root.playing= !root.playing
        }
    }
    Plasmoid.fullRepresentation: Item {
        id: fullRep
        property string source;
        signal clicked

        // Gets a list of audio files in the "../sounds" directory
        FolderListModel {
            id: folderModel
            folder: "../sounds/"
            showDirs: false
            nameFilters: ["*.mp3", "*.ogg", "*.wav", "*.opus", "*.flac"]
        }

        // Button delegate
        Component {
            id: buttonComp

            PlasmaComponents.Button {
                id: button
                text: fileBaseName
                iconSource: "emblem-music-symbolic"
                font.capitalization: Font.Capitalize
                width: fullRep.width

                property bool playingThis: root.playing && root.source == filePath
                checked: playingThis

                onClicked: {
                    if (playingThis) {
                        root.playing = false
                    } else {
                        root.source = filePath
                        root.playing = true
                    }
                    fullRep.clicked()
                }
                Component.onCompleted: {
                    if(index==0) {
                        root.source = filePath
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onPressed: {
                        if (!containsMouse) {
                            contextMenu.dismiss()
                        }
                    }
                    onClicked: {
                        contextMenu.popup()
                    }
                    Menu {
                        id: contextMenu
                        MenuItem {
                            text: `Delete ${fileBaseName}`
                            icon.name: "delete"
                            onTriggered: {
                                popup.open()
                            }
                        }
                    }
                    Popup {
                        id: popup
                        contentItem: ColumnLayout{
                            PlasmaComponents.Label {
                                text: "Are you sure? This action can't be undone."
                                wrapMode: Text.WordWrap
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                PlasmaComponents.Button {
                                    text: "Yes"
                                    iconSource: "delete"
                                    Layout.fillWidth: true
                                    onClicked: {
                                        var path = `${filePath}`
                                        dataSource.connectedSources = [`rm "${path}"`]
                                        popup.close()
                                    }
                                }
                                PlasmaComponents.Button {
                                    text: "Cancel"
                                    iconSource: "dialog-cancel"
                                    Layout.fillWidth: true

                                    onClicked: {
                                        popup.close()
                                    }
                                }
                            }
                        }
                    }
                }

            }
        }

        // Buttons
        ColumnLayout {
            id: mainColumn
            anchors.fill: parent

            ListView {
                id: buttons
                model: folderModel
                delegate: buttonComp
                clip: true
                spacing: 3
                Layout.fillHeight: true
                Layout.fillWidth: true
            }


            PlasmaComponents.Button {
                id: addMore
                text: "Add More Sounds"
                iconSource: "list-add-symbolic"
                width: fullRep.width
                onClicked: {
                    pickSound.open()
                }
            }
            RowLayout {
                Layout.fillWidth: true
                PlasmaCore.IconItem{
                    source: "player-volume"
                }
                Slider {
                    id: volume
                    Layout.fillWidth: true
                    from: 0; to: 100
                    value: root.volume

                    onValueChanged: {
                        root.volume=value
                    }
                }
            }
            FileDialog {
                id: pickSound
                nameFilters: ["Audio Files (mp3, ogg, wav, flac, opus) (*.ogg *.wav *.mp3 *.flac *.opus)"]
                folder: shortcuts.home
                onAccepted: {
                    var location = `${fileUrl}`
                    var filename = location.split("/").pop()
                    var home = shortcuts.home.slice(7)
                    var plasmoidLocation = `${home}/.local/share/plasma/plasmoids/com.github.prayag2.relaxingsounds`

                    // copying that file to the sounds folder
                    var cmd = `cp "${location.slice(7)}" "${plasmoidLocation}/contents/sounds/${filename}"`

                    // Running the command
                    dataSource.connectedSources = [cmd]
                }

            }

            // Run shell commands
            PlasmaCore.DataSource {
                id: dataSource
                engine: "executable"
                connectedSources: []

                onNewData: {
                    // Resetting connectedSources
                    connectedSources = []
                }
            }
        }
    }

    // AUDIO
    Audio {
        id: audio
        loops: Audio.Infinite
        property bool playing: root.playing
        property string audioSource: root.source
        volume: root.volume/100

        onAudioSourceChanged: {
            source = audioSource
            if (playing) {
                play()
            } else {
                pause()
            }
        }
        onPlayingChanged: {
            audioSourceChanged()
        }
    }

}
