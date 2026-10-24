import QtQuick
import Sanar.Filer

Row {
    id: root

    property int filter: DirectoryModel.ShowAll

    spacing: 8

    FilterChip {
        icon: "check"
        label: Tr.t("All")
        selected: root.filter === DirectoryModel.ShowAll
        onClicked: root.filter = DirectoryModel.ShowAll
    }

    FilterChip {
        icon: "folder"
        label: Tr.t("Folders")
        selected: root.filter === DirectoryModel.ShowFolders
        onClicked: root.filter = DirectoryModel.ShowFolders
    }

    FilterChip {
        icon: "image"
        label: Tr.t("Images")
        selected: root.filter === DirectoryModel.ShowImages
        onClicked: root.filter = DirectoryModel.ShowImages
    }

    FilterChip {
        icon: "description"
        label: Tr.t("Documents")
        selected: root.filter === DirectoryModel.ShowDocuments
        onClicked: root.filter = DirectoryModel.ShowDocuments
    }

    FilterChip {
        icon: "code"
        label: Tr.t("Code")
        selected: root.filter === DirectoryModel.ShowCode
        onClicked: root.filter = DirectoryModel.ShowCode
    }

    FilterChip {
        icon: "folder_zip"
        label: Tr.t("Archives")
        selected: root.filter === DirectoryModel.ShowArchives
        onClicked: root.filter = DirectoryModel.ShowArchives
    }
}
