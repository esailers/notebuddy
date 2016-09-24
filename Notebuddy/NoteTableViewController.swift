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
            navigationItem.title = Note.sharedInstance().formattedDateAndTimeString(Date())
        }
        
        AppDelegate().setNavigationBarColors(navigationController)
        
        tableView.estimatedRowHeight = 50
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            
            if noteContentCell.noteTextView.text == "" {
                noteContentCell.noteTextView.text = "Enter text"
            }
            
            currentNote?.setValue(noteTitleCell.noteTitleTextField.text, forKey: "title")
            if let resizedImage = resizedImage, let imageData = UIImageJPEGRepresentation(resizedImage, 1.0) {
                currentNote?.photo?.setValue(imageData, forKey: "imageData")
            }
            currentNote?.setValue(noteContentCell.noteTextView.text, forKey: "content")
            DataManager.saveManagedContext()
            resignFirstResponders()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cancelNote(_ sender: UIBarButtonItem) {
        resignFirstResponders()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveNote(_ sender: UIBarButtonItem) {
        if let currentNotebook = currentNotebook, let titleText = noteTitleCell.noteTitleTextField.text {
            if titleText.trimmingCharacters(in: CharacterSet.whitespaces) != "" && resizedImage != nil {
                currentNote = Note.sharedInstance().insertNoteInNotebook(currentNotebook, title: titleText, content: noteContentCell.noteTextView.text)
                
                if let resizedImage = resizedImage, let imageData = UIImageJPEGRepresentation(resizedImage, 1.0) {
                    currentNote?.photo = Photo.sharedInstance().insertPhotoInNote(currentNote!, imageData: imageData)
                }
                resignFirstResponders()
                dismiss(animated: true, completion: nil)
            } else { presentAlertForTitle("Warning", message: "Please enter a title and add a photo for your note.") }
        }
    }
    
    // MARK: - Helpers
    
    func resignFirstResponders() {
        noteTitleCell.noteTitleTextField.resignFirstResponder()
        noteContentCell.noteTextView.resignFirstResponder()
    }
    
    fileprivate func configurePopover(_ popoverPresentationController: UIPopoverPresentationController) {
        resignFirstResponders()
        popoverPresentationController.sourceRect = notePhotoCell.noteImageView.frame //noteImageView.frame
        popoverPresentationController.sourceView = self.view
        popoverPresentationController.permittedArrowDirections = .any
    }
    
    // MARK: - Gesture Recognizer
    
    func addTapGestureRecognizer() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapGesture.delegate = self
        notePhotoCell.noteImageView.addGestureRecognizer(tapGesture)
    }
    
    func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        presentImageActionSheet()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            resizedImage = resizeImage(selectedImage)
            
            notePhotoCell.notePhotoLabel.isHidden = true
            notePhotoCell.noteImageView.image = resizedImage
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Resize image
    
    fileprivate func resizeImage(_ image: UIImage) -> UIImage {
        let aspectRatio: CGSize = image.size
        let boundingRect: CGRect = CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0)
        
        let resizedFrame: CGRect = AVMakeRect(aspectRatio: aspectRatio, insideRect: boundingRect)
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(resizedFrame.size, !hasAlpha, scale)
        
        let rect = CGRect(origin: CGPoint.zero, size: resizedFrame.size)
        UIRectClip(rect)
        image.draw(in: rect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).row {
        case 0:
            noteTitleCell = tableView.dequeueReusableCell(withIdentifier: noteTitleCellIdentifier, for: indexPath) as! NoteTitleTableViewCell
            noteTitleCell.noteTitleTextField.delegate = self
            
            if let currentNote = currentNote {
                noteTitleCell.noteTitleTextField.text = currentNote.title
            }
            
            return noteTitleCell
        case 1:
            notePhotoCell = tableView.dequeueReusableCell(withIdentifier: notePhotoCellIdentifier, for: indexPath) as! NotePhotoTableViewCell
            
            if let currentNote = currentNote, let photo = currentNote.photo, let image = UIImage(data: photo.imageData! as Data) {
                notePhotoCell.noteImageView.image = image
                notePhotoCell.notePhotoLabel.isHidden = true
            }
            
            notePhotoCell.noteImageView.isUserInteractionEnabled = true
            addTapGestureRecognizer()
            
            return notePhotoCell
        case 2:
            noteContentCell = tableView.dequeueReusableCell(withIdentifier: noteContentCellIdentifier, for: indexPath) as! NoteContentTableViewCell
            noteContentCell.noteTextView.textContainerInset = UIEdgeInsets.zero
            noteContentCell.noteTextView.delegate = self
            
            if let currentNote = currentNote {
                noteContentCell.noteTextView.text = currentNote.content
            } else {
                noteContentCell.noteTextView.text = "Enter text"
            }
            
            return noteContentCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard (indexPath as NSIndexPath).row == 1 else { return UITableViewAutomaticDimension }
        return 200.0
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        // Code from http://candycode.io/self-sizing-uitextview-in-a-uitableview-using-auto-layout-like-reminders-app/
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: false)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter text"  {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Enter text"
        }
    }
    
    // MARK: - UIAlertController
    
    func presentImageActionSheet() {
        let alertController = UIAlertController(title: "Add Photo", message: "", preferredStyle: .actionSheet)
        
        let cancelButtonTitle = "Cancel"
        let cameraButtonTitle = "Camera"
        let photoLibraryButtonTitle = "Photo Library"
        let flickrPhotoButtonTitle = "Flickr Search"
        
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            
        }
        
        let cameraAction = UIAlertAction(title: cameraButtonTitle, style: .default) { action in
            self.configurePicker(.camera)
        }
        
        let photoLibraryAction = UIAlertAction(title: photoLibraryButtonTitle, style: .default) { action in
            self.configurePicker(.photoLibrary)
        }
        
        let flickrPhotoAction = UIAlertAction(title: flickrPhotoButtonTitle, style: .default) { action in
            self.performSegue(withIdentifier: StoryboardSegue.kSegueToFlickr, sender: self)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) { alertController.addAction(cameraAction) }
        alertController.addAction(cancelAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(flickrPhotoAction)
        
        // Configure popover for iPad
        if let popoverPresentationController = alertController.popoverPresentationController {
            configurePopover(popoverPresentationController)
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func configurePicker(_ sourceType: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        AppDelegate().setNavigationBarColors(imagePickerController.navigationController)
        
        // Configure popover for Photo Library on iPad
        if imagePickerController.sourceType == .photoLibrary { imagePickerController.modalPresentationStyle = .popover }
        if let popoverPresentationController = imagePickerController.popoverPresentationController {
            configurePopover(popoverPresentationController)
        }
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - FlickrViewControllerDelegate
    
    func selectedImagePath(_ path: String) {
        if let imageURL = URL(string: path), let imageData = try? Data(contentsOf: imageURL) {
            notePhotoCell.noteImageView.image = UIImage(data: imageData)
            resizedImage = notePhotoCell.noteImageView.image
            notePhotoCell.notePhotoLabel.isHidden = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    fileprivate struct StoryboardSegue {
        static let kSegueToFlickr = "segueToFlickr"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.kSegueToFlickr {
            if let destination = segue.destination as? UINavigationController, let flickrVC = destination.topViewController as? FlickrViewController {
                flickrVC.delegate = self
            }
        }
    }

}
