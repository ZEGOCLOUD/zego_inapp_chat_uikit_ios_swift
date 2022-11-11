//
//  MessageListVC+Media.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/24.
//

import Foundation
import Photos
import PhotosUI
import MobileCoreServices
import AssetsLibrary
import QuickLook

private var _currentFileMessage: FileMessage?
private var _currentFileCell: FileMessageCell?

extension MessagesListVC {

    func selectPhotoForSend() {
        // don't need photo authorization when use PHPickerViewController and UIImagePickerController
        takeImagePhoto()
    }

    private func takeImagePhoto() {
        DispatchQueue.main.async {
            if #available(iOS 14.0, *) {
                var config = PHPickerConfiguration()
                config.filter = PHPickerFilter.any(of: [.images, .videos, .livePhotos])
                config.selectionLimit = 9
                config.preferredAssetRepresentationMode = .current

                let picker = PHPickerViewController(configuration: config)
                picker.delegate = self
                //                picker.modalPresentationStyle = .fullScreen
                self.present(picker, animated: true)
            } else {
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let picker = UIImagePickerController()
                    //                    picker.modalPresentationStyle = .fullScreen
                    picker.sourceType = .savedPhotosAlbum
                    picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? ["public.image"]
                    picker.delegate = self
                    self.present(picker, animated: true)
                }
            }
        }
    }

    func selectFileForSend() {
        if #available(iOS 14.0, *) {
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data])
            picker.delegate = self
            //            picker.allowsMultipleSelection = true
            self.present(picker, animated: true)
        } else {
            let picker = UIDocumentPickerViewController(documentTypes: [kUTTypeData as String], in: .open)
            picker.delegate = self
            //            picker.allowsMultipleSelection = true
            self.present(picker, animated: true)
        }
    }

    func previewFile(with message: FileMessage, cell: FileMessageCell) {
        _currentFileMessage = message
        _currentFileCell = cell
        if FileManager.default.fileExists(atPath: message.fileLocalPath) {
            let qlViewController = QLPreviewController()
            qlViewController.dataSource = self
            qlViewController.delegate = self
            present(qlViewController, animated: true)
            //            self.navigationController?.pushViewController(qlViewController, animated: true)
        } else {
            viewModel.downloadMediaMessage(message)
        }
    }
}


extension MessagesListVC : PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @available(iOS 14, *)
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        DispatchQueue.main.async {
            picker.dismiss(animated: true)
        }
        if results.count == 0 { return }

        for result in results {
            let itemProvider = result.itemProvider
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] url, _ in
                    guard let url = url else { return }
                    self?.sendImageMessage(with: url)
                }
            } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                // if use `loadItem` may get a empty file
                // use load file will copy the video to a temp folder
                // and the `preferredAssetRepresentationMode` should set to `current`
                // or it will cost a few seconds to handle the video to `compatible`
                // Ref: https://developer.apple.com/forums/thread/652695
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, _ in
                    guard let url = url else { return }
                    self?.sendVideoMessage(with: url)
                }
            }
        }
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.delegate = nil
        picker.dismiss(animated: true) { [weak self] in
            guard let mediaType = info[.mediaType] as? String else { return }
            if mediaType as CFString == kUTTypeImage {
                guard let url = info[.imageURL] as? URL else { return }
                self?.sendImageMessage(with: url)
                print("Pick an image.")
            } else if mediaType as CFString == kUTTypeMovie {
                print("Pick a video.")
                if let url = info[.mediaURL] as? URL {
                    self?.sendVideoMessage(with: url)
                    return
                }
                HUDHelper.showMessage("Not support this video.")
            }
        }
    }

}

extension MessagesListVC: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            if !url.startAccessingSecurityScopedResource() { continue }
            let coordinator = NSFileCoordinator()
            coordinator.coordinate(readingItemAt: url, error: nil) { [weak self] _ in
                self?.sendFileMessage(with: url)
            }
            url.stopAccessingSecurityScopedResource()
        }
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {

    }
}

extension MessagesListVC: QLPreviewControllerDataSource,
                          QLPreviewControllerDelegate {
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        FilePreviewItem(with: _currentFileMessage!)
    }

    public func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        _currentFileCell?.containerView
    }
}

class FilePreviewItem: NSObject, QLPreviewItem {

    let message: MediaMessage

    init(with message: MediaMessage) {
        self.message = message
    }

    var previewItemURL: URL? {
        URL(fileURLWithPath: message.fileLocalPath)
    }

    var previewItemTitle: String? {
        message.fileName
    }
}
