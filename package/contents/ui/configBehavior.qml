import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

ColumnLayout {
    property alias cfg_default_volume: volume.value
    RowLayout {
        Label {
            text: "Default Volume"
        }
        SpinBox {
            id: volume
            from: 0; to: 100
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
