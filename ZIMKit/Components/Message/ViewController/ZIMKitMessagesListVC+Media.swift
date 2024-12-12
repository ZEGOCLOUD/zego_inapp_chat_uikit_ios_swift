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

private var _currentFileMessageVM: MediaMessageViewModel?
private var _currentFileCell: MessageCell?

extension ZIMKitMessagesListVC {
    
    func selectPhotoForSend() {
        // don't need photo authorization when use PHPickerViewController and UIImagePickerController
        takeImagePhoto()
    }
    func takeCameraPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("相机不可用")
        }
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
    
    func previewFile(with messageVM: MediaMessageViewModel, cell: MessageCell) {
        _currentFileMessageVM = messageVM
        _currentFileCell = cell
        if FileManager.default.fileExists(atPath: messageVM.message.fileLocalPath) {
            let qlViewController = QLPreviewController()
            qlViewController.dataSource = self
            qlViewController.delegate = self
            present(qlViewController, animated: true)
            //            self.navigationController?.pushViewController(qlViewController, animated: true)
        } else {
            viewModel.downloadMediaMessage(messageVM)
        }
    }
    
    func createTemporaryURL(forData data: Data) -> URL {
        let temporaryDirectory = NSTemporaryDirectory()
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = URL(fileURLWithPath: temporaryDirectory).appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("创建临时 URL 时出错: \(error)")
            return URL(string: "")!
        }
    }
}


extension ZIMKitMessagesListVC : PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
                    
                    let fileManager = FileManager.default
                    do {
                        let attributes = try fileManager.attributesOfItem(atPath: url.path)
                        if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                            let sizeInMB = Double(fileSize) / (1024.0 * 1024.0)
                            print("图片大小为\(sizeInMB) MB")
                            // 在这里可以添加是否超过某个大小的判断，比如是否超过10MB
                            if sizeInMB > 10 {
                                HUDHelper.showMessage(L10n("message_photo_size_err_tips"))
                                return
                            }
                        }
                    } catch {
                        print("获取图片属性出错: \(error)")
                    }
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
                    
                    do {
                        // 使用 try? 来处理可能的抛出错误，并将其结果转换为可选值
                        let fileSize = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                        let isLargerThan100MB = fileSize! > 100 * 1024 * 1024 // 100MB
                        if isLargerThan100MB {// 100MB
                            HUDHelper.showMessage(L10n("message_file_size_err_tips"))
                            return
                        }
                    }
                    
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
                
                if let pickedImage = info[.originalImage] as? UIImage {
                    // 在这里调用函数判断图片大小是否超过100MB
                    if let sizeInMB = self?.getImageSizeInMB(image: pickedImage), sizeInMB > 10 {
                        HUDHelper.showMessage(L10n("message_photo_size_err_tips"))
                        return
                    }
                }
                
                if picker.sourceType == .camera {
                    if let image = info[.originalImage] as? UIImage {
                        let imageData = image.jpegData(compressionQuality: 1.0)!
                        let temporaryURL = self?.createTemporaryURL(forData: imageData)
                        self?.sendImageMessage(with: temporaryURL ?? URL(string: "")!)
                    }
                } else {
                    guard let url = info[.imageURL] as? URL else { return }
                    self?.sendImageMessage(with: url)
                }
                print("Pick an image.")
            } else if mediaType as CFString == kUTTypeMovie {
                print("Pick a video.")
                if let url = info[.mediaURL] as? URL {
                    do {
                        // 使用 try? 来处理可能的抛出错误，并将其结果转换为可选值
                        let fileSize = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                        let isLargerThan100MB = fileSize! > 100 * 1024 * 1024 // 100MB
                        if isLargerThan100MB {// 100MB
                            HUDHelper.showMessage(L10n("message_file_size_err_tips"))
                            return
                        }
                    }
                    self?.sendVideoMessage(with: url)
                    return
                }
                HUDHelper.showMessage("Not support this video.")
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func getImageSizeInMB(image: UIImage) -> Double? {
        if let imageData = image.pngData() {
            let sizeInMB = Double(imageData.count) / (1024.0 * 1024.0)
            return sizeInMB
        } else if let imageData = image.jpegData(compressionQuality: 1.0) {
            let sizeInMB = Double(imageData.count) / (1024.0 * 1024.0)
            return sizeInMB
        }
        return nil
    }
}

extension ZIMKitMessagesListVC: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            if !url.startAccessingSecurityScopedResource() { continue }
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                if let size = attributes[FileAttributeKey.size] as? NSNumber {
                    let fileSizeInBytes = size.int64Value
                    let fileSizeInMB = Double(fileSizeInBytes) / (1024 * 1024)
                    if fileSizeInMB > 100 {
                        HUDHelper.showMessage(L10n("message_file_size_err_tips"))
                        return
                    }
                }
            } catch {
                print("获取文件大小出错: \(error)")
            }
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

extension ZIMKitMessagesListVC: QLPreviewControllerDataSource,
                                QLPreviewControllerDelegate {
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        FilePreviewItem(with: _currentFileMessageVM!)
    }
    
    public func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        _currentFileCell?.containerView
    }
}

class FilePreviewItem: NSObject, QLPreviewItem {
    
    let messageVM: MediaMessageViewModel
    
    init(with messageVM: MediaMessageViewModel) {
        self.messageVM = messageVM
    }
    
    var previewItemURL: URL? {
        URL(fileURLWithPath: messageVM.message.fileLocalPath)
    }
    
    var previewItemTitle: String? {
        messageVM.message.fileName
    }
}
