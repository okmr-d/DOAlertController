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

let DOAlertActionEnabledDidChangeNotification = "DOAlertActionEnabledDidChangeNotification"

enum DOAlertActionStyle : Int {
    case Default
    case Cancel
    case Destructive
}

enum DOAlertControllerStyle : Int {
    case ActionSheet
    case Alert
}

// MARK: DOAlertAction Class

class DOAlertAction : NSObject, NSCopying {
    var title: String
    var style: DOAlertActionStyle
    var handler: ((DOAlertAction!) -> Void)!
    var enabled: Bool {
        didSet {
            if (oldValue != enabled) {
                NSNotificationCenter.defaultCenter().postNotificationName(DOAlertActionEnabledDidChangeNotification, object: nil)
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

// MARK: DOAlertAnimation Class

class DOAlertAnimation : NSObject, UIViewControllerAnimatedTransitioning {

    let isPresenting: Bool
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        if (isPresenting) {
            return 0.45
        } else {
            return 0.25
        }
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if (self.isPresenting) {
            self.presentAnimateTransition(transitionContext)
        } else {
            self.dismissAnimateTransition(transitionContext)
        }
    }
    
    func presentAnimateTransition(transitionContext: UIViewControllerContextTransitioning) {
        var alertController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! DOAlertController
        var fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        var containerView = transitionContext.containerView()
        containerView.insertSubview(alertController.view, belowSubview: fromViewController.view)
        
        alertController.overlayView.alpha = 0.0
        if (alertController.isAlert()) {
            alertController.containerView.alpha = 0.0
            alertController.containerView.center = alertController.view.center
            alertController.containerView.transform = CGAffineTransformMakeScale(0.5, 0.5)
        } else {
            alertController.containerView.transform = CGAffineTransformMakeTranslation(0, alertController.alertView.frame.height)
        }
        
        UIView.animateWithDuration(0.25,
            animations: {
                alertController.overlayView.alpha = 1.0
                if (alertController.isAlert()) {
                    alertController.containerView.alpha = 1.0
                    alertController.containerView.transform = CGAffineTransformMakeScale(1.05, 1.05)
                } else {
                    alertController.containerView.transform = CGAffineTransformMakeTranslation(0, -15.0)
                }
            },
            completion: { finished in
                
                UIView.animateWithDuration(0.2,
                    animations: {
                        if (alertController.isAlert()) {
                            alertController.containerView.transform = CGAffineTransformIdentity
                        } else {
                            alertController.containerView.transform = CGAffineTransformIdentity
                        }
                        
                    },
                    completion: { finished in
                        if (finished) {
                            transitionContext.completeTransition(true)
                        }
                    })
            })
    }
    
    func dismissAnimateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        var alertController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! DOAlertController
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext),
            animations: {
                alertController.overlayView.alpha = 0.0
                if (alertController.isAlert()) {
                    alertController.containerView.alpha = 0.0
                    alertController.containerView.transform = CGAffineTransformMakeScale(0.9, 0.9)
                } else {
                    alertController.containerView.transform = CGAffineTransformMakeTranslation(0, alertController.alertView.frame.height)
                }
            },
            completion: { finished in
                transitionContext.completeTransition(true)
            })
    }
}

// MARK: DOAlertController Class

class DOAlertController : UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate {
    
    // Message
    var message: String?
    // AlertController Style
    private(set) var preferredStyle: DOAlertControllerStyle?
    
    // OverlayView
    private var overlayView = UIView()
    var overlayColor = UIColor(red:0, green:0, blue:0, alpha:0.5)
    
    // ContainerView
    private var containerView = UIView()
    private var containerViewBottomSpaceConstraint: NSLayoutConstraint!
    
    // AlertView
    private var alertView = UIView()
    var alertViewBgColor = UIColor(red:239/255, green:240/255, blue:242/255, alpha:1.0)
    private var alertViewWidth: CGFloat = 270.0
    private var alertViewHeightConstraint: NSLayoutConstraint!
    
    // TextAreaScrollView
    private var textAreaScrollView = UIScrollView()
    private var textAreaHeight: CGFloat = 0.0
    
    // TitleLabel
    private var titleLabel = UILabel()
    var titleFont = UIFont(name: "HelveticaNeue-Bold", size: 18)
    var titleTextColor = UIColor(red:77/255, green:77/255, blue:77/255, alpha:1.0)
    
    // MessageView
    private var messageView = UILabel()
    var messageFont = UIFont(name: "HelveticaNeue", size: 15)
    var messageTextColor = UIColor(red:77/255, green:77/255, blue:77/255, alpha:1.0)
    
    // TextFields
    private(set) var textFields: [AnyObject]?
    
    // ButtonAreaScrollView
    private var buttonAreaScrollView = UIScrollView()
    private var buttonAreaScrollViewHeightConstraint: NSLayoutConstraint!
    private var buttonAreaHeight: CGFloat = 0.0
    
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
    
    private var layoutFlg = false
    
    // Initializer
    convenience init(title: String?, message: String?, preferredStyle: DOAlertControllerStyle) {
        self.init(nibName: nil, bundle: nil)
        
        self.title = title
        self.message = message
        self.preferredStyle = preferredStyle
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = UIModalPresentationStyle.Custom
        
        // OverlayView
        self.view.addSubview(self.overlayView)
        
        // ContainerView
        self.view.addSubview(self.containerView)
        
        // AlertView
        self.containerView.addSubview(self.alertView)
        
        // textAreaScrollView
        self.alertView.addSubview(self.textAreaScrollView)
        
        // buttonAreaScrollView
        self.alertView.addSubview(self.buttonAreaScrollView)
        
        //------------------------------
        // Layout Constraint Setting
        //------------------------------
        self.overlayView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.alertView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.textAreaScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.buttonAreaScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // OverlayView Layout Constraint
        let overlayViewTopSpaceConstraint = NSLayoutConstraint(item: self.overlayView, attribute: .Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let overlayViewRightSpaceConstraint = NSLayoutConstraint(item: self.overlayView, attribute: .Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0.0)
        let overlayViewLeftSpaceConstraint = NSLayoutConstraint(item: self.overlayView, attribute: .Left, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let overlayViewBottomSpaceConstraint = NSLayoutConstraint(item: self.overlayView, attribute: .Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        self.view.addConstraints([overlayViewTopSpaceConstraint, overlayViewRightSpaceConstraint, overlayViewLeftSpaceConstraint, overlayViewBottomSpaceConstraint])
        
        // ContainerView Layout Constraint
        let containerViewTopSpaceConstraint = NSLayoutConstraint(item: self.containerView, attribute: .Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let containerViewRightSpaceConstraint = NSLayoutConstraint(item: self.containerView, attribute: .Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0.0)
        let containerViewLeftSpaceConstraint = NSLayoutConstraint(item: self.containerView, attribute: .Left, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
        containerViewBottomSpaceConstraint = NSLayoutConstraint(item: self.containerView, attribute: .Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        self.view.addConstraints([containerViewTopSpaceConstraint, containerViewRightSpaceConstraint, containerViewLeftSpaceConstraint, containerViewBottomSpaceConstraint])
        
        // AlertView Layout Constraint
        if (isAlert()) {
            
            let alertViewCenterXConstraint = NSLayoutConstraint(item: self.alertView, attribute: .CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.containerView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
            let alertViewCenterYConstraint = NSLayoutConstraint(item: self.alertView, attribute: .CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.containerView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
            let alertViewWidthConstraint = NSLayoutConstraint(item: self.alertView, attribute: .Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: alertViewWidth)
            alertViewHeightConstraint = NSLayoutConstraint(item: self.alertView, attribute: .Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 0.0)
            self.containerView.addConstraints([alertViewCenterXConstraint, alertViewCenterYConstraint, alertViewWidthConstraint, alertViewHeightConstraint])
            
        } else {
            
            let alertViewCenterXConstraint = NSLayoutConstraint(item: self.alertView, attribute: .CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.containerView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
            let alertViewBottomSpaceConstraint = NSLayoutConstraint(item: self.alertView, attribute: .Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.containerView, attribute: .Bottom, multiplier: 1.0, constant: 15.0)
            let alertViewWidthConstraint = NSLayoutConstraint(item: self.alertView, attribute: .Width, relatedBy: NSLayoutRelation.Equal, toItem: self.containerView, attribute: .Width, multiplier: 1.0, constant: 0.0)
            alertViewHeightConstraint = NSLayoutConstraint(item: self.alertView, attribute: .Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 15.0)
            self.containerView.addConstraints([alertViewCenterXConstraint, alertViewBottomSpaceConstraint, alertViewWidthConstraint, alertViewHeightConstraint])
        }
        
        // textAreaScrollView Layout Constraint
        let textAreaScrollViewTopSpaceConstraint = NSLayoutConstraint(item: self.textAreaScrollView, attribute: .Top, relatedBy: NSLayoutRelation.Equal, toItem: self.alertView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let textAreaScrollViewRightSpaceConstraint = NSLayoutConstraint(item: self.textAreaScrollView, attribute: .Right, relatedBy: NSLayoutRelation.Equal, toItem: self.alertView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        let textAreaScrollViewLeftSpaceConstraint = NSLayoutConstraint(item: self.textAreaScrollView, attribute: .Left, relatedBy: NSLayoutRelation.Equal, toItem: self.alertView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let textAreaScrollViewBottomSpaceConstraint = NSLayoutConstraint(item: self.textAreaScrollView, attribute: .Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.buttonAreaScrollView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        self.alertView.addConstraints([textAreaScrollViewTopSpaceConstraint, textAreaScrollViewRightSpaceConstraint, textAreaScrollViewLeftSpaceConstraint, textAreaScrollViewBottomSpaceConstraint])
        
        // buttonAreaScrollView Layout Constraint
        let buttonAreaScrollViewRightSpaceConstraint = NSLayoutConstraint(item: self.buttonAreaScrollView, attribute: .Right, relatedBy: NSLayoutRelation.Equal, toItem: self.alertView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        let buttonAreaScrollViewLeftSpaceConstraint = NSLayoutConstraint(item: self.buttonAreaScrollView, attribute: .Left, relatedBy: NSLayoutRelation.Equal, toItem: self.alertView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let buttonAreaScrollViewBottomSpaceConstraint = NSLayoutConstraint(item: self.buttonAreaScrollView, attribute: .Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.alertView, attribute: .Bottom, multiplier: 1.0, constant: isAlert() ? 0.0 : -15.0)
        buttonAreaScrollViewHeightConstraint = NSLayoutConstraint(item: self.buttonAreaScrollView, attribute: .Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 0.0)
        self.alertView.addConstraints([buttonAreaScrollViewRightSpaceConstraint, buttonAreaScrollViewLeftSpaceConstraint, buttonAreaScrollViewBottomSpaceConstraint, buttonAreaScrollViewHeightConstraint])

        // NotificationCenter
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleAlertActionEnabledDidChangeNotification:", name: DOAlertActionEnabledDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDeviceOrientationDidChangeNotification:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        // Delegate
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
        layoutView()
    }
    
    func layoutView() {
        if (layoutFlg) { return }
        layoutFlg = true
        println("layoutView")
        
        //------------------------------
        // Color Settings
        //------------------------------
        overlayView.backgroundColor = overlayColor
        alertView.backgroundColor = alertViewBgColor
        titleLabel.textColor = titleTextColor
        messageView.backgroundColor = alertView.backgroundColor
        messageView.textColor = messageTextColor
        
        //------------------------------
        // Screen Size
        //------------------------------
        // Screen Size
        var screenSize = UIScreen.mainScreen().bounds.size
        if ((UIDevice.currentDevice().systemVersion as NSString).floatValue < 8.0) {
            if (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)) {
                screenSize = CGSize(width:screenSize.height, height:screenSize.width)
            }
        }
        self.view.frame.size = screenSize
        
        //------------------------------
        // Variable
        //------------------------------
        var alertViewPadding: CGFloat = 15.0
        var innerContentWidth = alertViewWidth - alertViewPadding * 2
        let textFieldHeight: CGFloat = 23.0
        let buttonHeight: CGFloat = 44.0
        var buttonMargin: CGFloat = 10.0
        
        if (!isAlert()) {
            self.alertViewWidth =  screenSize.width
            alertViewPadding = 8.0
            buttonMargin = 8.0
            
            innerContentWidth = screenSize.width
            if (innerContentWidth > screenSize.height) {
                innerContentWidth = screenSize.height
            }
            innerContentWidth -= 16.0
        }
        
        //------------------------------
        // TextArea Layout
        //------------------------------
        var textAreaY: CGFloat = alertViewPadding
        
        // TitleLabel
        if (title != nil && title != "") {
            titleLabel.frame.size = CGSize(width: innerContentWidth, height: 0.0)
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .Center
            titleLabel.font = titleFont
            titleLabel.text = title
            titleLabel.sizeToFit()
            titleLabel.frame = CGRect(x: alertViewPadding, y: textAreaY, width: innerContentWidth, height: titleLabel.frame.height)
            self.textAreaScrollView.addSubview(titleLabel)
            textAreaY += titleLabel.frame.height + 5.0
        }
        
        // MessageView
        if (message != nil && message != "") {
            messageView.frame.size = CGSize(width: innerContentWidth, height: 0.0)
            messageView.numberOfLines = 0
            messageView.textAlignment = .Center
            messageView.font = messageFont
            messageView.text = message
            messageView.sizeToFit()
            messageView.frame = CGRect(x: alertViewPadding, y: textAreaY, width: innerContentWidth, height: messageView.frame.height)
            self.textAreaScrollView.addSubview(messageView)
            textAreaY += messageView.frame.height + 5.0
        }
        
        // TextFields
        if (self.textFields != nil && self.textFields!.count > 0) {
            textAreaY += 10.0
            for (i, obj) in enumerate(self.textFields!) {
                let textField = obj as! UITextField
                textField.frame = CGRect(x: alertViewPadding, y: textAreaY, width: innerContentWidth, height: textFieldHeight)
                textAreaY += textFieldHeight
            }
            textAreaY += 5.0
        }
        
        // TextAreaScrollView
        self.textAreaHeight = textAreaY
        self.textAreaScrollView.contentSize = CGSize(width: alertViewWidth, height: textAreaHeight)
        
        //------------------------------
        // ButtonArea Layout
        //------------------------------
        var buttonAreaY: CGFloat = 10.0
        
        // ButtonAreaScrollView Height
        self.buttonAreaHeight = 10.0 + CGFloat(self.buttons.count) * (buttonHeight + buttonMargin) - buttonMargin + alertViewPadding
        if (isAlert() && self.buttons.count == 2) {
            self.buttonAreaHeight -= buttonHeight + buttonMargin
        }
        self.buttonAreaScrollView.contentSize = CGSize(width: alertViewWidth, height: buttonAreaHeight)
        
        // Buttons
        if (isAlert() && self.buttons.count == 2) {
            let buttonWidth = (innerContentWidth - buttonMargin) / 2
            var buttonX = alertViewPadding
            for button in self.buttons {
                button.titleLabel?.font = self.buttonFont
                button.frame = CGRect(x: buttonX, y: buttonAreaY, width: buttonWidth, height: buttonHeight)
                buttonX += buttonMargin + buttonWidth
            }
        } else {
            var cancelButtonTag = 0
            for button in self.buttons {
                let action = self.actions[button.tag - 1] as! DOAlertAction
                if (action.style != DOAlertActionStyle.Cancel) {
                    button.titleLabel?.font = self.buttonFont
                    button.frame = CGRect(x: alertViewPadding, y: buttonAreaY, width: innerContentWidth, height: buttonHeight)
                    buttonAreaY += buttonHeight + buttonMargin
                } else {
                    cancelButtonTag = button.tag
                }
            }
            if (cancelButtonTag != 0) {
                var button = self.buttonAreaScrollView.viewWithTag(cancelButtonTag) as! UIButton
                button.titleLabel?.font = self.buttonFont
                button.frame = CGRect(x: alertViewPadding, y: buttonAreaY, width: innerContentWidth, height: buttonHeight)
            }
        }
        
        // AlertView Height
        reloadAlertViewHeight(maxHeight: self.view.frame.height)
    }
    
    // Reload AlertView Height
    func reloadAlertViewHeight(#maxHeight: CGFloat) {
        // for avoiding constraint error
        buttonAreaScrollViewHeightConstraint.constant = 0.0
        
        // AlertView Height Constraint
        var alertViewHeight = self.textAreaHeight + self.buttonAreaHeight
        if (alertViewHeight > maxHeight) {
            alertViewHeight = maxHeight
        }
        if (!isAlert()) {
            alertViewHeight += 15.0
        }
        alertView.frame.size = CGSize(width: alertViewWidth, height: alertViewHeight)
        alertViewHeightConstraint.constant = alertViewHeight
        
        // ButtonAreaScrollView Height Constraint
        var buttonAreaHeight = self.buttonAreaHeight
        if (buttonAreaHeight > maxHeight) {
            buttonAreaHeight = maxHeight
        }
        buttonAreaScrollViewHeightConstraint.constant = buttonAreaHeight
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
    
    // MARK : Handle NSNotification Method
    
    @objc func handleAlertActionEnabledDidChangeNotification(notification: NSNotification) {
        for i in 0..<buttons.count {
            buttons[i].enabled = actions[i].enabled
        }
    }
    
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo as? [String: NSValue] {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue().size
            self.containerViewBottomSpaceConstraint.constant = -keyboardSize.height
            
            reloadAlertViewHeight(maxHeight: self.view.frame.height - keyboardSize.height)
            
            UIView.animateWithDuration(0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        self.containerViewBottomSpaceConstraint.constant = 0.0
        reloadAlertViewHeight(maxHeight: self.view.frame.height)
        
        UIView.animateWithDuration(0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func handleDeviceOrientationDidChangeNotification(notification: NSNotification){
        reloadAlertViewHeight(maxHeight: self.view.frame.height + self.containerViewBottomSpaceConstraint.constant)
        self.view.layoutIfNeeded()
    }
    
    // MARK: Public Methods
    
    // Attaches an action object to the alert or action sheet.
    func addAction(action: DOAlertAction) {
        // Error
        if (action.style == DOAlertActionStyle.Cancel) {
            for ac in self.actions as! [DOAlertAction] {
                if (ac.style == DOAlertActionStyle.Cancel) {
                    var error: NSError?
                    NSException.raise("NSInternalInconsistencyException", format:"DOAlertController can only have one action with a style of DOAlertActionStyleCancel", arguments:getVaList([error ?? "nil"]))
                    return
                }
            }
        }
        // Add Action
        self.actions.append(action)
        
        // Add Button
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setTitle(action.title, forState: .Normal)
        button.enabled = action.enabled
        button.layer.cornerRadius = isAlert() ? 4.0 : 6.0
        button.addTarget(self, action: Selector("buttonTapped:"), forControlEvents: .TouchUpInside)
        button.tag = buttons.count + 1
        button.setBackgroundImage(createImageFromUIColor(buttonBgColor[action.style]!), forState: UIControlState.Normal)
        button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), forState: UIControlState.Highlighted)
        self.buttons.append(button)
        self.buttonAreaScrollView.addSubview(button)
    }
    
    // Adds a text field to an alert.
    func addTextFieldWithConfigurationHandler(configurationHandler: ((UITextField!) -> Void)!) {
        
        // You can add a text field only if the preferredStyle property is set to DOAlertControllerStyle.Alert.
        if (!isAlert()) {
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
        self.textAreaScrollView.addSubview(textField)
    }
    
    func isAlert() -> Bool { return preferredStyle == .Alert }
    
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
        layoutView()
        return DOAlertAnimation(isPresenting: true)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DOAlertAnimation(isPresenting: false)
    }
}
