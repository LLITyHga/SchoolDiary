import UIKit
import AVFoundation

class CompendiumVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let screenWidth = UIScreen.main.bounds.width
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Кнопка для відкриття камери
        let openCameraButton = UIButton(type: .system)
        openCameraButton.setImage(UIImage(named: "Ellipse 21"), for: .normal) 
        openCameraButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        view.addSubview(openCameraButton)
        openCameraButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Кнопка для відкриття галереї
        let openGalleryButton = UIButton(type: .system)
        openGalleryButton.setImage(UIImage(named: "Next"), for: .normal)
        openGalleryButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        view.addSubview(openGalleryButton)
        openGalleryButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Обмеження для кнопок
        NSLayoutConstraint.activate([
            openCameraButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            openCameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -screenWidth * 0.25),
            openCameraButton.widthAnchor.constraint(equalToConstant: screenWidth * 0.3),
            openCameraButton.heightAnchor.constraint(equalToConstant: screenWidth * 0.3),
            
            openGalleryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            openGalleryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: screenWidth * 0.25),
            openGalleryButton.widthAnchor.constraint(equalToConstant: screenWidth * 0.3),
            openGalleryButton.heightAnchor.constraint(equalToConstant: screenWidth * 0.3)
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
}
