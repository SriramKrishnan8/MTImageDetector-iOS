//
//  ViewController.swift
//  MTMachineLearningSample
//
//  Created by Sriram Krishnan on 15/06/17.
//  Copyright © 2017 Mallow Technologies. All rights reserved.
//

import UIKit
import Photos
import CoreML
import Vision

class ViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    
    var imagePickerController: UIImagePickerController?
    
    //MARK:- View Life Cycle Method

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        configureImagePicker()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//MARK:- IBAction Method

extension ViewController {
    
    @IBAction func chooseImage(_ sender: Any) {
        showLibrary()
    }
    
}

//MARK:- Custom Methods

extension ViewController {
    
    func configureImagePicker() {
        imagePickerController = UIImagePickerController()
        imagePickerController!.delegate = self
        imagePickerController!.allowsEditing = true
    }
    
    func showLibrary() {
        imagePickerController!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        let authorizationStatus: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .denied:
            accessPhotoLibraryAlert()
            break
        case .restricted:
            accessPhotoLibraryAlert()
            break
        case .authorized:
            presentImagePicker()
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                if authorizationStatus == .denied || authorizationStatus == .notDetermined || authorizationStatus == .restricted {
                    return
                }
                else {
                    self.presentImagePicker()
                }
            })
            break
        }
    }
    
    func presentImagePicker() {
        descriptionLabel.text = ""
        self.present(imagePickerController!, animated: true, completion: nil)
    }
    
    func accessPhotoLibraryAlert() {
        descriptionLabel.text = "Allow App to access photo"
    }
    
    func detectImage(image: CVPixelBuffer) {
        if let model = try? VNCoreMLModel(for: Inceptionv3().model) {//Get the model
            let request = VNCoreMLRequest(model: model) { [weak self] response, error in//Create a request using the model
                if let results = response.results as? [VNClassificationObservation], let topResult = results.first {//Using the request, get the result
                    DispatchQueue.main.async { [weak self] in
                        self?.descriptionLabel.text = "\(topResult.identifier)\n\(Int(topResult.confidence * 100))% Sure"//Update the label
                    }
                }
            }
            
            //The following is to perform the request
            let handler = VNImageRequestHandler(ciImage: CIImage(image: imageView.image!)!)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print(error)
                }
            }
        }
    }
    
}


//MARK: UIImagePicker Delegate Methods

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = (info[UIImagePickerControllerEditedImage] as! UIImage)
        detectImage(image: info[UIImagePickerControllerEditedImage] as! CVPixelBuffer)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

