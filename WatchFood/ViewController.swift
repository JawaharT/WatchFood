//
//  ViewController.swift
//  WatchFood
//
//  Created by Jawahar Tunuguntla on 30/06/2018.
//  Copyright © 2018 Jawahar Tunuguntla. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageOfPictureTaken: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imageOfPictureTaken.image = userPickedImage
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage from UIImage.")
            }
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage){
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError("Loading CoreML failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError("Model Failed to process image.")
            }
            results.sorted(by: {$0.confidence > $1.confidence})
            let label: UILabel = UILabel(frame: CGRect(x:0, y:0, width:400, height:100))
            let textString: String = "\(results[0].identifier) - \(results[0].confidence*100)%"
            label.text = textString
            
            label.numberOfLines = 0
            label.font = UIFont.boldSystemFont(ofSize: 25.0)
            label.textAlignment = .left
            
            self.navigationItem.titleView = label
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do{
            try handler.perform([request])
        }catch{
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Choose Photo Gallery or Take Picture Now.", message: "", preferredStyle: .alert)
        let cameraAction = UIAlertAction(title: "Take Picture", style: .default) { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let photoLibraryAction = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        present(alert, animated: true, completion: nil)
    }
}
