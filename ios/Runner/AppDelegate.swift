import AVFoundation
import Flutter
import Photos
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  private var ticketImagePickerResult: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let imagePickerChannel = FlutterMethodChannel(
        name: "ticketmaster/ticket_image_picker",
        binaryMessenger: controller.binaryMessenger
      )
      imagePickerChannel.setMethodCallHandler { [weak self] call, result in
        self?.handleTicketImagePicker(call: call, result: result)
      }

      let deviceIdentityChannel = FlutterMethodChannel(
        name: "ticketmaster/device_identity",
        binaryMessenger: controller.binaryMessenger
      )
      deviceIdentityChannel.setMethodCallHandler { [weak self] call, result in
        self?.handleDeviceIdentity(call: call, result: result)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handleDeviceIdentity(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "getDeviceIdentity" else {
      result(FlutterMethodNotImplemented)
      return
    }

    let device = UIDevice.current
    let identifier = device.identifierForVendor?.uuidString ?? device.name
    let label = [device.model, device.name]
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
      .joined(separator: " ")
    let documentsDirectory =
      FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? ""

    result([
      "deviceKey": "ios:\(identifier)",
      "deviceLabel": label.isEmpty ? "iPhone" : label,
      "storageDirectoryPath": documentsDirectory,
    ])
  }

  private func handleTicketImagePicker(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "pickTicketImage" else {
      result(FlutterMethodNotImplemented)
      return
    }

    if ticketImagePickerResult != nil {
      result(
        FlutterError(
          code: "busy",
          message: "Another image selection is already in progress.",
          details: nil
        )
      )
      return
    }

    guard
      let arguments = call.arguments as? [String: Any],
      let source = arguments["source"] as? String
    else {
      result(
        FlutterError(
          code: "invalid_args",
          message: "Image source was not provided.",
          details: nil
        )
      )
      return
    }

    ticketImagePickerResult = result

    switch source {
    case "camera":
      requestCameraAccessIfNeeded()
    case "gallery":
      requestPhotoLibraryAccessIfNeeded()
    default:
      finishWithError(
        code: "invalid_source",
        message: "Unsupported image source."
      )
    }
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true)
    ticketImagePickerResult?(nil)
    ticketImagePickerResult = nil
  }

  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    let result = ticketImagePickerResult
    ticketImagePickerResult = nil

    picker.dismiss(animated: true)

    guard let image = info[.originalImage] as? UIImage else {
      result?(
        FlutterError(
          code: "read_failed",
          message: "Unable to read the selected image.",
          details: nil
        )
      )
      return
    }

    guard let data = resizedImageData(from: image) else {
      result?(
        FlutterError(
          code: "read_failed",
          message: "Unable to process the selected image.",
          details: nil
        )
      )
      return
    }

    result?(FlutterStandardTypedData(bytes: data))
  }

  private func requestCameraAccessIfNeeded() {
    guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
      finishWithError(
        code: "unavailable",
        message: "Camera is not available on this device."
      )
      return
    }

    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      presentImagePicker(sourceType: .camera)
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
        DispatchQueue.main.async {
          if granted {
            self?.presentImagePicker(sourceType: .camera)
          } else {
            self?.finishWithError(
              code: "permission_denied",
              message: "Camera access is required to capture an image."
            )
          }
        }
      }
    case .denied, .restricted:
      finishWithError(
        code: "permission_denied",
        message: "Camera access is required to capture an image."
      )
    @unknown default:
      finishWithError(
        code: "permission_denied",
        message: "Camera access is unavailable right now."
      )
    }
  }

  private func requestPhotoLibraryAccessIfNeeded() {
    switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
    case .authorized, .limited:
      presentImagePicker(sourceType: .photoLibrary)
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
        DispatchQueue.main.async {
          switch status {
          case .authorized, .limited:
            self?.presentImagePicker(sourceType: .photoLibrary)
          default:
            self?.finishWithError(
              code: "permission_denied",
              message: "Gallery access is required to select an image."
            )
          }
        }
      }
    case .denied, .restricted:
      finishWithError(
        code: "permission_denied",
        message: "Gallery access is required to select an image."
      )
    @unknown default:
      finishWithError(
        code: "permission_denied",
        message: "Gallery access is unavailable right now."
      )
    }
  }

  private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = false
    picker.sourceType = sourceType

    guard let presenter = window?.rootViewController else {
      finishWithError(
        code: "unavailable",
        message: "Unable to open the image picker right now."
      )
      return
    }

    presenter.present(picker, animated: true)
  }

  private func finishWithError(code: String, message: String) {
    ticketImagePickerResult?(
      FlutterError(
        code: code,
        message: message,
        details: nil
      )
    )
    ticketImagePickerResult = nil
  }

  private func resizedImageData(from image: UIImage) -> Data? {
    let maxDimension: CGFloat = 1600
    let originalSize = image.size
    let longestSide = max(originalSize.width, originalSize.height)
    let scale = longestSide > maxDimension ? maxDimension / longestSide : 1
    let targetSize = CGSize(
      width: originalSize.width * scale,
      height: originalSize.height * scale
    )

    let renderer = UIGraphicsImageRenderer(size: targetSize)
    let renderedImage = renderer.image { _ in
      image.draw(in: CGRect(origin: .zero, size: targetSize))
    }
    return renderedImage.jpegData(compressionQuality: 0.88)
  }
}
