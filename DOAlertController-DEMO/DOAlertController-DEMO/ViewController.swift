//
//  ViewController.swift
//  DOAlertController-DEMO
//
//  Created by Daiki Okumura on 2014/12/30.
//  Copyright (c) 2014 Daiki Okumura. All rights reserved.
//

import UIKit

class ViewController : UITableViewController, UITextFieldDelegate {
    // MARK: Properties
    
    weak var secureTextAlertAction: DOAlertAction?
    var customAlertController: DOAlertController!
    weak var textField1: UITextField?
    weak var textField2: UITextField?
    weak var customAlertAction: DOAlertAction?
    
    // A matrix of closures that should be invoked based on which table view cell is
    // tapped (index by section, row).
    var actionMap: [[(_ selectedIndexPath: IndexPath) -> Void]] {
        return [
            // Alert style alerts.
            [
                self.showSimpleAlert,
                self.showOkayCancelAlert,
                self.showOtherAlert,
                self.showTextEntryAlert,
                self.showSecureTextEntryAlert,
                self.showCustomAlert
            ],
            // Action sheet style alerts.
            [
                self.showOkayCancelActionSheet,
                self.showOtherActionSheet,
                self.showCustomActionSheet
            ]
        ]
    }
    
    // MARK: DOAlertControllerStyleAlert Style Alerts
    
    /// Show an alert with an "Okay" button.
    func showSimpleAlert(_: IndexPath) {
        let title = "Simple Alert"
        let message = "A message should be a short, complete sentence."
        let cancelButtonTitle = "OK"
        
        let alertController = DOAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create the action.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            NSLog("The simple alert's cancel action occured.")
        }
        
        // Add the action.
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    /// Show an alert with an "Okay" and "Cancel" button.
    func showOkayCancelAlert(_: IndexPath) {
        let title = "Okay/Cancel Alert"
        let message = "A message should be a short, complete sentence."
        let cancelButtonTitle = "Cancel"
        let otherButtonTitle = "OK"
        
        let alertCotroller = DOAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            NSLog("The \"Okay/Cancel\" alert's cancel action occured.")
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .default) { action in
            NSLog("The \"Okay/Cancel\" alert's other action occured.")
        }
        
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        alertCotroller.addAction(otherAction)
        
        present(alertCotroller, animated: true, completion: nil)
    }
    
    /// Show an alert with two custom buttons.
    func showOtherAlert(_: IndexPath) {
        let title = "Other Alert"
        let message = "A message should be a short, complete sentence."
        let cancelButtonTitle = "Cancel"
        let otherButtonTitleOne = "Choice One"
        let otherButtonTitleTwo = "Choice Two"
        let destructiveButtonTitle = "Destructive"
        
        let alertController = DOAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            NSLog("The \"Other\" alert's cancel action occured.")
        }
        
        let otherButtonOneAction = DOAlertAction(title: otherButtonTitleOne, style: .default) { action in
            NSLog("The \"Other\" alert's other button one action occured.")
        }
        
        let otherButtonTwoAction = DOAlertAction(title: otherButtonTitleTwo, style: .default) { action in
            NSLog("The \"Other\" alert's other button two action occured.")
        }
        
        let destructiveButtonAction = DOAlertAction(title: destructiveButtonTitle, style: .destructive) { action in
            NSLog("The \"Other\" alert's destructive button action occured.")
        }
        
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(otherButtonOneAction)
        alertController.addAction(otherButtonTwoAction)
        alertController.addAction(destructiveButtonAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    /// Show a text entry alert with two custom buttons.
    func showTextEntryAlert(_: IndexPath) {
        let title = "Text Entry Alert"
        let message = "A message should be a short, complete sentence."
        let cancelButtonTitle = "Cancel"
        let otherButtonTitle = "OK"
        
        let alertController = DOAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add the text field for text entry.
        alertController.addTextFieldWithConfigurationHandler { textField in
            // If you need to customize the text field, you can do so here.
        }
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            NSLog("The \"Text Entry\" alert's cancel action occured.")
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .default) { action in
            NSLog("The \"Text Entry\" alert's other action occured.")
        }
        
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(otherAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    /// Show a secure text entry alert with two custom buttons.
    func showSecureTextEntryAlert(_: IndexPath) {
        let title = "Secure Text Entry Alert"
        let message = "A message should be a short, complete sentence."
        let cancelButtonTitle = "Cancel"
        let otherButtonTitle = "OK"
        
        let alertController = DOAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add the text field for the secure text entry.
        alertController.addTextFieldWithConfigurationHandler { textField in
            // Listen for changes to the text field's text so that we can toggle the current
            // action's enabled property based on whether the user has entered a sufficiently
            // secure entry.
            NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleTextFieldTextDidChangeNotification(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: textField)
            
            textField?.isSecureTextEntry = true
        }
        
        // Stop listening for text change notifications on the text field. This closure will be called in the two action handlers.
        let removeTextFieldObserver: (Void) -> Void = {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: alertController.textFields!.first)
        }
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            NSLog("The \"Secure Text Entry\" alert's cancel action occured.")
            
            removeTextFieldObserver()
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .default) { action in
            NSLog("The \"Secure Text Entry\" alert's other action occured.")
            
            removeTextFieldObserver()
        }
        
        // The text field initially has no text in the text field, so we'll disable it.
        otherAction.enabled = false
        
        // Hold onto the secure text alert action to toggle the enabled/disabled state when the text changed.
        secureTextAlertAction = otherAction
        
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(otherAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    /// Show a custom alert.
    func showCustomAlert(_: IndexPath) {
        let title = "LOGIN"
        let message = "Input your ID and Password"
        let cancelButtonTitle = "Cancel"
        let otherButtonTitle = "Login"
        
        customAlertController = DOAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OverlayView
        customAlertController.overlayColor = UIColor(red:235/255, green:245/255, blue:255/255, alpha:0.7)
        // AlertView
        customAlertController.alertViewBgColor = UIColor(red:44/255, green:62/255, blue:80/255, alpha:1)
        // Title
        customAlertController.titleFont = UIFont(name: "GillSans-Bold", size: 18.0)
        customAlertController.titleTextColor = UIColor(red:241/255, green:196/255, blue:15/255, alpha:1)
        // Message
        customAlertController.messageFont = UIFont(name: "GillSans-Italic", size: 15.0)
        customAlertController.messageTextColor = UIColor.white
        // Cancel Button
        customAlertController.buttonFont[.cancel] = UIFont(name: "GillSans-Bold", size: 16.0)
        // Default Button
        customAlertController.buttonFont[.default] = UIFont(name: "GillSans-Bold", size: 16.0)
        customAlertController.buttonTextColor[.default] = UIColor(red:44/255, green:62/255, blue:80/255, alpha:1)
        customAlertController.buttonBgColor[.default] = UIColor(red: 46/255, green:204/255, blue:113/255, alpha:1)
        customAlertController.buttonBgColorHighlighted[.default] = UIColor(red:64/255, green:212/255, blue:126/255, alpha:1)
        
        
        customAlertController.addTextFieldWithConfigurationHandler { textField in
            self.textField1 = textField
            textField?.placeholder = "ID"
            textField?.frame.size = CGSize(width: 240.0, height: 30.0)
            textField?.font = UIFont(name: "HelveticaNeue", size: 15.0)
            textField?.keyboardAppearance = UIKeyboardAppearance.dark
            textField?.returnKeyType = UIReturnKeyType.next
            
            let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
            label.text = "ID"
            label.font = UIFont(name: "GillSans-Bold", size: 15.0)
            textField?.leftView = label
            textField?.leftViewMode = UITextFieldViewMode.always
            
            textField?.delegate = self
        }
        
        customAlertController.addTextFieldWithConfigurationHandler { textField in
            self.textField2 = textField
            textField?.isSecureTextEntry = true
            textField?.placeholder = "Password"
            textField?.frame.size = CGSize(width: 240.0, height: 30.0)
            textField?.font = UIFont(name: "HelveticaNeue", size: 15.0)
            textField?.keyboardAppearance = UIKeyboardAppearance.dark
            textField?.returnKeyType = UIReturnKeyType.send
            
            let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
            label.text = "PASS"
            label.font = UIFont(name: "GillSans-Bold", size: 15.0)
            textField?.leftView = label
            textField?.leftViewMode = UITextFieldViewMode.always
            
            textField?.delegate = self
        }
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            NSLog("The \"Custom\" alert's cancel action occured.")
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .default) { action in
            NSLog("The \"Custom\" alert's other action occured.")
            
            let textFields = self.customAlertController.textFields as? Array<UITextField>
            if textFields != nil {
                for textField: UITextField in textFields! {
                    NSLog("  \(textField.placeholder!): \(String(describing: textField.text))")
                }
            }
        }
        customAlertAction = otherAction
        
        // Add the actions.
        customAlertController.addAction(cancelAction)
        customAlertController.addAction(otherAction)
        
        present(customAlertController, animated: true, completion: nil)
    }
    
    // MARK: DOAlertControllerStyleActionSheet Style Alerts
    
    /// Show a dialog with an "Okay" and "Cancel" button.
    func showOkayCancelActionSheet(_ selectedIndexPath: IndexPath) {
        let cancelButtonTitle = "Cancel"
        let destructiveButtonTitle = "OK"
        
        let alertController = DOAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            NSLog("The \"Okay/Cancel\" alert action sheet's cancel action occured.")
        }
        
        let destructiveAction = DOAlertAction(title: destructiveButtonTitle, style: .destructive) { action in
            NSLog("The \"Okay/Cancel\" alert action sheet's destructive action occured.")
        }
        
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(destructiveAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    /// Show a dialog with two custom buttons.
    func showOtherActionSheet(_ selectedIndexPath: IndexPath) {
        let title = "Other ActionSheet"
        let message = "A message should be a short, complete sentence."
        let destructiveButtonTitle = "Destructive Choice"
        let otherButtonTitle = "Safe Choice"
        
        let alertController = DOAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        // Create the actions.
        let destructiveAction = DOAlertAction(title: destructiveButtonTitle, style: .destructive) { action in
            NSLog("The \"Other\" alert action sheet's destructive action occured.")
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .default) { action in
            NSLog("The \"Other\" alert action sheet's other action occured.")
        }
        
        // Add the actions.
        alertController.addAction(destructiveAction)
        alertController.addAction(otherAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    /// Show a custom dialog.
    func showCustomActionSheet(_ selectedIndexPath: IndexPath) {
        let title = "A Short Title is Best"
        let message = "A message should be a short, complete sentence."
        let cancelButtonTitle = "Cancel"
        let otherButtonTitle = "Save"
        let destructiveButtonTitle = "Delete"
        
        let alertController = DOAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        // OverlayView
        alertController.overlayColor = UIColor(red:235/255, green:245/255, blue:255/255, alpha:0.7)
        // AlertView
        alertController.alertViewBgColor = UIColor(red:44/255, green:62/255, blue:80/255, alpha:1)
        // Title
        alertController.titleFont = UIFont(name: "GillSans-Bold", size: 18.0)
        alertController.titleTextColor = UIColor(red:241/255, green:196/255, blue:15/255, alpha:1)
        // Message
        alertController.messageFont = UIFont(name: "GillSans-Italic", size: 15.0)
        alertController.messageTextColor = UIColor.white
        // Cancel Button
        alertController.buttonFont[.cancel] = UIFont(name: "GillSans-Bold", size: 16.0)
        // Other Button
        alertController.buttonFont[.default] = UIFont(name: "GillSans-Bold", size: 16.0)
        // Default Button
        alertController.buttonFont[.destructive] = UIFont(name: "GillSans-Bold", size: 16.0)
        alertController.buttonBgColor[.destructive] = UIColor(red: 192/255, green:57/255, blue:43/255, alpha:1)
        alertController.buttonBgColorHighlighted[.destructive] = UIColor(red:209/255, green:66/255, blue:51/255, alpha:1)
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .cancel) { action in
            NSLog("The \"Custom\" alert action sheet's cancel action occured.")
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .default) { action in
            NSLog("The \"Custom\" alert action sheet's other action occured.")
        }
        
        let destructiveAction = DOAlertAction(title: destructiveButtonTitle, style: .destructive) { action in
            NSLog("The \"Custom\" alert action sheet's destructive action occured.")
        }
        
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(otherAction)
        alertController.addAction(destructiveAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: UITextFieldTextDidChangeNotification
    
    func handleTextFieldTextDidChangeNotification(_ notification: Notification) {
        let textField = notification.object as! UITextField
        
        // Enforce a minimum length of >= 5 characters for secure text alerts.
        secureTextAlertAction!.enabled = textField.text!.characters.count >= 5
    }
    
    // MARK: UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField === textField1) {
            self.textField2?.becomeFirstResponder()
        } else if (textField === textField2) {
            customAlertAction!.handler(customAlertAction)
            self.textField2?.resignFirstResponder()
            self.customAlertController.dismiss(animated: true, completion: nil)
        }
        return true
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let action = actionMap[indexPath.section][indexPath.row]
        
        action(indexPath)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
