import AVFoundation
import SwiftUI
import UIKit

struct BookBarcodeScannerView: UIViewControllerRepresentable {
    let onCode: (String) -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        let viewController = ScannerViewController()
        viewController.onCode = onCode
        return viewController
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
}

final class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCode: ((String) -> Void)?

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var didReadCode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        configureSession()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didReadCode = false
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if session.isRunning {
            session.stopRunning()
        }
    }

    private func configureSession() {
        guard
            let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            return
        }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [
            .ean13,
            .ean8,
            .upce,
            .code128,
            .qr
        ]

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer

        let frameView = UIView()
        frameView.layer.borderColor = UIColor.systemYellow.cgColor
        frameView.layer.borderWidth = 4
        frameView.layer.cornerRadius = 12
        frameView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(frameView)

        NSLayoutConstraint.activate([
            frameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            frameView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            frameView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.72),
            frameView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard
            !didReadCode,
            let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let code = metadataObject.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines),
            !code.isEmpty
        else {
            return
        }

        didReadCode = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onCode?(code)
    }
}
