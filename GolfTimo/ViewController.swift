import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let cameraButton = UIButton(type: .system)
        cameraButton.setTitle("Open Golf Timer Camera", for: .normal)
        cameraButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        cameraButton.backgroundColor = .systemBlue
        cameraButton.setTitleColor(.white, for: .normal)
        cameraButton.layer.cornerRadius = 12
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        
        view.addSubview(cameraButton)
        
        NSLayoutConstraint.activate([
            cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cameraButton.widthAnchor.constraint(equalToConstant: 250),
            cameraButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func openCamera() {
        let cameraVC = CameraViewController()
        cameraVC.modalPresentationStyle = .fullScreen
        present(cameraVC, animated: true)
    }
}