import UIKit
import AVFoundation

class CompendiumVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
        // Кнопка для відкриття камери
        let openCameraButton = UIButton(type: .custom)
        openCameraButton.setImage(UIImage(named: "camera"), for: .normal)
        openCameraButton.imageView?.contentMode = .scaleAspectFit
        openCameraButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        view.addSubview(openCameraButton)
        openCameraButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Кнопка для відкриття галереї
        let openGalleryButton = UIButton(type: .custom)
        openGalleryButton.setImage(UIImage(named: "galerry"), for: .normal)
        openGalleryButton.imageView?.contentMode = .scaleAspectFit
        openGalleryButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        view.addSubview(openGalleryButton)
        openGalleryButton.translatesAutoresizingMaskIntoConstraints = false
        
        //back button
        let backButton = UIButton(type: .custom)
        let img = UIImage(systemName: "arrowshape.turn.up.left")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        backButton.setImage(img, for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
       view.addSubview(backButton)

        // Обмеження для кнопок
        NSLayoutConstraint.activate([
            openCameraButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            openCameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openCameraButton.widthAnchor.constraint(equalToConstant: screenWidth),
            openCameraButton.heightAnchor.constraint(equalToConstant: screenHeight / 2),
            
            openGalleryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 8),
            openGalleryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openGalleryButton.widthAnchor.constraint(equalToConstant: screenWidth),
            openGalleryButton.heightAnchor.constraint(equalToConstant: screenHeight / 2),
            
            backButton.heightAnchor.constraint(equalToConstant: 40),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.widthAnchor.constraint(equalTo: backButton.superview!.widthAnchor, multiplier: 0.1),
            backButton.heightAnchor.constraint(equalTo: backButton.superview!.heightAnchor, multiplier: 0.1),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            backButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                DispatchQueue.main.async {
                    self.openCamera()
                }
            } else {
                // Дозвіл не отримано, можна показати алерт з проханням змінити налаштування приватності
                DispatchQueue.main.async {
                    self.showPermissionAlert()
                }
            }
        }
    }
    func showPermissionAlert() {
        let alertController = UIAlertController(
            title: "Доступ до камери",
            message: "Додаток потребує доступу до вашої камери. Будь ласка, дозвольте доступ у налаштуваннях.",
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: "Налаштування", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    // Перевірка, чи вдалося відкрити налаштування
                })
            }
        }

        let cancelAction = UIAlertAction(title: "Скасувати", style: .cancel, handler: nil)

        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)

        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }



    
    @objc func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("Камера недоступна.")
        }
    }
    
    @objc func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("Галерея недоступна.")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let takenImage = info[.originalImage] as? UIImage {
            saveImageToDocuments(image: takenImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func saveImageToDocuments(image: UIImage) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Не вдалося отримати шлях до папки Documents.")
            return
        }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let filename = formatter.string(from: date) + ".jpg"
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            do {
                try imageData.write(to: fileURL)
                print("Зображення збережене: \(fileURL.path)")
            } catch {
                print("Помилка при збереженні зображення: \(error.localizedDescription)")
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    @objc func back() {
        self.dismiss(animated: true)
    }
}
