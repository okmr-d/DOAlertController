//
//  DOAlertController.swift
//  DOAlertController
//
//  Created by Daiki Okumura on 2014/12/30.
//  Copyright (c) 2014 Daiki Okumura. All rights reserved.
//
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php
//

import Foundation
import UIKit

let DOAlertActionChangeEnabledProperty = "DOAlertActionChangeEnabledProperty"

enum DOAlertActionStyle : Int {
    case Default
    case Cancel
    case Destructive
}

enum DOAlertControllerStyle : Int {
    case ActionSheet
    case Alert
}

class DOAlertAction : NSObject, NSCopying {
    var title: String
    var style: DOAlertActionStyle
    var handler: ((DOAlertAction!) -> Void)!
    var enabled: Bool {
        didSet {
            if (oldValue != enabled) {
                NSNotificationCenter.defaultCenter().postNotificationName(DOAlertActionChangeEnabledProperty, object: nil)
            }
        }
    }
    
    required init(title: String, style: DOAlertActionStyle, handler: ((DOAlertAction!) -> Void)!) {
        self.title = title
        self.style = style
        self.handler = handler
        self.enabled = true
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType(title: self.title, style: self.style, handler: self.handler)
        copy.enabled = self.enabled
        return copy
    }
}

class DOAlertAnimation : NSObject, UIViewControllerAnimatedTransitioning {

    let isPresenting: Bool
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if(self.isPresenting){
            self.executePresentingAnimation(transitionContext)
        } else {
            self.executeDismissingAnimation(transitionContext)
        }
    }
    
    func executePresentingAnimation(transitionContext: UIViewControllerContextTransitioning) {
    
        var screenSize: CGSize = UIScreen.mainScreen().bounds.size
        let verStr = UIDevice.currentDevice().systemVersion as NSString
        let ver = verStr.floatValue
        if (ver < 8.0) {
            if (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)) {
                screenSize = CGSize(width:screenSize.height, height:screenSize.width)
            }
        }
        var containerView = transitionContext.containerView()
    
        var toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        toViewController.view.frame = CGRectMake(0.0, 0.0, screenSize.width, screenSize.height)
        toViewController.view.alpha = 0.0
        if (toViewController is DOAlertController) {
            var alertController = toViewController as! DOAlertController
            if (alertController.preferredStyle == DOAlertControllerStyle.Alert) {
                alertController.alertView.center = alertController.view.center
                alertController.alertView.transform = CGAffineTransformMakeScale(0.5, 0.5)
            }
        }
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext),
            animations: {
                toViewController.view.alpha = 1.0
                if let alertController = toViewController as? DOAlertController {
                    if (alertController.preferredStyle == DOAlertControllerStyle.Alert) {
                        alertController.alertView.transform = CGAffineTransformMakeScale(1.05, 1.05)
                    }
                }
            },
            completion: { finished in
                
                UIView.animateWithDuration(0.2,
                    animations: {
                        if let alertController = toViewController as? DOAlertController {
                            alertController.alertView.transform = CGAffineTransformIdentity
                        }
                    },
                    completion: { (finished) -> Void in
                        if (finished) {
                            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                        }
                    })
            })
    }
    
    func executeDismissingAnimation(transitionContext: UIViewControllerContextTransitioning) {
        
        var screenSize: CGSize = UIScreen.mainScreen().bounds.size
        let verStr = UIDevice.currentDevice().systemVersion as NSString
        let ver = verStr.floatValue
        if (ver < 8.0) {
            if (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)) {
                screenSize = CGSize(width:screenSize.height, height:screenSize.width)
            }
        }
        var containerView = transitionContext.containerView()
        
        var toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        var fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        toViewController.view.frame = CGRectMake(0.0, 0.0, screenSize.width, screenSize.height)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext),
            animations: {
                fromViewController.view.alpha = 0.0
            },
            completion: { (finished) -> Void in
                if (finished) {
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                }
            })
    }
}

class DOAlertController : UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate {
    
    // Message
    var message: String?
    // AlertController Style
    private(set) var preferredStyle: DOAlertControllerStyle?
    
    // Overlay Color
    var overlayColor = UIColor(red:0, green:0, blue:0, alpha:0.7)
    
    // AlertView
    private var alertView = UIView()
    var alertViewBgColor = UIColor(red:239/255, green:240/255, blue:242/255, alpha:1.0)
    
    // TitleLabel
    private var titleLabel = UILabel()
    var titleFont = UIFont(name: "HelveticaNeue-Bold", size: 18)
    var titleTextColor = UIColor(red:77/255, green:77/255, blue:77/255, alpha:1.0)
    
    // MessageView
    private var messageView = UITextView()
    var messageFont = UIFont(name: "HelveticaNeue", size: 15)
    var messageTextColor = UIColor(red:77/255, green:77/255, blue:77/255, alpha:1.0)
    
    // TextFields
    private(set) var textFields: [AnyObject]?
    
    // Actions
    private(set) var actions: [AnyObject] = []
    
    // Buttons
    private var buttons = [UIButton]()
    var buttonFont = UIFont(name: "HelveticaNeue-Bold", size: 16)
    var buttonBgColor: [DOAlertActionStyle : UIColor] = [
        .Default : UIColor(red:52/255, green:152/255, blue:219/255, alpha:1),
        .Cancel  : UIColor(red:128/255, green:128/255, blue:128/255, alpha:1),
        .Destructive  : UIColor(red:231/255, green:76/255, blue:70/255, alpha:1)
    ]
    var buttonBgColorHighlighted: [DOAlertActionStyle : UIColor] = [
        .Default : UIColor(red:93/255, green:173/255, blue:226/255, alpha:1),
        .Cancel  : UIColor(red:145/255, green:145/255, blue:145/255, alpha:1),
        .Destructive  : UIColor(red:236/255, green:112/255, blue:99/255, alpha:1)
    ]
    
    // Initializer
    convenience init(title: String?, message: String?, preferredStyle: DOAlertControllerStyle) {
        self.init(nibName: nil, bundle: nil)
        
        self.title = title
        self.message = message
        self.preferredStyle = preferredStyle
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        
        // Overlay View
        self.view.frame = UIScreen.mainScreen().applicationFrame
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        self.view.alpha = 0
        self.view.addSubview(alertView)
        
        // Title Label
        if (title != nil && title != "") {
            titleLabel.numberOfLines = 1
            titleLabel.textAlignment = .Center
            titleLabel.text = title
            alertView.addSubview(titleLabel)
        }
        // Message View
        if (message != nil && message != "") {
            messageView.text = message
            messageView.editable = false
            messageView.textAlignment = .Center
            messageView.textContainerInset = UIEdgeInsetsZero
            messageView.textContainer.lineFragmentPadding = 0;
            alertView.addSubview(messageView)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "relaodButtonsEnabled:", name: DOAlertActionChangeEnabledProperty, object: nil)
        
        self.transitioningDelegate = self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Color Settings
        view.backgroundColor = overlayColor
        alertView.backgroundColor = alertViewBgColor
        titleLabel.textColor = titleTextColor
        messageView.backgroundColor = alertView.backgroundColor
        messageView.textColor = messageTextColor
        
        // Fonts Settings
        titleLabel.font = titleFont
        messageView.font = messageFont
        
        // Screen Size
        var screenSize = UIScreen.mainScreen().bounds.size
        
        // iOS Version < 8.0
        let verStr = UIDevice.currentDevice().systemVersion as NSString
        let ver = verStr.floatValue
        if (ver < 8.0) {
            if (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)) {
                screenSize = CGSize(width:screenSize.height, height:screenSize.width)
            }
        }
        
        // OverlayView
        self.view.frame.size = screenSize
        
        // AlertView
        let alertViewPadding: CGFloat = 15.0
        let alertViewWidth: CGFloat = 270.0
        
        let innerContentWidth = alertViewWidth - alertViewPadding * 2
        var y = alertViewPadding
        
        // TitleLabel
        let titleLabelHeight: CGFloat = (title == nil || title!.isEmpty) ? 0.0 : 20.0
        if (titleLabelHeight > 0.0) {
            titleLabel.frame = CGRect(x: alertViewPadding, y: y, width: innerContentWidth, height: titleLabelHeight)
            y += titleLabelHeight + alertViewPadding
        }
        
        // MessageView
        if (message != nil && message != "") {
            var messageViewHeight: CGFloat = 0.0
            
            // Adjust text view size, if necessary
            let nsstr = message! as NSString
            let attr = [NSFontAttributeName: messageView.font]
            let messageViewSize = CGSize(width: innerContentWidth, height: messageViewHeight)
            let rect = nsstr.boundingRectWithSize(messageViewSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:attr, context:nil)
            messageViewHeight = ceil(rect.size.height)
            messageView.frame = CGRect(x: alertViewPadding, y: y, width: innerContentWidth, height: messageViewHeight)
            y += messageViewHeight + alertViewPadding
        }
        
        // TextFields
        if (self.textFields != nil && self.textFields!.count > 0) {
            let textFieldHeight: CGFloat = 30.0
            for (i, obj) in enumerate(self.textFields!) {
                let textField = obj as! UITextField
                textField.frame = CGRect(x: alertViewPadding, y: y, width: innerContentWidth, height: textFieldHeight)
                self.alertView.addSubview(textField)
                y += textFieldHeight
            }
            y += alertViewPadding
        }

        // Buttons
        let buttonHeight: CGFloat = 44.0
        let buttonMargin: CGFloat = 10.0
        for btn in buttons {
            btn.frame = CGRect(x: alertViewPadding, y: y, width: innerContentWidth, height: buttonHeight)
            y += buttonHeight + buttonMargin
            
            btn.titleLabel?.font = buttonFont
        }
        
        // AlertView frame
        let alertViewHeight = y - buttonMargin + alertViewPadding
        var x = (screenSize.width - alertViewWidth) / 2
        y = (screenSize.height - alertViewHeight) / 2
        alertView.frame = CGRect(x: x, y: y, width: alertViewWidth, height: alertViewHeight)
    }
    
    // Button Tapped Action
    func buttonTapped(sender: UIButton) {
        let action = self.actions[sender.tag - 1] as! DOAlertAction
        if (action.handler != nil) {
            action.handler(action)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // UIColor -> UIImage
    func createImageFromUIColor(var color: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let contextRef: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(contextRef, color.CGColor)
        CGContextFillRect(contextRef, rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    @objc func relaodButtonsEnabled(notification: NSNotification?) {
        for i in 0..<buttons.count {
            buttons[i].enabled = actions[i].enabled
        }
    }
    
    // MARK: DOAlertController Public Methods
    
    // Attaches an action object to the alert or action sheet.
    func addAction(action: DOAlertAction) {
        // Error
        if (action.style == DOAlertActionStyle.Cancel) {
            for ac in actions as! [DOAlertAction] {
                if (ac.style == DOAlertActionStyle.Cancel) {
                    var error: NSError?
                    NSException.raise("NSInternalInconsistencyException", format:"DOAlertController can only have one action with a style of DOAlertActionStyleCancel", arguments:getVaList([error ?? "nil"]))
                    return
                }
            }
        }
        // Add Action
        actions.append(action)
        
        // Add Button
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setTitle(action.title, forState: .Normal)
        button.enabled = action.enabled
        button.layer.cornerRadius = 4.0
        button.addTarget(self, action: Selector("buttonTapped:"), forControlEvents: .TouchUpInside)
        alertView.addSubview(button)
        buttons.append(button)
        button.tag = buttons.count
        button.setBackgroundImage(createImageFromUIColor(buttonBgColor[action.style]!), forState: UIControlState.Normal)
        button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), forState: UIControlState.Highlighted)
    }
    
    // Adds a text field to an alert.
    func addTextFieldWithConfigurationHandler(configurationHandler: ((UITextField!) -> Void)!) {
        
        // You can add a text field only if the preferredStyle property is set to DOAlertControllerStyle.Alert.
        if (self.preferredStyle == DOAlertControllerStyle.ActionSheet) {
            var error: NSError?
            NSException.raise("NSInternalInconsistencyException", format: "Text fields can only be added to an alert controller of style DOAlertControllerStyleAlert", arguments:getVaList([error ?? "nil"]))
            return
        }
        if (self.textFields == nil) {
            self.textFields = []
        }
        
        let textFieldHeight: CGFloat = 20.0
        let textFieldWidth: CGFloat = 234.0
        
        var textField = UITextField(frame: CGRectMake(0.0, 0.0, textFieldWidth, textFieldHeight))
        textField.borderStyle = UITextBorderStyle.None
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.grayColor().CGColor
        textField.delegate = self
        if ((configurationHandler) != nil) {
            configurationHandler(textField)
        }
        self.textFields!.append(textField)
    }
    
    // MARK: UITextFieldDelegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField.canResignFirstResponder()) {
            textField.resignFirstResponder()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        return true
    }
    
    // MARK: UIViewControllerTransitioningDelegate Methods
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DOAlertAnimation(isPresenting: true)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DOAlertAnimation(isPresenting: false)
    }
}
