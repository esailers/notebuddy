//
//  FlickrViewController.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/25/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import UIKit

protocol FlickrViewControllerDelegate: class {
    func selectedImagePath(_ path: String)
}

class FlickrViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Properties
    
    weak var delegate: FlickrViewControllerDelegate?
    
    @IBOutlet weak var flickrTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    let flickrCell = "flickrCell"
    
    var photos = [FlickrPhoto]()
    
    // MARK: - UIViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        flickrTextField.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        
        AppDelegate().setNavigationBarColors(navigationController)
        
        configureKeyboardView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        flickrTextField.becomeFirstResponder()
    }
    
    // MARK: - Actions
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        flickrTextField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func searchTapped(_ sender: UIBarButtonItem) {
        searchFlickr()
    }
    
    // MARK: - Helpers
    
    func searchFlickr() {
        if let text = flickrTextField.text {
            FlickrClient.sharedInstance().resultsFromFlickrSearch(text) { (photos, errorText) in
                DispatchQueue.main.async {
                    if let photos = photos {
                        self.photos = photos
                        self.collectionView.reloadData()
                    } else {
                        self.presentAlertForTitle("Error", message: errorText!)
                    }
                }
            }
        }
    }
    
    func configureKeyboardView() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        
        toolbar.items = [flexSpace, doneBarButton]
        flickrTextField.inputAccessoryView = toolbar
    }
    
    func dismissKeyboard() {
        flickrTextField.resignFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchFlickr()
        return true
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: flickrCell, for: indexPath) as! FlickrCollectionViewCell
        let photo = photos[(indexPath as NSIndexPath).item]
        
        cell.activityIndicator.isHidden = false
        cell.activityIndicator.startAnimating()
        
        FlickrClient().imageDataForPhoto(photo) {
            (imageData, error) in
            
            guard error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                cell.activityIndicator.isHidden = true
                cell.activityIndicator.stopAnimating()
                if let imageData = imageData {
                    cell.flickrImage.image = UIImage(data: imageData)
                }
            }
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[(indexPath as NSIndexPath).item]
        
        flickrTextField.resignFirstResponder()
        DispatchQueue.main.async {
            if let path = photo.path {
                self.delegate?.selectedImagePath(path)
            }
        }
    }
    
}

extension UIViewController {
    
    // MARK: - UIAlertController
    
    func presentAlertForTitle(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
