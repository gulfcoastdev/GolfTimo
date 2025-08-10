import UIKit
import AVFoundation
import Photos
import PhotosUI

class CameraViewController: UIViewController {
    private var captureSession: AVCaptureSession?
    private var stillImageOutput: AVCapturePhotoOutput?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var clockOverlayView: ClockOverlayView!
    private var backgroundImageView: UIImageView!
    
    private var captureButton: UIButton!
    private var dismissButton: UIButton!
    private var overlayToggleButton: UIButton!
    private var photoPickerButton: UIButton!
    
    private var isCameraMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundImageView()
        setupUI()
        setupClockOverlay()
        checkCameraPermissions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if captureSession == nil {
            setupCamera()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            showAlert(message: "Unable to access camera")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        } catch let error {
            showAlert(message: "Error Unable to initialize camera: \(error.localizedDescription)")
        }
    }
    
    private func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        view.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.view.bounds
            }
        }
    }
    
    private func setupBackgroundImageView() {
        backgroundImageView = UIImageView()
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.backgroundColor = .black
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.isHidden = true
        view.addSubview(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupUI() {
        captureButton = UIButton(type: .custom)
        captureButton.backgroundColor = .white
        captureButton.layer.cornerRadius = 35
        captureButton.layer.borderWidth = 5
        captureButton.layer.borderColor = UIColor.lightGray.cgColor
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        
        dismissButton = UIButton(type: .system)
        dismissButton.setTitle("×", for: .normal)
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .light)
        dismissButton.setTitleColor(.white, for: .normal)
        dismissButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dismissButton.layer.cornerRadius = 25
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.addTarget(self, action: #selector(dismissCamera), for: .touchUpInside)
        
        overlayToggleButton = UIButton(type: .system)
        overlayToggleButton.setTitle("Clock", for: .normal)
        overlayToggleButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        overlayToggleButton.setTitleColor(.white, for: .normal)
        overlayToggleButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayToggleButton.layer.cornerRadius = 20
        overlayToggleButton.translatesAutoresizingMaskIntoConstraints = false
        overlayToggleButton.addTarget(self, action: #selector(toggleOverlay), for: .touchUpInside)
        
        photoPickerButton = UIButton(type: .system)
        photoPickerButton.setTitle("📸", for: .normal)
        photoPickerButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        photoPickerButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        photoPickerButton.layer.cornerRadius = 25
        photoPickerButton.translatesAutoresizingMaskIntoConstraints = false
        photoPickerButton.addTarget(self, action: #selector(openPhotoPicker), for: .touchUpInside)
        
        view.addSubview(captureButton)
        view.addSubview(dismissButton)
        view.addSubview(overlayToggleButton)
        view.addSubview(photoPickerButton)
        
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70),
            
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dismissButton.widthAnchor.constraint(equalToConstant: 50),
            dismissButton.heightAnchor.constraint(equalToConstant: 50),
            
            overlayToggleButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            overlayToggleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            overlayToggleButton.widthAnchor.constraint(equalToConstant: 80),
            overlayToggleButton.heightAnchor.constraint(equalToConstant: 40),
            
            photoPickerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            photoPickerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            photoPickerButton.widthAnchor.constraint(equalToConstant: 50),
            photoPickerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupClockOverlay() {
        clockOverlayView = ClockOverlayView()
        clockOverlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clockOverlayView)
        
        NSLayoutConstraint.activate([
            clockOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            clockOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            clockOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            clockOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func capturePhoto() {
        if isCameraMode, let stillImageOutput = stillImageOutput {
            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            stillImageOutput.capturePhoto(with: settings, delegate: self)
            
            UIView.animate(withDuration: 0.1, animations: {
                self.captureButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    self.captureButton.transform = CGAffineTransform.identity
                }
            }
        } else {
            openPhotoPicker()
        }
    }
    
    @objc private func dismissCamera() {
        dismiss(animated: true)
    }
    
    @objc private func toggleOverlay() {
        clockOverlayView.isHidden.toggle()
        overlayToggleButton.alpha = clockOverlayView.isHidden ? 0.5 : 1.0
    }
    
    @objc private func openPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func switchToPhotoMode() {
        isCameraMode = false
        captureSession?.stopRunning()
        videoPreviewLayer?.removeFromSuperlayer()
        backgroundImageView.isHidden = false
        captureButton.setTitle("📸", for: .normal)
        captureButton.backgroundColor = UIColor.blue.withAlphaComponent(0.8)
        photoPickerButton.isHidden = true
    }
    
    private func switchToCameraMode() {
        isCameraMode = true
        backgroundImageView.isHidden = true
        captureButton.setTitle("", for: .normal)
        captureButton.backgroundColor = .white
        photoPickerButton.isHidden = false
        if let captureSession = captureSession {
            DispatchQueue.global(qos: .background).async {
                captureSession.startRunning()
            }
        }
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                self.setupCamera()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupCamera()
                    } else {
                        self.switchToPhotoMode()
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.switchToPhotoMode()
            }
        @unknown default:
            DispatchQueue.main.async {
                self.switchToPhotoMode()
            }
        }
    }
    
    private func showPermissionAlert() {
        DispatchQueue.main.async {
            guard self.isViewLoaded && self.view.window != nil else {
                return
            }
            let alert = UIAlertController(title: "Camera Permission", message: "Camera access is needed to record golf swings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                self.dismiss(animated: true)
            })
            self.present(alert, animated: true)
        }
    }
    
    private func showAlert(message: String) {
        DispatchQueue.main.async {
            guard self.isViewLoaded && self.view.window != nil else {
                return
            }
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: imageData)
        
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
        let flashView = UIView(frame: view.bounds)
        flashView.backgroundColor = .white
        flashView.alpha = 0
        view.addSubview(flashView)
        
        UIView.animate(withDuration: 0.1, animations: {
            flashView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                flashView.alpha = 0
            } completion: { _ in
                flashView.removeFromSuperview()
            }
        }
        
        let haptic = UIImpactFeedbackGenerator(style: .medium)
        haptic.impactOccurred()
    }
}

extension CameraViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            DispatchQueue.main.async {
                if let image = object as? UIImage {
                    self?.backgroundImageView.image = image
                    self?.backgroundImageView.isHidden = false
                }
            }
        }
    }
}