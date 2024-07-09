//
//  ViewController.swift
//  FilterColor
//
//  Created by Vivek Patel on 08/07/24.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    @IBOutlet fileprivate var captureButton: UIButton!
    @IBOutlet fileprivate var capturePreviewView: UIView!
    @IBOutlet fileprivate var photoModeButton: UIButton!
    @IBOutlet fileprivate var toggleCameraButton: UIButton!
    @IBOutlet fileprivate var toggleFlashButton: UIButton!
    @IBOutlet fileprivate var videoModeButton: UIButton!
    
    override var prefersStatusBarHidden: Bool { return true }
    
    let cameraController = CameraController()
    
    override func viewDidLoad() {
        
        configureCameraController()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.capturePreviewView)
        }
    }
    
    
}

extension ViewController {
    @IBAction func toggleFlash(_ sender: UIButton) {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash Off Icon"), for: .normal)
        }
        
        else {
            cameraController.flashMode = .on
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash On Icon"), for: .normal)
        }
    }
    
    
    
    @IBAction func captureImage(_ sender: UIButton) {
        sender.animate()
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            //Saves the image to the photo library
            //            try? PHPhotoLibrary.shared().performChangesAndWait {
            //                PHAssetChangeRequest.creationRequestForAsset(from: image)
            //            }
            
            self.navigateVC(image: image)
        }
    }
    
    
    @IBAction func switchCameras(_ sender: UIButton) {
        do {
            try cameraController.switchCameras()
        }
        
        catch {
            print(error)
        }
        
        switch cameraController.currentCameraPosition {
        case .some(.front):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Front Camera Icon"), for: .normal)
            
        case .some(.rear):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Rear Camera Icon"), for: .normal)
            
        case .none:
            return
        }
    }
    
    @IBAction func photoModeBtn(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func navigateVC(image: UIImage?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let filterViewController = storyboard.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController {
            filterViewController.selectedImage = image
            
            if let navigationController = self.navigationController {
                self.navigationController?.pushViewController(filterViewController, animated: true)
            } else {
                self.present(filterViewController, animated: true, completion: nil)
            }
        }
    }
    
    
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            // Handle the selected image here
            print("Selected image: \(selectedImage)")
            picker.dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.navigateVC(image: selectedImage)
                }
            }

        } else {
            picker.dismiss(animated: true, completion: nil)
        }
       
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}



