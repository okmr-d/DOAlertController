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
    var actionMap: [[(selectedIndexPath: NSIndexPath) -> Void]] {
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
    func showSimpleAlert(_: NSIndexPath) {
        let title = "Simple Alert"
        let message = "A message should be a short, complete sentence."
        let cancelButtonTitle = "OK"
        
        let alertController = DOAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create the action.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            NSLog("The simple alert's cancel action occured.")
        }
        
        // Add the action.
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /// Show an alert with an "Okay" and "Cancel" button.
    func showOkayCancelAlert(_: NSIndexPath) {
        let title = "Okay/Cancel Alert"
        let message = "A message should be a short, complete sentence."
        let cancelButtonTitle = "Cancel"
        let otherButtonTitle = "OK"
        
        let alertCotroller = DOAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            NSLog("The \"Okay/Cancel\" alert's cancel action occured.")
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .Default) { action in
            NSLog("The \"Okay/Cancel\" alert's other action occured.")
        }
        
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        alertCotroller.addAction(otherAction)
        
        presentViewController(alertCotroller, animated: true, completion: nil)
    }
    
    /// Show an alert with two custom buttons.
    func showOtherAlert(_: NSIndexPath) {
        let title = "Other Alert"
        let message = "A message should be a short, complete sentence."
        let cancelButtonTitle = "Cancel"
        let otherButtonTitleOne = "Choice One"
        let otherButtonTitleTwo = "Choice Two"
        let destructiveButtonTitle = "Destructive"
        
        let alertController = DOAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            NSLog("The \"Other\" alert's cancel action occured.")
        }
        
        let otherButtonOneAction = DOAlertAction(title: otherButtonTitleOne, style: .Default) { action in
            NSLog("The \"Other\" alert's other button one action occured.")
        }
        
        let otherButtonTwoAction = DOAlertAction(title: otherButtonTitleTwo, style: .Default) { action in
            NSLog("The \"Other\" alert's other button two action occured.")
        }
        
        let destructiveButtonAction = DOAlertAction(title: destructiveButtonTitle, style: .Destructive) { action in
            NSLog("The \"Other\" alert's destructive button action occured.")
        }
        
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(otherButtonOneAction)
        alertController.addAction(otherButtonTwoAction)
        alertController.addAction(destructiveButtonAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /// Show a text entry alert with two custom buttons.
    func showTextEntryAlert(_: NSIndexPath) {
        let title = "Text Entry Alert"
        let message = "A message should be a short, complete sentence."
        let cancelButtonTitle = "Cancel"
        let otherButtonTitle = "OK"
        
        let alertController = DOAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Add the text field for text entry.
        alertController.addTextFieldWithConfigurationHandler { textField in
            // If you need to customize the text field, you can do so here.
        }
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            NSLog("The \"Text Entry\" alert's cancel action occured.")
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .Default) { action in
            NSLog("The \"Text Entry\" alert's other action occured.")
        }
        
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(otherAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /// Show a secure text entry alert with two custom buttons.
    func showSecureTextEntryAlert(_: NSIndexPath) {
        let title = "Secure Text Entry Alert"
        let message = "A message should be a short, complete sentence."
        let cancelButtonTitle = "Cancel"
        let otherButtonTitle = "OK"
        
        let alertController = DOAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Add the text field for the secure text entry.
        alertController.addTextFieldWithConfigurationHandler { textField in
            // Listen for changes to the text field's text so that we can toggle the current
            // action's enabled property based on whether the user has entered a sufficiently
            // secure entry.
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextFieldTextDidChangeNotification:", name: UITextFieldTextDidChangeNotification, object: textField)
            
            textField.secureTextEntry = true
        }
        
        // Stop listening for text change notifications on the text field. This closure will be called in the two action handlers.
        let removeTextFieldObserver: Void -> Void = {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: alertController.textFields!.first)
        }
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            NSLog("The \"Secure Text Entry\" alert's cancel action occured.")
            
            removeTextFieldObserver()
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .Default) { action in
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
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /// Show a custom alert.
    func showCustomAlert(_: NSIndexPath) {
        let title = "LOGIN"
        let message = "Input your ID and Password"
        let cancelButtonTitle = "Cancel"
        let otherButtonTitle = "Login"
        
        customAlertController = DOAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // OverlayView
        customAlertController.overlayColor = UIColor(red:235/255, green:245/255, blue:255/255, alpha:0.7)
        // AlertView
        customAlertController.alertViewBgColor = UIColor(red:44/255, green:62/255, blue:80/255, alpha:1)
        // Title
        customAlertController.titleFont = UIFont(name: "GillSans-Bold", size: 18.0)
        customAlertController.titleTextColor = UIColor(red:241/255, green:196/255, blue:15/255, alpha:1)
        // Message
        customAlertController.messageFont = UIFont(name: "GillSans-Italic", size: 15.0)
        customAlertController.messageTextColor = UIColor.whiteColor()
        // Cancel Button
        customAlertController.buttonFont[.Cancel] = UIFont(name: "GillSans-Bold", size: 16.0)
        // Default Button
        customAlertController.buttonFont[.Default] = UIFont(name: "GillSans-Bold", size: 16.0)
        customAlertController.buttonTextColor[.Default] = UIColor(red:44/255, green:62/255, blue:80/255, alpha:1)
        customAlertController.buttonBgColor[.Default] = UIColor(red: 46/255, green:204/255, blue:113/255, alpha:1)
        customAlertController.buttonBgColorHighlighted[.Default] = UIColor(red:64/255, green:212/255, blue:126/255, alpha:1)
        
        
        customAlertController.addTextFieldWithConfigurationHandler { textField in
            self.textField1 = textField
            textField.placeholder = "ID"
            textField.frame.size = CGSizeMake(240.0, 30.0)
            textField.font = UIFont(name: "HelveticaNeue", size: 15.0)
            textField.keyboardAppearance = UIKeyboardAppearance.Dark
            textField.returnKeyType = UIReturnKeyType.Next
            
            var label:UILabel = UILabel(frame: CGRectMake(0, 0, 50, 30))
            label.text = "ID"
            label.font = UIFont(name: "GillSans-Bold", size: 15.0)
            textField.leftView = label
            textField.leftViewMode = UITextFieldViewMode.Always
            
            textField.delegate = self
        }
        
        customAlertController.addTextFieldWithConfigurationHandler { textField in
            self.textField2 = textField
            textField.secureTextEntry = true
            textField.placeholder = "Password"
            textField.frame.size = CGSizeMake(240.0, 30.0)
            textField.font = UIFont(name: "HelveticaNeue", size: 15.0)
            textField.keyboardAppearance = UIKeyboardAppearance.Dark
            textField.returnKeyType = UIReturnKeyType.Send
            
            var label:UILabel = UILabel(frame: CGRectMake(0, 0, 50, 30))
            label.text = "PASS"
            label.font = UIFont(name: "GillSans-Bold", size: 15.0)
            textField.leftView = label
            textField.leftViewMode = UITextFieldViewMode.Always
            
            textField.delegate = self
        }
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            NSLog("The \"Custom\" alert's cancel action occured.")
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .Default) { action in
            NSLog("The \"Custom\" alert's other action occured.")
            
            let textFields = self.customAlertController.textFields as? Array<UITextField>
            if textFields != nil {
                for textField: UITextField in textFields! {
                    NSLog("  \(textField.placeholder!): \(textField.text)")
                }
            }
        }
        customAlertAction = otherAction
        
        // Add the actions.
        customAlertController.addAction(cancelAction)
        customAlertController.addAction(otherAction)
        
        presentViewController(customAlertController, animated: true, completion: nil)
    }
    
    // MARK: DOAlertControllerStyleActionSheet Style Alerts
    
    /// Show a dialog with an "Okay" and "Cancel" button.
    func showOkayCancelActionSheet(selectedIndexPath: NSIndexPath) {
        let cancelButtonTitle = "Cancel"
        let destructiveButtonTitle = "OK"
        
        let alertController = DOAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            NSLog("The \"Okay/Cancel\" alert action sheet's cancel action occured.")
        }
        
        let destructiveAction = DOAlertAction(title: destructiveButtonTitle, style: .Destructive) { action in
            NSLog("The \"Okay/Cancel\" alert action sheet's destructive action occured.")
        }
        
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(destructiveAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /// Show a dialog with two custom buttons.
    func showOtherActionSheet(selectedIndexPath: NSIndexPath) {
        let title = "Other ActionSheet"
        let message = "A message should be a short, complete sentence."
        let destructiveButtonTitle = "Destructive Choice"
        let otherButtonTitle = "Safe Choice"
        
        let alertController = DOAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        
        // Create the actions.
        let destructiveAction = DOAlertAction(title: destructiveButtonTitle, style: .Destructive) { action in
            NSLog("The \"Other\" alert action sheet's destructive action occured.")
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .Default) { action in
            NSLog("The \"Other\" alert action sheet's other action occured.")
        }
        
        // Add the actions.
        alertController.addAction(destructiveAction)
        alertController.addAction(otherAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /// Show a custom dialog.
    func showCustomActionSheet(selectedIndexPath: NSIndexPath) {
        let title = "A Short Title is Best"
        let message = "A message should be a short, complete sentence."
        let cancelButtonTitle = "Cancel"
        let otherButtonTitle = "Save"
        let destructiveButtonTitle = "Delete"
        
        let alertController = DOAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        
        // OverlayView
        alertController.overlayColor = UIColor(red:235/255, green:245/255, blue:255/255, alpha:0.7)
        // AlertView
        alertController.alertViewBgColor = UIColor(red:44/255, green:62/255, blue:80/255, alpha:1)
        // Title
        alertController.titleFont = UIFont(name: "GillSans-Bold", size: 18.0)
        alertController.titleTextColor = UIColor(red:241/255, green:196/255, blue:15/255, alpha:1)
        // Message
        alertController.messageFont = UIFont(name: "GillSans-Italic", size: 15.0)
        alertController.messageTextColor = UIColor.whiteColor()
        // Cancel Button
        alertController.buttonFont[.Cancel] = UIFont(name: "GillSans-Bold", size: 16.0)
        // Other Button
        alertController.buttonFont[.Default] = UIFont(name: "GillSans-Bold", size: 16.0)
        // Default Button
        alertController.buttonFont[.Destructive] = UIFont(name: "GillSans-Bold", size: 16.0)
        alertController.buttonBgColor[.Destructive] = UIColor(red: 192/255, green:57/255, blue:43/255, alpha:1)
        alertController.buttonBgColorHighlighted[.Destructive] = UIColor(red:209/255, green:66/255, blue:51/255, alpha:1)
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            NSLog("The \"Custom\" alert action sheet's cancel action occured.")
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .Default) { action in
            NSLog("The \"Custom\" alert action sheet's other action occured.")
        }
        
        let destructiveAction = DOAlertAction(title: destructiveButtonTitle, style: .Destructive) { action in
            NSLog("The \"Custom\" alert action sheet's destructive action occured.")
        }
        
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(otherAction)
        alertController.addAction(destructiveAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: UITextFieldTextDidChangeNotification
    
    func handleTextFieldTextDidChangeNotification(notification: NSNotification) {
        let textField = notification.object as! UITextField
        
        // Enforce a minimum length of >= 5 characters for secure text alerts.
        secureTextAlertAction!.enabled = count(textField.text) >= 5
    }
    
    // MARK: UITextFieldDelegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField === textField1) {
            self.textField2?.becomeFirstResponder()
        } else if (textField === textField2) {
            customAlertAction!.handler(customAlertAction)
            self.textField2?.resignFirstResponder()
            self.customAlertController.dismissViewControllerAnimated(true, completion: nil)
        }
        return true
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let action = actionMap[indexPath.section][indexPath.row]
        
        action(selectedIndexPath: indexPath)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
