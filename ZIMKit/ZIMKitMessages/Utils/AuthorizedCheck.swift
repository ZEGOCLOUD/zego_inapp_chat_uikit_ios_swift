//
//  AuthorizedCheck.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/20.
//

import UIKit
import AVFoundation
import Photos

class AuthorizedCheck: NSObject {

    static func getMicAuthorization() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .audio)
    }

    static func getCameraAuthorization() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }

    static func getPhotoAuthorization() -> PHAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            return PHPhotoLibrary.authorizationStatus()
        }
    }

    // MARK: - Action
    static func takeCameraAuthorityStatus(completion: ((Bool) -> Void)?) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard let completion = completion else { return }
            completion(granted)
        }
    }

    static func takeMicPhoneAuthorityStatus(completion: ((Bool) -> Void)?) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            guard let completion = completion else { return }
            completion(granted)
        }
    }

    static func takePhotoAuthorityStatus(completion: ((PHAuthorizationStatus) -> Void)?) {
        if #available(iOS 14.0, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                completion?(status)
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                completion?(status)
            }
        }
    }

    static func showMicrophoneUnauthorizedAlert(_ viewController: UIViewController) {
        let title: String = L10n("message_photo_no_mic_tip")
        let message: String = L10n("message_photo_no_mic_description")
        showAlert(title, message, viewController) {
            openAppSettings()
        }
    }

    static func showCameraUnauthorizedAlert(_ viewController: UIViewController) {
        // TODO: - need add localized string
        let title: String = L10n("message_photo_no_camera_tip")
        let message: String = L10n("message_photo_no_camera_description")
        showAlert(title, message, viewController) {
            openAppSettings()
        }
    }

    static func showPhotoUnauthorizedAlert(_ viewController: UIViewController) {
        let title: String = L10n("message_photo_no_acess_tip")
        let message: String = L10n("message_photo_no_acess_description")
        showAlert(title, message, viewController) {
            openAppSettings()
        }
    }

    private static func showAlert(_ title: String,
                                  _ message: String,
                                  _ viewController: UIViewController,
                                  okCompletion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: L10n("message_access_later"), style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: L10n("message_go_setting"), style: .default) { _ in
                okCompletion()
            }
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            viewController.present(alert, animated: true, completion: nil)
        }
    }

    private static func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
