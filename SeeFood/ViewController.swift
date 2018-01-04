//
//  ViewController.swift
//  SeeFood
//
//  Created by Admin on 06.12.17.
//  Copyright © 2017 Ionut-Catalin Bolea. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ChameleonFramework

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
        
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model failed.")
        }
        
        let request = VNCoreMLRequest(model: model){
            (request, error) in
            guard let results = request.results as? [VNClassificationObservation],
            let firstResult = results.first
            else {
                fatalError("Could not get a result")
            }
            
                if firstResult.identifier.lowercased().contains("chihuahua") {
                    self.navigationItem.title = "That's a chihuahua!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.flatBrown()
                }
                else if firstResult.identifier.lowercased().contains("muffin") {
                    self.navigationItem.title = "That's a muffin!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.flatBrownColorDark()
                    
                }
                else {
                    self.navigationItem.title = "That's neither! It's " + firstResult.identifier
                    self.navigationController?.navigationBar.barTintColor = UIColor.flatRed()
                }
                
            print(firstResult)
            print(firstResult.identifier)
            
            self.navigationItem.titleView?.layoutIfNeeded()
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    @IBAction func libraryTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
}

