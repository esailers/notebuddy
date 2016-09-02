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
    
    let noteTitleCellIdentifier = "noteTitleCell"
    let notePhotoCellIdentifier = "notePhotoCell"
    let noteContentCellIdentifier = "noteContentCell"
    
    var noteTitleCell: NoteTitleTableViewCell!
    var notePhotoCell: NotePhotoTableViewCell!
    var noteContentCell: NoteContentTableViewCell!
    
    // MARK: - UIViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsSelection = false
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        if let currentNote = currentNote {
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
            navigationItem.title = currentNote.formattedDateAndTimeString(currentNote.createdDate)
        } else {
            navigationItem.title = Note.sharedInstance().formattedDateAndTimeString(NSDate())
        }
        
        tableView.estimatedRowHeight = 50
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            
            if noteContentCell.noteTextView.text == "" {
                noteContentCell.noteTextView.text = "Enter text"
            }
            
            currentNote?.setValue(noteTitleCell.noteTitleTextField.text, forKey: "title")
            if let resizedImage = resizedImage, imageData = UIImageJPEGRepresentation(resizedImage, 1.0) {
                currentNote?.photo?.setValue(imageData, forKey: "imageData")
            }
            currentNote?.setValue(noteContentCell.noteTextView.text, forKey: "content")
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
        if let currentNotebook = currentNotebook, titleText = noteTitleCell.noteTitleTextField.text {
            if titleText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" && resizedImage != nil {
                currentNote = Note.sharedInstance().insertNoteInNotebook(currentNotebook, title: titleText, content: noteContentCell.noteTextView.text)
                
                if let resizedImage = resizedImage, imageData = UIImageJPEGRepresentation(resizedImage, 1.0) {
                    currentNote?.photo = Photo.sharedInstance().insertPhotoInNote(currentNote!, imageData: imageData)
                }
                resignFirstResponders()
                dismissViewControllerAnimated(true, completion: nil)
            } else { presentAlertForTitle("Warning", message: "Please enter a title and add a photo for your note.") }
        }
    }
    
    // MARK: - Helpers
    
    func resignFirstResponders() {
        noteTitleCell.noteTitleTextField.resignFirstResponder()
        noteContentCell.noteTextView.resignFirstResponder()
    }
    
    private func configurePopover(popoverPresentationController: UIPopoverPresentationController) {
        resignFirstResponders()
        popoverPresentationController.sourceRect = notePhotoCell.noteImageView.frame //noteImageView.frame
        popoverPresentationController.sourceView = self.view
        popoverPresentationController.permittedArrowDirections = .Any
    }
    
    // MARK: - Gesture Recognizer
    
    func addTapGestureRecognizer() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapGesture.delegate = self
        notePhotoCell.noteImageView.addGestureRecognizer(tapGesture)
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
            
            notePhotoCell.notePhotoLabel.hidden = true
            notePhotoCell.noteImageView.image = resizedImage
            
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
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            noteTitleCell = tableView.dequeueReusableCellWithIdentifier(noteTitleCellIdentifier, forIndexPath: indexPath) as! NoteTitleTableViewCell
            noteTitleCell.noteTitleTextField.delegate = self
            
            if let currentNote = currentNote {
                noteTitleCell.noteTitleTextField.text = currentNote.title
            }
            
            return noteTitleCell
        case 1:
            notePhotoCell = tableView.dequeueReusableCellWithIdentifier(notePhotoCellIdentifier, forIndexPath: indexPath) as! NotePhotoTableViewCell
            
            if let currentNote = currentNote, photo = currentNote.photo, image = UIImage(data: photo.imageData!) {
                notePhotoCell.noteImageView.image = image
                notePhotoCell.notePhotoLabel.hidden = true
            }
            
            notePhotoCell.noteImageView.userInteractionEnabled = true
            addTapGestureRecognizer()
            
            return notePhotoCell
        case 2:
            noteContentCell = tableView.dequeueReusableCellWithIdentifier(noteContentCellIdentifier, forIndexPath: indexPath) as! NoteContentTableViewCell
            noteContentCell.noteTextView.textContainerInset = UIEdgeInsetsZero
            noteContentCell.noteTextView.delegate = self
            
            if let currentNote = currentNote {
                noteContentCell.noteTextView.text = currentNote.content
            } else {
                noteContentCell.noteTextView.text = "Enter text"
            }
            
            return noteContentCell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellIdentifier", forIndexPath: indexPath)
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard indexPath.row == 1 else { return UITableViewAutomaticDimension }
        return 200.0
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(textView: UITextView) {
        // Code from http://candycode.io/self-sizing-uitextview-in-a-uitableview-using-auto-layout-like-reminders-app/
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: false)
    }
    
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
        if let popoverPresentationController = alertController.popoverPresentationController {
            configurePopover(popoverPresentationController)
        }
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func configurePicker(sourceType: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        
        // Configure popover for Photo Library on iPad
        if imagePickerController.sourceType == .PhotoLibrary { imagePickerController.modalPresentationStyle = .Popover }
        if let popoverPresentationController = imagePickerController.popoverPresentationController {
            configurePopover(popoverPresentationController)
        }
        
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
            notePhotoCell.noteImageView.image = UIImage(data: imageData)
            resizedImage = notePhotoCell.noteImageView.image
            notePhotoCell.notePhotoLabel.hidden = true
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
