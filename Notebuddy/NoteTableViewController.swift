//
//  NoteTableViewController.swift
//  Notebuddy
//
//  Created by Eric Sailers on 8/15/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import UIKit
import AVFoundation

class NoteTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, FlickrViewControllerDelegate {
    
    // MARK: - Properties
    
    var currentNotebook: Notebook?
    var currentNote: Note?
    
    var resizedImage: UIImage?
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!
    
    // MARK: - UIViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteTextView.textContainerInset = UIEdgeInsetsZero
        
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        if let currentNote = currentNote {
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
            navigationItem.title = currentNote.formattedDateAndTimeString(currentNote.createdDate)
            noteTextField.text = currentNote.title
            
            if let photo = currentNote.photo, image = UIImage(data: photo.imageData!) {
                noteImageView.image = image
                noteImageView.backgroundColor = UIColor.whiteColor()
                addPhotoLabel.hidden = true
            } else {
                noteImageView.backgroundColor = UIColor.lightGrayColor()
            }
                
            noteTextView.text = currentNote.content
            
        } else {
            navigationItem.title = Note.sharedInstance().formattedDateAndTimeString(NSDate())
            noteImageView.backgroundColor = UIColor.lightGrayColor()
            noteTextView.text = "Enter text"
        }
        
        // Need to enable user interaction for the imageView before the long press gesture can be recognized
        noteImageView.userInteractionEnabled = true
        addTapGestureRecognizer()
        
        noteTextField.delegate = self
        noteTextView.delegate = self
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            
            if noteTextView.text == "" {
                noteTextView.text = "Enter text"
            }
            
            currentNote?.setValue(noteTextField.text, forKey: "title")
            if let resizedImage = resizedImage, imageData = UIImageJPEGRepresentation(resizedImage, 1.0) {
                currentNote?.photo?.setValue(imageData, forKey: "imageData")
            }
            currentNote?.setValue(noteTextView.text, forKey: "content")
            DataManager.saveManagedContext()
            resignFirstResponders()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cancelNote(sender: UIBarButtonItem) {
        resignFirstResponders()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveNote(sender: UIBarButtonItem) {
        if let currentNotebook = currentNotebook, titleText = noteTextField.text {
            if titleText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" {
                currentNote = Note.sharedInstance().insertNoteInNotebook(currentNotebook, title: titleText, content: noteTextView.text)
                
                if let resizedImage = resizedImage, imageData = UIImageJPEGRepresentation(resizedImage, 1.0) {
                    currentNote?.photo = Photo.sharedInstance().insertPhotoInNote(currentNote!, imageData: imageData)
                }
                resignFirstResponders()
                dismissViewControllerAnimated(true, completion: nil)
            } else { presentAlertForTitle("Warning", message: "Please enter a title for your note.") }
        }
    }
    
    // MARK: - Helpers
    
    func resignFirstResponders() {
        noteTextField.resignFirstResponder()
        noteTextView.resignFirstResponder()
    }
    
    // MARK: - Gesture Recognizer
    
    func addTapGestureRecognizer() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapGesture.delegate = self
        noteImageView.addGestureRecognizer(tapGesture)
    }
    
    func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        presentImageActionSheet()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            resizedImage = resizeImage(selectedImage)
            
            addPhotoLabel.hidden = true
            noteImageView.image = resizedImage
            noteImageView.backgroundColor = UIColor.whiteColor()
            
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: - Resize image
    
    private func resizeImage(image: UIImage) -> UIImage {
        let aspectRatio: CGSize = image.size
        let boundingRect: CGRect = CGRectMake(0.0, 0.0, 400.0, 400.0)
        
        let resizedFrame: CGRect = AVMakeRectWithAspectRatioInsideRect(aspectRatio, boundingRect)
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(resizedFrame.size, !hasAlpha, scale)
        
        let rect = CGRect(origin: CGPointZero, size: resizedFrame.size)
        UIRectClip(rect)
        image.drawInRect(rect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "Enter text"  {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = "Enter text"
        }
    }
    
    // MARK: - UIAlertController
    
    func presentImageActionSheet() {
        let alertController = UIAlertController(title: "Add Photo", message: "", preferredStyle: .ActionSheet)
        
        let cancelButtonTitle = "Cancel"
        let cameraButtonTitle = "Camera"
        let photoLibraryButtonTitle = "Photo Library"
        let flickrPhotoButtonTitle = "Flickr Search"
        
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            
        }
        
        let cameraAction = UIAlertAction(title: cameraButtonTitle, style: .Default) { action in
            self.configurePicker(.Camera)
        }
        
        let photoLibraryAction = UIAlertAction(title: photoLibraryButtonTitle, style: .Default) { action in
            self.configurePicker(.PhotoLibrary)
        }
        
        let flickrPhotoAction = UIAlertAction(title: flickrPhotoButtonTitle, style: .Default) { action in
            self.performSegueWithIdentifier(StoryboardSegue.kSegueToFlickr, sender: self)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) { alertController.addAction(cameraAction) }
        alertController.addAction(cancelAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(flickrPhotoAction)
        
        // Configure popover for iPad
//        if let popoverPresentationController = alertController.popoverPresentationController {
//            popoverPresentationController.barButtonItem = cameraBarButton
//        }
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func configurePicker(sourceType: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        
        // Configure popover for Photo Library on iPad
//        if imagePickerController.sourceType == .PhotoLibrary { imagePickerController.modalPresentationStyle = .Popover }
//        if let popoverPresentationController = imagePickerController.popoverPresentationController {
//            popoverPresentationController.barButtonItem = cameraBarButton
//        }
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func presentAlertForTitle(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - FlickrViewControllerDelegate
    
    func selectedImagePath(path: String) {
        if let imageURL = NSURL(string: path), imageData = NSData(contentsOfURL: imageURL) {
            noteImageView.image = UIImage(data: imageData)
            resizedImage = noteImageView.image
            addPhotoLabel.hidden = true
            noteImageView.backgroundColor = UIColor.whiteColor()
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation
    
    private struct StoryboardSegue {
        static let kSegueToFlickr = "segueToFlickr"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardSegue.kSegueToFlickr {
            if let destination = segue.destinationViewController as? UINavigationController, flickrVC = destination.topViewController as? FlickrViewController {
                flickrVC.delegate = self
            }
        }
    }

}
