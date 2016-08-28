//
//  FlickrViewController.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/25/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import UIKit

protocol FlickrViewControllerDelegate: class {
    func selectedImagePath(path: String)
}

class FlickrViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Properties
    
    weak var delegate: FlickrViewControllerDelegate?
    
    @IBOutlet weak var flickrTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    let flickrCell = "flickrCell"
    
    var photos = [Photo]()
    
    // MARK: - UIViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        flickrTextField.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.allowsMultipleSelection = false
        
        configureKeyboardView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        flickrTextField.becomeFirstResponder()
    }
    
    // MARK: - Actions
    
    @IBAction func cancelTapped(sender: UIBarButtonItem) {
        flickrTextField.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func searchTapped(sender: UIBarButtonItem) {
        searchFlickr()
    }
    
    // MARK: - Helpers
    
    func searchFlickr() {
        if let text = flickrTextField.text {
            FlickrClient.sharedInstance().resultsFromFlickrSearch(text) { (photos, errorText) in
                dispatch_async(dispatch_get_main_queue()) {
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
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(self.dismissKeyboard))
        
        toolbar.items = [flexSpace, doneBarButton]
        flickrTextField.inputAccessoryView = toolbar
    }
    
    func dismissKeyboard() {
        flickrTextField.resignFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchFlickr()
        return true
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(flickrCell, forIndexPath: indexPath) as! FlickrCollectionViewCell
        let photo = photos[indexPath.item]
        
        cell.activityIndicator.hidden = false
        cell.activityIndicator.startAnimating()
        
        FlickrClient().imageDataForPhoto(photo) {
            (imageData, error) in
            
            guard error == nil else {
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                cell.activityIndicator.hidden = true
                cell.activityIndicator.stopAnimating()
                if let imageData = imageData {
                    cell.flickrImage.image = UIImage(data: imageData)
                }
            }
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = photos[indexPath.item]
        
        flickrTextField.resignFirstResponder()
        dispatch_async(dispatch_get_main_queue()) {
            if let path = photo.path {
                self.delegate?.selectedImagePath(path)
            }
        }
    }
    
    // MARK: - UIAlertController
    
    private func presentAlertForTitle(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}
