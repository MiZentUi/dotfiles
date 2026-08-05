import Quickshell
import Quickshell.Io
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell.Wayland

PanelWindow {
    id: main
    implicitHeight: 500
    implicitWidth: Screen.width
    color: "transparent"
    property int speed: 5000

    aboveWindows: true
    exclusionMode: "Ignore"
    exclusiveZone: 1

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    Component.onCompleted: {
        Quickshell.execDetached(["bash", Quickshell.shellPath("cache.sh"), Quickshell.shellDir]);
    }

    FileView {
        path: Quickshell.shellPath("config.json")
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: config
            property string wallpaper_path
            property string cache_path
            property int number_of_pictures
            property int height
            property real x_factor
        }
    }

    FileView {
        path: Quickshell.shellPath("colors.json")
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: colors
            property string border_color
        }
    }

    FileView {
        id: current
        blockLoading: true

        path: config.cache_path ? "file://" + resolveEnvVars(config.cache_path) + "/current" : ""

        onPathChanged: {
            if (path !== "") {
                reload();
            }
        }

        onLoaded: {
            list.selectCurrent(text().trim());
        }
    }

    function resolveEnvVars(inputPath) {
        return inputPath.replace(/\$(\w+)/g, function (match, varName) {
            return Quickshell.env(varName) ?? "";
        });
    }

    FolderListModel {
        id: folderModel
        folder: "file://" + resolveEnvVars(config.wallpaper_path)
        showDirs: false
        nameFilters: ["*.png", "*.jpg"]
        sortField: FolderListModel.Name

        onCountChanged: {
            if (count > 0 && current.status === FileView.Ready) {
                list.selectCurrent(current.text().trim());
            }
        }
    }

    ListView {
        id: list
        anchors.fill: parent
        focus: true

        model: folderModel
        orientation: ListView.Horizontal
        spacing: 4
        clip: true
        cacheBuffer: width * 2

        property int selectedIndex: 0
        property real tileWidth: width / config.number_of_pictures - 10

        property real shearOffset: config.height * Math.abs(config.x_factor)

        leftMargin: config.x_factor < 0 ? shearOffset : 0

        function clampIndex(i) {
            return Math.max(0, Math.min(i, count - 1));
        }

        property bool initialPosition: true

        function selectCurrent(current) {
            for (let i = 0; i < folderModel.count; ++i) {
                console.log(folderModel.get(i, "filePath"));
                if (folderModel.get(i, "fileName") === current) {
                    selectedIndex = i;

                    initialPosition = true;
                    ensureVisibleAnimated(i);

                    Qt.callLater(() => {
                        initialPosition = false;
                    });

                    return;
                }
            }
        }

        function activateCurrent() {
            const path = folderModel.get(selectedIndex, "filePath");
            Quickshell.execDetached(["bash", Quickshell.shellPath("commands.sh"), path]);
            Quickshell.execDetached(["sh", "-c", "echo " + folderModel.get(selectedIndex, "fileName") + ">" + resolveEnvVars(config.cache_path) + "/current"]);
            Qt.quit();
        }

        function clampX(x) {
            const max = contentWidth - width;
            const clamped = Math.max(0, Math.min(x, max));

            return config.x_factor < 0 ? (clamped === 0 ? -shearOffset : clamped) : (clamped === 0 ? 0 : clamped === max ? x + shearOffset : clamped);
        }

        function ensureVisibleAnimated(i) {
            const step = tileWidth + spacing;
            const itemStart = i * step;
            const itemEnd = itemStart + tileWidth + 20;

            contentX = clampX(itemStart - (width - tileWidth) / 2);
        }

        Behavior on contentX {
            enabled: !list.initialPosition

            SmoothedAnimation {
                id: anim
                property int v: 10
                duration: 500
            }
        }

        Component.onCompleted: {
            anim.v = main.speed;
        }

        delegate: Item {
            property bool active: index === list.selectedIndex
            width: list.tileWidth

            height: config.height

            Behavior on width {
                NumberAnimation {
                    duration: 50
                    easing.type: Easing.OutCubic
                }
            }

            Text {
                id: alt
                text: "Loading..."
                color: colors.border_color
                anchors.centerIn: parent
                font.pixelSize: 16
                transform: Shear {
                    xFactor: config.x_factor
                }
            }

            Image {
                id: img
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop

                asynchronous: true
                cache: false
                smooth: true

                source: "file://" + resolveEnvVars(config.cache_path) + "/" + fileName

                sourceSize.width: width
                sourceSize.height: height

                transform: Shear {
                    xFactor: config.x_factor
                }

                Timer {
                    id: retryTimer
                    interval: 1000
                    repeat: false
                    onTriggered: {
                        let s = img.source;
                        img.source = "";
                        img.source = s;
                    }
                }

                onStatusChanged: {
                    if (status === Image.Error) {
                        alt.text = "Caching";
                        retryTimer.start();
                    }
                }
            }

            Rectangle {
                id: border
                z: 10
                visible: parent.active
                width: list.tileWidth
                height: config.height
                color: "transparent"

                border.width: 4
                border.color: colors.border_color

                transform: Shear {
                    xFactor: config.x_factor
                }
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    list.selectedIndex = index;
                    list.activateCurrent();
                }

                onWheel: function (wheel) {
                    list.contentX = list.clampX(list.contentX - wheel.angleDelta.y * 2);
                    wheel.accepted = false;
                }
            }
        }

        Keys.onPressed: function (event) {
            const step = 1;
            const big = config.number_of_pictures;

            if (event.key === Qt.Key_J || event.key === Qt.Key_L || event.key === Qt.Key_Down || event.key === Qt.Key_Right) {
                anim.v = main.speed;
                selectedIndex = clampIndex(selectedIndex + step);
                ensureVisibleAnimated(selectedIndex);
            } else if (event.key === Qt.Key_K || event.key === Qt.Key_H || event.key === Qt.Key_Up || event.key === Qt.Key_Left) {
                anim.v = main.speed;
                selectedIndex = clampIndex(selectedIndex - step);
                ensureVisibleAnimated(selectedIndex);
            } else if (event.key === Qt.Key_Tab) {
                anim.v = main.speed;
                selectedIndex = clampIndex((selectedIndex + step) % count);
                ensureVisibleAnimated(selectedIndex);
            } else if (event.key === Qt.Key_Backtab) {
                anim.v = main.speed;
                selectedIndex = clampIndex(((selectedIndex - step) % count + count) % count);
                ensureVisibleAnimated(selectedIndex);
            } else if (event.key === Qt.Key_D) {
                anim.v = main.speed * big;
                selectedIndex = clampIndex(selectedIndex + big);
                ensureVisibleAnimated(selectedIndex);
            } else if (event.key === Qt.Key_U) {
                anim.v = main.speed * big;
                selectedIndex = clampIndex(selectedIndex - big);
                ensureVisibleAnimated(selectedIndex);
            } else if (event.key === Qt.Key_Space || event.key === Qt.Key_Return) {
                activateCurrent();
            } else if (event.key === Qt.Key_Escape) {
                Qt.quit();
            } else
                return;
            event.accepted = true;
        }
    }
}
