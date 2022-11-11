//
//  FileMessageCell.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/9/15.
//

import Foundation

protocol FileMessageDelegate: MessageCellDelegate {
    func fileMessageCell(_ cell: FileMessageCell, didClickImageWith message: FileMessage)
}

class FileMessageCell: MessageCell {
    override class var reuseId: String {
        String(describing: FileMessageCell.self)
    }

    lazy var iconImageView = UIImageView().withoutAutoresizingMaskConstraints

    lazy var titleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = .zim_textBlack1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    lazy var sizeLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textColor = .zim_textBlack1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12)
        return label
    }()

    lazy var downloadingIndicator: UIActivityIndicatorView = {
        var style = UIActivityIndicatorView.Style.gray
        if #available(iOS 13.0, *) {
            style = .medium
        }
        let indicator = UIActivityIndicatorView(style: style).withoutAutoresizingMaskConstraints
        return indicator
    }()

    override var message: Message? {
        didSet {
            guard let message = message as? FileMessage else { return }
            message.$isDownloading.bindOnce { [weak self] _ in
                // when callback, self.message maybe is another object.
                if self?.message !== message { return }
                self?.updateDownloadingIndicator(message)
            }
        }
    }

    override func setUp() {
        super.setUp()
        containerView.backgroundColor = .zim_backgroundWhite
        containerView.layer.cornerRadius = 8.0

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        containerView.addGestureRecognizer(tap)
        containerView.isUserInteractionEnabled = true
    }

    override func setUpLayout() {
        super.setUpLayout()

        containerView.addSubview(iconImageView)
        iconImageView.pin(anchors: [.centerY], to: containerView)
        iconImageView.pin(to: 39)
        iconImageView.trailingAnchor.pin(
            equalTo: containerView.trailingAnchor,
            constant: -19.5)
            .isActive = true

        containerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.pin(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.pin(equalTo: iconImageView.leadingAnchor, constant: -23),
            titleLabel.topAnchor.pin(equalTo: containerView.topAnchor, constant: 11),
            titleLabel.heightAnchor.pin(equalToConstant: 21)
        ])

        containerView.addSubview(sizeLabel)
        NSLayoutConstraint.activate([
            sizeLabel.leadingAnchor.pin(equalTo: titleLabel.leadingAnchor),
            sizeLabel.trailingAnchor.pin(equalTo: titleLabel.trailingAnchor),
            sizeLabel.topAnchor.pin(equalTo: titleLabel.bottomAnchor, constant: 2),
            sizeLabel.heightAnchor.pin(equalToConstant: 16.5)
        ])

        containerView.addSubview(downloadingIndicator)
        downloadingIndicator.pin(anchors: [.centerX, .centerY], to: iconImageView)
        downloadingIndicator.pin(to: 24.0)
    }

    override func updateContent() {
        super.updateContent()

        guard let message = message as? FileMessage else { return }

        titleLabel.text = message.fileName
        sizeLabel.text = getFileSizeName(message.fileSize)
        iconImageView.image = loadImageSafely(with: getFileExtensionIcon(message.fileName))

        updateDownloadingIndicator(message)
    }

    private func updateDownloadingIndicator(_ message: FileMessage) {
        if message.isDownloading {
            downloadingIndicator.startAnimating()
        } else {
            downloadingIndicator.stopAnimating()
        }
    }

    private func getFileSizeName(_ size: Int64) -> String {
        if size < 1024 {
            return String(size) + " B"
        } else if size < 1024 * 1024 {
            return String(format: "%.2f", Double(size)/1024.0) + " KB"
        } else if size < 1024 * 1024 * 1024 {
            return String(format: "%.2f", Double(size)/1024.0/1024.0) + " MB"
        } else if size < 1024 * 1024 * 1024 * 1024 {
            return String(format: "%.2f", Double(size)/1024.0/1024.0/1024.0) + " GB"
        }
        return "0 B"
    }

    private func getFileExtensionIcon(_ path: String) -> String {

        let excelArray = ["xlsx", "xlsm", "xlsb", "xltx", "xltm", "xls", "xlt", "xls", "xml", "xlr", "xlw", "xla", "xlam"]
        let zipArray = ["rar", "zip", "arj", "gz", "arj", "z"]
        let wordArray = ["doc", "docx", "rtf", "dot", "html", "tmp", "wps"]
        let pptArray = ["ppt", "pptx", "pptm"]
        let pdfArray = ["pdf"]
        let txtArray = ["txt"]
        let videoArray =  ["mp4", "m4v", "mov", "qt", "avi", "flv", "wmv", "asf", "mpeg", "mpg", "vob", "mkv", "asf", "rm", "rmvb", "vob", "ts", "dat","3gp","3gpp","3g2","3gpp2","webm"]
        let audioArrary = ["mp3", "wma", "wav", "mid", "ape", "flac", "ape", "alac","m4a"]
        let picArrary = ["tiff", "heif", "heic", "jpg", "jpeg", "png", "gif", "bmp","webp"]

        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension.lowercased()

        if excelArray.contains(pathExtension) {
            return "file_icon_excel"
        } else if zipArray.contains(pathExtension) {
            return "file_icon_zip"
        } else if wordArray.contains(pathExtension) {
            return "file_icon_word"
        } else if pptArray.contains(pathExtension) {
            return "file_icon_ppt"
        } else if pdfArray.contains(pathExtension) {
            return "file_icon_pdf"
        } else if txtArray.contains(pathExtension) {
            return "file_icon_txt"
        } else if videoArray.contains(pathExtension) {
            return "file_icon_video"
        } else if audioArrary.contains(pathExtension) {
            return "file_icon_audio"
        } else if picArrary.contains(pathExtension) {
            return "file_icon_pic"
        }
        return "file_icon_other"
    }
}

extension FileMessageCell {
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        guard let message = message as? FileMessage else { return }
        let delegate = delegate as? FileMessageDelegate
        delegate?.fileMessageCell(self, didClickImageWith: message)
    }
}
