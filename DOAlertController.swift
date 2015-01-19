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
        if(self.isPresenting){
            self.presentAnimateTransition(transitionContext)
        } else {
            self.dismissAnimateTransition(transitionContext)
        }
    }
    
    func presentAnimateTransition(transitionContext: UIViewControllerContextTransitioning) {
    
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
        
        var fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        
        UIView.animateWithDuration(0.25,
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
                    completion: { finished in
                        if (finished) {
                            transitionContext.completeTransition(true)
                        }
                    })
            })
    }
    
    func dismissAnimateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
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
    
    // Overlay Color
    var overlayColor = UIColor(red:0, green:0, blue:0, alpha:0.5)
    
    // ContainerView
    private var containerView = UIView()
    private var containerViewBottomSpaceConstraint: NSLayoutConstraint!
    
    // AlertView
    private var alertView = UIView()
    var alertViewBgColor = UIColor(red:239/255, green:240/255, blue:242/255, alpha:1.0)
    private let alertViewWidth: CGFloat = 270.0
    private var alertViewHeightConstraint: NSLayoutConstraint!
    
    // TextAreaScrollView
    private var textAreaScrollView = UIScrollView()
    
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
    
    // TextAreaScrollView
    private var buttonAreaScrollView = UIScrollView()
    private var buttonAreaScrollViewHeightConstraint: NSLayoutConstraint!
    
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
        self.modalPresentationStyle = UIModalPresentationStyle.Custom
        
        // OverlayView
        self.view.frame = UIScreen.mainScreen().bounds
        //self.view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        self.view.alpha = 0
        
        // ContainerView
        self.view.addSubview(self.containerView)
        
        // AlertView
        self.containerView.addSubview(self.alertView)
        
        // textAreaScrollView
        self.alertView.addSubview(self.textAreaScrollView)
        
        // buttonAreaScrollView
        self.alertView.addSubview(self.buttonAreaScrollView)
        
        //----------------------------
        // Layout Constraint Setting
        self.containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.alertView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.textAreaScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.buttonAreaScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // ContainerView Layout Constraint
        let containerViewTopSpaceConstraint = NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0)
        let containerViewRightSpaceConstraint = NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0)
        let containerViewLeftSpaceConstraint = NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0)
        containerViewBottomSpaceConstraint = NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0)
        self.view.addConstraints([containerViewTopSpaceConstraint, containerViewRightSpaceConstraint, containerViewLeftSpaceConstraint, containerViewBottomSpaceConstraint])
        
        // AlertView Layout Constraint
        let alertViewCenterXConstraint = NSLayoutConstraint(item: self.alertView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.containerView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
        let alertViewCenterYConstraint = NSLayoutConstraint(item: self.alertView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.containerView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
        let alertViewWidthConstraint = NSLayoutConstraint(item: self.alertView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: alertViewWidth)
        alertViewHeightConstraint = NSLayoutConstraint(item: self.alertView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: alertViewWidth)
        self.containerView.addConstraints([alertViewCenterXConstraint, alertViewCenterYConstraint, alertViewWidthConstraint, alertViewHeightConstraint])
        
        // textAreaScrollView Layout Constraint
        let textAreaScrollViewTopSpaceConstraint = NSLayoutConstraint(item: self.textAreaScrollView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.alertView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0)
        let textAreaScrollViewRightSpaceConstraint = NSLayoutConstraint(item: self.textAreaScrollView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.alertView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0)
        let textAreaScrollViewLeftSpaceConstraint = NSLayoutConstraint(item: self.textAreaScrollView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.alertView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0)
        let textAreaScrollViewButtomSpaceConstraint = NSLayoutConstraint(item: self.textAreaScrollView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.buttonAreaScrollView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0)
        self.alertView.addConstraints([textAreaScrollViewTopSpaceConstraint, textAreaScrollViewRightSpaceConstraint, textAreaScrollViewLeftSpaceConstraint, textAreaScrollViewButtomSpaceConstraint])
        
        // buttonAreaScrollView Layout Constraint
        let buttonAreaScrollViewRightSpaceConstraint = NSLayoutConstraint(item: self.buttonAreaScrollView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.alertView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0)
        let buttonAreaScrollViewLeftSpaceConstraint = NSLayoutConstraint(item: self.buttonAreaScrollView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.alertView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0)
        let buttonAreaScrollViewBottomSpaceConstraint = NSLayoutConstraint(item: self.buttonAreaScrollView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.alertView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0)
        buttonAreaScrollViewHeightConstraint = NSLayoutConstraint(item: self.buttonAreaScrollView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0.0)
        self.alertView.addConstraints([buttonAreaScrollViewRightSpaceConstraint, buttonAreaScrollViewLeftSpaceConstraint, buttonAreaScrollViewBottomSpaceConstraint, buttonAreaScrollViewHeightConstraint])

        // NotificationCenter
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "alertActionEnabledDidChange:", name: DOAlertActionEnabledDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
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
        
        // Constant
        let alertViewPadding: CGFloat = 15.0
        let innerContentWidth = alertViewWidth - alertViewPadding * 2
        let textFieldHeight: CGFloat = 30.0
        let buttonHeight: CGFloat = 44.0
        let buttonMargin: CGFloat = 10.0
        
        // Color Settings
        view.backgroundColor = overlayColor
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
        // OverlayView
        self.view.frame.size = screenSize
        
        //------------------------------
        // TextArea Layout
        //------------------------------
        var textAreaY: CGFloat = alertViewPadding
        
        // TitleLabel
        if (title != nil && message != "") {
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
            textAreaY += messageView.frame.height + alertViewPadding
        }
        
        // TextFields
        if (self.textFields != nil && self.textFields!.count > 0) {
            for (i, obj) in enumerate(self.textFields!) {
                let textField = obj as! UITextField
                textField.frame = CGRect(x: alertViewPadding, y: textAreaY, width: innerContentWidth, height: textFieldHeight)
                self.textAreaScrollView.addSubview(textField)
                textAreaY += textFieldHeight
            }
            textAreaY += alertViewPadding
        }
        
        // TextAreaScrollView
        var textAreaHeight = textAreaY
        self.textAreaScrollView.contentSize = CGSize(width: alertViewWidth, height: textAreaHeight)
        
        //------------------------------
        // ButtonArea Layout
        //------------------------------
        var buttonAreaY: CGFloat = 0.0
        
        // ButtonAreaScrollView Height
        var buttonAreaHeight = CGFloat(self.buttons.count) * (buttonHeight + buttonMargin) - buttonMargin + alertViewPadding
        if (textAreaHeight + buttonAreaHeight > screenSize.height) {
            buttonAreaHeight += alertViewPadding
            buttonAreaY += alertViewPadding
        }
        self.buttonAreaScrollView.contentSize = CGSize(width: alertViewWidth, height: buttonAreaHeight)
        
        // Buttons
        for btn in buttons {
            btn.titleLabel?.font = buttonFont
            btn.frame = CGRect(x: alertViewPadding, y: buttonAreaY, width: innerContentWidth, height: buttonHeight)
            self.buttonAreaScrollView.addSubview(btn)
            buttonAreaY += buttonHeight + buttonMargin
        }
        
        //------------------------------
        // Calculate AlertView Height
        //------------------------------
        // AlertView Height
        var alertViewHeight = textAreaHeight + buttonAreaHeight
        
        // Height Calculation
        if (buttonAreaHeight > self.view.frame.height) {
            buttonAreaHeight = self.view.frame.height
        }
        if (alertViewHeight > self.view.frame.height) {
            alertViewHeight = self.view.frame.height
        }
        if (textAreaHeight > alertViewHeight - buttonAreaHeight) {
            textAreaHeight = alertViewHeight - buttonAreaHeight
        }
        
        // AlertView Height Constraint
        alertViewHeightConstraint.constant = alertViewHeight
        
        // ButtonAreaScrollView Height Constraint
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
    
    @objc func alertActionEnabledDidChange(notification: NSNotification?) {
        for i in 0..<buttons.count {
            buttons[i].enabled = actions[i].enabled
        }
    }
    func keyboardWillShow(notification: NSNotification?) {
        if let userInfo = notification?.userInfo as? [String: NSValue] {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue().size
            self.containerViewBottomSpaceConstraint.constant = -keyboardSize.height
            
            /*
            let alertViewHeight = self.alertViewHeightConstraint.constant
            let maxHeight = self.view.frame.height - keyboardSize.height
            if (alertViewHeight > maxHeight) {
                self.alertViewHeightConstraint.constant = maxHeight
            }
            */
            
            UIView.animateWithDuration(0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification?) {
        self.containerViewBottomSpaceConstraint.constant = 0.0
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
        })
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
        button.tag = buttons.count + 1
        button.setBackgroundImage(createImageFromUIColor(buttonBgColor[action.style]!), forState: UIControlState.Normal)
        button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), forState: UIControlState.Highlighted)
        buttons.append(button)
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
