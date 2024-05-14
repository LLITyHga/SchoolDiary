import UIKit

class CompendiumVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let screenWidth = UIScreen.main.bounds.width
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let openCameraButton = UIButton(type: .system)
        openCameraButton.setImage(UIImage(named: "Ellipse 21"), for: .normal)
        openCameraButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        
        self.view.addSubview(openCameraButton)
        openCameraButton.translatesAutoresizingMaskIntoConstraints = false
        
                NSLayoutConstraint.activate([
                    openCameraButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30),
                    openCameraButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    openCameraButton.widthAnchor.constraint(equalToConstant: screenWidth * 0.3),
                    openCameraButton.heightAnchor.constraint(equalToConstant: screenWidth * 0.3)])

    }
    
    @objc func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("Камера недоступна.")
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let takenImage = info[.originalImage] as? UIImage {
            saveImageToDocuments(image: takenImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func saveImageToDocuments(image: UIImage) {
        // Отримання URL папки "Documents"
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
