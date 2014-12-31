//
//  ViewController.swift
//  DOAlertController-DEMO
//
//  Created by Daiki Okumura on 2014/12/30.
//  Copyright (c) 2014 Daiki Okumura. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func noOptionTapped(sender: AnyObject) {
        
        var alertController = DOAlertController(title: "Title", message: nil, preferredStyle: .Alert)
        
        let okAction = DOAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: false, completion: nil)
    }

    @IBAction func withMessageTapped(sender: AnyObject) {
        
        var alertController = DOAlertController(title: "Title", message: "Message Message!", preferredStyle: .Alert)
        
        let okAction = DOAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        
        let cancelAction = DOAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: false, completion: nil)
    }
    
    @IBAction func addActionTapped(sender: AnyObject) {
        var alertController = DOAlertController(title: "Title", message: "Message Message!", preferredStyle: .Alert)
        
        let defaultAction = DOAlertAction(title: "Show Next View", style: .Default) {
            action in
            self.label.text = "-> Show Next View!"
            self.performSegueWithIdentifier("Next View", sender:self)
        }
        alertController.addAction(defaultAction)
        
        let destructiveAction = DOAlertAction(title: "Destructive", style: .Destructive) {
            action in
            self.label.text = "-> Destructive!"
        }
        alertController.addAction(destructiveAction)
        
        let cancelAction = DOAlertAction(title: "Cancel", style: .Cancel) {
            action in
            self.label.text = "-> Cancel!"
        }
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: false, completion: nil)
    }
    
    @IBAction func customDesignTapped(sender: AnyObject) {
        var alertController = DOAlertController(title: "Title", message: "Message Message!", preferredStyle: .Alert)
        
        // OverlayView
        alertController.overlayColor = UIColor(red:1, green:1, blue:1, alpha:0.7)
        // AlertView
        alertController.alertViewBgColor = UIColor(red:230/255, green:230/255, blue:230/255, alpha:1)
        // TitleLabel
        alertController.titleFont = UIFont(name: "GillSans", size: 18.0)
        alertController.titleTextColor = UIColor(red:255/255, green:0/255, blue:0/255, alpha:1)
        // MessageView
        alertController.messageFont = UIFont(name: "GillSans-Italic", size: 15.0)
        alertController.messageTextColor = UIColor(red:0/255, green:0/255, blue:255/255, alpha:1)
        // Buttons
        alertController.buttonFont = UIFont(name: "GillSans-BoldItalic", size: 16.0)
        alertController.buttonBgColor[.Default] = UIColor(red:0/255, green:0/255, blue:255/255, alpha:1)
        alertController.buttonBgColorHighlighted[.Default] = UIColor(red:0/255, green:0/255, blue:230/255, alpha:1)
        alertController.buttonBgColor[.Destructive] = UIColor(red:255/255, green:0/255, blue:0/255, alpha:1)
        alertController.buttonBgColorHighlighted[.Destructive] = UIColor(red:230/255, green:0/255, blue:0/255, alpha:1)
        alertController.buttonBgColor[.Cancel] = UIColor(red:0/255, green:255/255, blue:0/255, alpha:1)
        alertController.buttonBgColorHighlighted[.Cancel] = UIColor(red:0/255, green:230/255, blue:0/255, alpha:1)
        
        let defaultAction = DOAlertAction(title: "Default", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        let destructiveAction = DOAlertAction(title: "Destructive", style: .Destructive, handler: nil)
        alertController.addAction(destructiveAction)
        
        let cancelAction = DOAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: false, completion: nil)
    }
}

