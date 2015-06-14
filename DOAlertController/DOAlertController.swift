//
//  DOAlertController.swift
//  DOAlertController
//
//  Created by Daiki Okumura on 2015/06/14.
//  Copyright (c) 2015 Daiki Okumura. All rights reserved.
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
        let copy = self.dynamicType(title: title, style: style, handler: handler)
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
        if (isPresenting) {
            self.presentAnimateTransition(transitionContext)
        } else {
            self.dismissAnimateTransition(transitionContext)
        }
    }
    
    func presentAnimateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        var alertController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! DOAlertController
        var containerView = transitionContext.containerView()
        
        alertController.overlayView.alpha = 0.0
        if (alertController.isAlert()) {
            alertController.alertView.alpha = 0.0
            alertController.alertView.center = alertController.view.center
            alertController.alertView.transform = CGAffineTransformMakeScale(0.5, 0.5)
        } else {
            alertController.alertView.transform = CGAffineTransformMakeTranslation(0, alertController.alertView.frame.height)
        }
        containerView.addSubview(alertController.view)
        
        UIView.animateWithDuration(0.25,
            animations: {
                alertController.overlayView.alpha = 1.0
                if (alertController.isAlert()) {
                    alertController.alertView.alpha = 1.0
                    alertController.alertView.transform = CGAffineTransformMakeScale(1.05, 1.05)
                } else {
                    let bounce = alertController.alertView.frame.height / 480 * 10.0 + 10.0
                    alertController.alertView.transform = CGAffineTransformMakeTranslation(0, -bounce)
                }
            },
            completion: { finished in
                UIView.animateWithDuration(0.2,
                    animations: {
                        alertController.alertView.transform = CGAffineTransformIdentity
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
                    alertController.alertView.alpha = 0.0
                    alertController.alertView.transform = CGAffineTransformMakeScale(0.9, 0.9)
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
    private var alertViewPadding: CGFloat = 15.0
    private var innerContentWidth: CGFloat = 240.0
    private let actionSheetBounceHeight: CGFloat = 20.0
    
    // TextAreaScrollView
    private var textAreaScrollView = UIScrollView()
    private var textAreaHeight: CGFloat = 0.0
    
    // TextAreaView
    private var textAreaView = UIView()
    
    // TextContainer
    private var textContainer = UIView()
    private var textContainerHeightConstraint: NSLayoutConstraint!
    
    // TitleLabel
    private var titleLabel = UILabel()
    var titleFont = UIFont(name: "HelveticaNeue-Bold", size: 18)
    var titleTextColor = UIColor(red:77/255, green:77/255, blue:77/255, alpha:1.0)
    
    // MessageView
    private var messageView = UILabel()
    var messageFont = UIFont(name: "HelveticaNeue", size: 15)
    var messageTextColor = UIColor(red:77/255, green:77/255, blue:77/255, alpha:1.0)
    
    // TextFieldContainerView
    private var textFieldContainerView = UIView()
    var textFieldBorderColor = UIColor(red: 203.0/255, green: 203.0/255, blue: 203.0/255, alpha: 1.0)
    
    // TextFields
    private(set) var textFields: [AnyObject]?
    private let textFieldHeight: CGFloat = 30.0
    var textFieldBgColor = UIColor.whiteColor()
    private let textFieldCornerRadius: CGFloat = 4.0
    
    // ButtonAreaScrollView
    private var buttonAreaScrollView = UIScrollView()
    private var buttonAreaScrollViewHeightConstraint: NSLayoutConstraint!
    private var buttonAreaHeight: CGFloat = 0.0
    
    // ButtonAreaView
    private var buttonAreaView = UIView()
    
    // ButtonContainer
    private var buttonContainer = UIView()
    private var buttonContainerHeightConstraint: NSLayoutConstraint!
    private let buttonHeight: CGFloat = 44.0
    private var buttonMargin: CGFloat = 10.0
    
    // Actions
    private(set) var actions: [AnyObject] = []
    
    // Buttons
    private var buttons = [UIButton]()
    var buttonFont: [DOAlertActionStyle : UIFont!] = [
        .Default : UIFont(name: "HelveticaNeue-Bold", size: 16),
        .Cancel  : UIFont(name: "HelveticaNeue-Bold", size: 16),
        .Destructive  : UIFont(name: "HelveticaNeue-Bold", size: 16)
    ]
    var buttonTextColor: [DOAlertActionStyle : UIColor] = [
        .Default : UIColor.whiteColor(),
        .Cancel  : UIColor.whiteColor(),
        .Destructive  : UIColor.whiteColor()
    ]
    var buttonBgColor: [DOAlertActionStyle : UIColor] = [
        .Default : UIColor(red:52/255, green:152/255, blue:219/255, alpha:1),
        .Cancel  : UIColor(red:127/255, green:140/255, blue:141/255, alpha:1),
        .Destructive  : UIColor(red:231/255, green:76/255, blue:60/255, alpha:1)
    ]
    var buttonBgColorHighlighted: [DOAlertActionStyle : UIColor] = [
        .Default : UIColor(red:74/255, green:163/255, blue:223/255, alpha:1),
        .Cancel  : UIColor(red:140/255, green:152/255, blue:153/255, alpha:1),
        .Destructive  : UIColor(red:234/255, green:97/255, blue:83/255, alpha:1)
    ]
    private var buttonCornerRadius: CGFloat = 4.0
    
    private var layoutFlg = false
    private var keyboardHeight: CGFloat = 0.0
    private var cancelButtonTag = 0
    
    // Initializer
    convenience init(title: String?, message: String?, preferredStyle: DOAlertControllerStyle) {
        self.init(nibName: nil, bundle: nil)
        
        self.title = title
        self.message = message
        self.preferredStyle = preferredStyle
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = UIModalPresentationStyle.Custom
        
        // NotificationCenter
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleAlertActionEnabledDidChangeNotification:", name: DOAlertActionEnabledDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
        
        // Delegate
        self.transitioningDelegate = self
        
        // Screen Size
        var screenSize = UIScreen.mainScreen().bounds.size
        if ((UIDevice.currentDevice().systemVersion as NSString).floatValue < 8.0) {
            if (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)) {
                screenSize = CGSizeMake(screenSize.height, screenSize.width)
            }
        }
        
        // variable for ActionSheet
        if (!isAlert()) {
            alertViewWidth =  screenSize.width
            alertViewPadding = 8.0
            innerContentWidth = (screenSize.height > screenSize.width) ? screenSize.width - alertViewPadding * 2 : screenSize.height - alertViewPadding * 2
            buttonMargin = 8.0
            buttonCornerRadius = 6.0
        }
        
        // self.view
        self.view.frame.size = screenSize
        
        // OverlayView
        self.view.addSubview(overlayView)
        
        // ContainerView
        self.view.addSubview(containerView)
        
        // AlertView
        containerView.addSubview(alertView)
        
        // TextAreaScrollView
        alertView.addSubview(textAreaScrollView)
        
        // TextAreaView
        textAreaScrollView.addSubview(textAreaView)
        
        // TextContainer
        textAreaView.addSubview(textContainer)
        
        // ButtonAreaScrollView
        alertView.addSubview(buttonAreaScrollView)
        
        // ButtonAreaView
        buttonAreaScrollView.addSubview(buttonAreaView)
        
        // ButtonContainer
        buttonAreaView.addSubview(buttonContainer)
        
        //------------------------------
        // Layout Constraint
        //------------------------------
        overlayView.setTranslatesAutoresizingMaskIntoConstraints(false)
        containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        alertView.setTranslatesAutoresizingMaskIntoConstraints(false)
        textAreaScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        textAreaView.setTranslatesAutoresizingMaskIntoConstraints(false)
        textContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
        buttonAreaScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        buttonAreaView.setTranslatesAutoresizingMaskIntoConstraints(false)
        buttonContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // self.view
        let overlayViewTopSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let overlayViewRightSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0.0)
        let overlayViewLeftSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let overlayViewBottomSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let containerViewTopSpaceConstraint = NSLayoutConstraint(item: containerView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let containerViewRightSpaceConstraint = NSLayoutConstraint(item: containerView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0.0)
        let containerViewLeftSpaceConstraint = NSLayoutConstraint(item: containerView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
        containerViewBottomSpaceConstraint = NSLayoutConstraint(item: containerView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        self.view.addConstraints([overlayViewTopSpaceConstraint, overlayViewRightSpaceConstraint, overlayViewLeftSpaceConstraint, overlayViewBottomSpaceConstraint, containerViewTopSpaceConstraint, containerViewRightSpaceConstraint, containerViewLeftSpaceConstraint, containerViewBottomSpaceConstraint])
        
        if (isAlert()) {
            // ContainerView
            let alertViewCenterXConstraint = NSLayoutConstraint(item: alertView, attribute: .CenterX, relatedBy: .Equal, toItem: containerView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
            let alertViewCenterYConstraint = NSLayoutConstraint(item: alertView, attribute: .CenterY, relatedBy: .Equal, toItem: containerView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
            containerView.addConstraints([alertViewCenterXConstraint, alertViewCenterYConstraint])
            
            // AlertView
            let alertViewWidthConstraint = NSLayoutConstraint(item: alertView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: alertViewWidth)
            alertViewHeightConstraint = NSLayoutConstraint(item: alertView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 1000.0)
            alertView.addConstraints([alertViewWidthConstraint, alertViewHeightConstraint])
            
        } else {
            // ContainerView
            let alertViewCenterXConstraint = NSLayoutConstraint(item: alertView, attribute: .CenterX, relatedBy: .Equal, toItem: containerView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
            let alertViewBottomSpaceConstraint = NSLayoutConstraint(item: alertView, attribute: .Bottom, relatedBy: .Equal, toItem: containerView, attribute: .Bottom, multiplier: 1.0, constant: actionSheetBounceHeight)
            let alertViewWidthConstraint = NSLayoutConstraint(item: alertView, attribute: .Width, relatedBy: .Equal, toItem: containerView, attribute: .Width, multiplier: 1.0, constant: 0.0)
            containerView.addConstraints([alertViewCenterXConstraint, alertViewBottomSpaceConstraint, alertViewWidthConstraint])
            
            // AlertView
            alertViewHeightConstraint = NSLayoutConstraint(item: alertView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 1000.0)
            alertView.addConstraint(alertViewHeightConstraint)
        }
        
        // AlertView
        let textAreaScrollViewTopSpaceConstraint = NSLayoutConstraint(item: textAreaScrollView, attribute: .Top, relatedBy: .Equal, toItem: alertView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let textAreaScrollViewRightSpaceConstraint = NSLayoutConstraint(item: textAreaScrollView, attribute: .Right, relatedBy: .Equal, toItem: alertView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        let textAreaScrollViewLeftSpaceConstraint = NSLayoutConstraint(item: textAreaScrollView, attribute: .Left, relatedBy: .Equal, toItem: alertView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let textAreaScrollViewBottomSpaceConstraint = NSLayoutConstraint(item: textAreaScrollView, attribute: .Bottom, relatedBy: .Equal, toItem: buttonAreaScrollView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let buttonAreaScrollViewRightSpaceConstraint = NSLayoutConstraint(item: buttonAreaScrollView, attribute: .Right, relatedBy: .Equal, toItem: alertView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        let buttonAreaScrollViewLeftSpaceConstraint = NSLayoutConstraint(item: buttonAreaScrollView, attribute: .Left, relatedBy: .Equal, toItem: alertView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let buttonAreaScrollViewBottomSpaceConstraint = NSLayoutConstraint(item: buttonAreaScrollView, attribute: .Bottom, relatedBy: .Equal, toItem: alertView, attribute: .Bottom, multiplier: 1.0, constant: isAlert() ? 0.0 : -actionSheetBounceHeight)
        alertView.addConstraints([textAreaScrollViewTopSpaceConstraint, textAreaScrollViewRightSpaceConstraint, textAreaScrollViewLeftSpaceConstraint, textAreaScrollViewBottomSpaceConstraint, buttonAreaScrollViewRightSpaceConstraint, buttonAreaScrollViewLeftSpaceConstraint, buttonAreaScrollViewBottomSpaceConstraint])
        
        // TextAreaScrollView
        let textAreaViewTopSpaceConstraint = NSLayoutConstraint(item: textAreaView, attribute: .Top, relatedBy: .Equal, toItem: textAreaScrollView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let textAreaViewRightSpaceConstraint = NSLayoutConstraint(item: textAreaView, attribute: .Right, relatedBy: .Equal, toItem: textAreaScrollView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        let textAreaViewLeftSpaceConstraint = NSLayoutConstraint(item: textAreaView, attribute: .Left, relatedBy: .Equal, toItem: textAreaScrollView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let textAreaViewBottomSpaceConstraint = NSLayoutConstraint(item: textAreaView, attribute: .Bottom, relatedBy: .Equal, toItem: textAreaScrollView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let textAreaViewWidthConstraint = NSLayoutConstraint(item: textAreaView, attribute: .Width, relatedBy: .Equal, toItem: textAreaScrollView, attribute: .Width, multiplier: 1.0, constant: 0.0)
        textAreaScrollView.addConstraints([textAreaViewTopSpaceConstraint, textAreaViewRightSpaceConstraint, textAreaViewLeftSpaceConstraint, textAreaViewBottomSpaceConstraint, textAreaViewWidthConstraint])
        
        // TextArea
        let textAreaViewHeightConstraint = NSLayoutConstraint(item: textAreaView, attribute: .Height, relatedBy: .Equal, toItem: textContainer, attribute: .Height, multiplier: 1.0, constant: 0.0)
        let textContainerTopSpaceConstraint = NSLayoutConstraint(item: textContainer, attribute: .Top, relatedBy: .Equal, toItem: textAreaView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let textContainerCenterXConstraint = NSLayoutConstraint(item: textContainer, attribute: .CenterX, relatedBy: .Equal, toItem: textAreaView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        textAreaView.addConstraints([textAreaViewHeightConstraint, textContainerTopSpaceConstraint, textContainerCenterXConstraint])
        
        // TextContainer
        let textContainerWidthConstraint = NSLayoutConstraint(item: textContainer, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: innerContentWidth)
        textContainerHeightConstraint = NSLayoutConstraint(item: textContainer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 0.0)
        textContainer.addConstraints([textContainerWidthConstraint, textContainerHeightConstraint])
        
        // ButtonAreaScrollView
        buttonAreaScrollViewHeightConstraint = NSLayoutConstraint(item: buttonAreaScrollView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 0.0)
        let buttonAreaViewTopSpaceConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .Top, relatedBy: .Equal, toItem: buttonAreaScrollView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let buttonAreaViewRightSpaceConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .Right, relatedBy: .Equal, toItem: buttonAreaScrollView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        let buttonAreaViewLeftSpaceConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .Left, relatedBy: .Equal, toItem: buttonAreaScrollView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let buttonAreaViewBottomSpaceConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .Bottom, relatedBy: .Equal, toItem: buttonAreaScrollView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let buttonAreaViewWidthConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .Width, relatedBy: .Equal, toItem: buttonAreaScrollView, attribute: .Width, multiplier: 1.0, constant: 0.0)
        buttonAreaScrollView.addConstraints([buttonAreaScrollViewHeightConstraint, buttonAreaViewTopSpaceConstraint, buttonAreaViewRightSpaceConstraint, buttonAreaViewLeftSpaceConstraint, buttonAreaViewBottomSpaceConstraint, buttonAreaViewWidthConstraint])
        
        // ButtonArea
        let buttonAreaViewHeightConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .Height, relatedBy: .Equal, toItem: buttonContainer, attribute: .Height, multiplier: 1.0, constant: 0.0)
        let buttonContainerTopSpaceConstraint = NSLayoutConstraint(item: buttonContainer, attribute: .Top, relatedBy: .Equal, toItem: buttonAreaView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let buttonContainerCenterXConstraint = NSLayoutConstraint(item: buttonContainer, attribute: .CenterX, relatedBy: .Equal, toItem: buttonAreaView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        buttonAreaView.addConstraints([buttonAreaViewHeightConstraint, buttonContainerTopSpaceConstraint, buttonContainerCenterXConstraint])
        
        // ButtonContainer
        let buttonContainerWidthConstraint = NSLayoutConstraint(item: buttonContainer, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: innerContentWidth)
        buttonContainerHeightConstraint = NSLayoutConstraint(item: buttonContainer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 0.0)
        buttonContainer.addConstraints([buttonContainerWidthConstraint, buttonContainerHeightConstraint])
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!isAlert() && cancelButtonTag != 0) {
            var tapGesture = UITapGestureRecognizer(target: self, action: "handleContainerViewTapGesture:")
            containerView.addGestureRecognizer(tapGesture)
        }
    }
    
    func layoutView() {
        if (layoutFlg) { return }
        layoutFlg = true
        
        //------------------------------
        // Layout & Color Settings
        //------------------------------
        overlayView.backgroundColor = overlayColor
        alertView.backgroundColor = alertViewBgColor
        
        //------------------------------
        // TextArea Layout
        //------------------------------
        let hasTitle: Bool = title != nil && title != ""
        let hasMessage: Bool = message != nil && message != ""
        let hasTextField: Bool = textFields != nil && textFields!.count > 0
        
        var textAreaPositionY: CGFloat = alertViewPadding
        if (!isAlert()) {textAreaPositionY += alertViewPadding}
        
        // TitleLabel
        if (hasTitle) {
            titleLabel.frame.size = CGSizeMake(innerContentWidth, 0.0)
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .Center
            titleLabel.font = titleFont
            titleLabel.textColor = titleTextColor
            titleLabel.text = title
            titleLabel.sizeToFit()
            titleLabel.frame = CGRectMake(0, textAreaPositionY, innerContentWidth, titleLabel.frame.height)
            textContainer.addSubview(titleLabel)
            textAreaPositionY += titleLabel.frame.height + 5.0
        }
        
        // MessageView
        if (hasMessage) {
            messageView.frame.size = CGSizeMake(innerContentWidth, 0.0)
            messageView.numberOfLines = 0
            messageView.textAlignment = .Center
            messageView.font = messageFont
            messageView.textColor = messageTextColor
            messageView.text = message
            messageView.sizeToFit()
            messageView.frame = CGRectMake(0, textAreaPositionY, innerContentWidth, messageView.frame.height)
            textContainer.addSubview(messageView)
            textAreaPositionY += messageView.frame.height + 5.0
        }
        
        // TextFieldContainerView
        if (hasTextField) {
            if (hasTitle || hasMessage) { textAreaPositionY += 5.0 }
            
            textFieldContainerView.backgroundColor = textFieldBorderColor
            textFieldContainerView.layer.masksToBounds = true
            textFieldContainerView.layer.cornerRadius = textFieldCornerRadius
            textFieldContainerView.layer.borderWidth = 0.5
            textFieldContainerView.layer.borderColor = textFieldBorderColor.CGColor
            textContainer.addSubview(textFieldContainerView)
            
            var textFieldContainerHeight: CGFloat = 0.0
            
            // TextFields
            for (i, obj) in enumerate(textFields!) {
                let textField = obj as! UITextField
                textField.frame = CGRectMake(0.0, textFieldContainerHeight, innerContentWidth, textField.frame.height)
                textFieldContainerHeight += textField.frame.height + 0.5
            }
            
            textFieldContainerHeight -= 0.5
            textFieldContainerView.frame = CGRectMake(0.0, textAreaPositionY, innerContentWidth, textFieldContainerHeight)
            textAreaPositionY += textFieldContainerHeight + 5.0
        }
        
        if (!hasTitle && !hasMessage && !hasTextField) {
            textAreaPositionY = 0.0
        }
        
        // TextAreaScrollView
        textAreaHeight = textAreaPositionY
        textAreaScrollView.contentSize = CGSizeMake(alertViewWidth, textAreaHeight)
        textContainerHeightConstraint.constant = textAreaHeight
        
        //------------------------------
        // ButtonArea Layout
        //------------------------------
        var buttonAreaPositionY: CGFloat = buttonMargin
        
        // Buttons
        if (isAlert() && buttons.count == 2) {
            let buttonWidth = (innerContentWidth - buttonMargin) / 2
            var buttonPositionX: CGFloat = 0.0
            for button in buttons {
                let action = actions[button.tag - 1] as! DOAlertAction
                button.titleLabel?.font = buttonFont[action.style]
                button.setTitleColor(buttonTextColor[action.style], forState: .Normal)
                button.setBackgroundImage(createImageFromUIColor(buttonBgColor[action.style]!), forState: .Normal)
                button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), forState: .Highlighted)
                button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), forState: .Selected)
                button.frame = CGRectMake(buttonPositionX, buttonAreaPositionY, buttonWidth, buttonHeight)
                buttonPositionX += buttonMargin + buttonWidth
            }
            buttonAreaPositionY += buttonHeight
        } else {
            for button in buttons {
                let action = actions[button.tag - 1] as! DOAlertAction
                if (action.style != DOAlertActionStyle.Cancel) {
                    button.titleLabel?.font = buttonFont[action.style]
                    button.setTitleColor(buttonTextColor[action.style], forState: .Normal)
                    button.setBackgroundImage(createImageFromUIColor(buttonBgColor[action.style]!), forState: .Normal)
                    button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), forState: .Highlighted)
                    button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), forState: .Selected)
                    button.frame = CGRectMake(0, buttonAreaPositionY, innerContentWidth, buttonHeight)
                    buttonAreaPositionY += buttonHeight + buttonMargin
                } else {
                    cancelButtonTag = button.tag
                }
            }
            
            // Cancel Button
            if (cancelButtonTag != 0) {
                if (!isAlert() && buttons.count > 1) {
                    buttonAreaPositionY += buttonMargin
                }
                var button = buttonAreaScrollView.viewWithTag(cancelButtonTag) as! UIButton
                let action = actions[cancelButtonTag - 1] as! DOAlertAction
                button.titleLabel?.font = buttonFont[action.style]
                button.setTitleColor(buttonTextColor[action.style], forState: .Normal)
                button.setBackgroundImage(createImageFromUIColor(buttonBgColor[action.style]!), forState: .Normal)
                button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), forState: .Highlighted)
                button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), forState: .Selected)
                button.frame = CGRectMake(0, buttonAreaPositionY, innerContentWidth, buttonHeight)
                buttonAreaPositionY += buttonHeight + buttonMargin
            }
            buttonAreaPositionY -= buttonMargin
        }
        buttonAreaPositionY += alertViewPadding
        
        if (buttons.count == 0) {
            buttonAreaPositionY = 0.0
        }
        
        // ButtonAreaScrollView Height
        buttonAreaHeight = buttonAreaPositionY
        buttonAreaScrollView.contentSize = CGSizeMake(alertViewWidth, buttonAreaHeight)
        buttonContainerHeightConstraint.constant = buttonAreaHeight
        
        //------------------------------
        // AlertView Layout
        //------------------------------
        // AlertView Height
        reloadAlertViewHeight()
        alertView.frame.size = CGSizeMake(alertViewWidth, alertViewHeightConstraint.constant)
    }
    
    // Reload AlertView Height
    func reloadAlertViewHeight() {
        
        var screenSize = UIScreen.mainScreen().bounds.size
        if ((UIDevice.currentDevice().systemVersion as NSString).floatValue < 8.0) {
            if (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)) {
                screenSize = CGSizeMake(screenSize.height, screenSize.width)
            }
        }
        let maxHeight = screenSize.height - keyboardHeight
        
        // for avoiding constraint error
        buttonAreaScrollViewHeightConstraint.constant = 0.0
        
        // AlertView Height Constraint
        var alertViewHeight = textAreaHeight + buttonAreaHeight
        if (alertViewHeight > maxHeight) {
            alertViewHeight = maxHeight
        }
        if (!isAlert()) {
            alertViewHeight += actionSheetBounceHeight
        }
        alertViewHeightConstraint.constant = alertViewHeight
        
        // ButtonAreaScrollView Height Constraint
        var buttonAreaScrollViewHeight = buttonAreaHeight
        if (buttonAreaScrollViewHeight > maxHeight) {
            buttonAreaScrollViewHeight = maxHeight
        }
        buttonAreaScrollViewHeightConstraint.constant = buttonAreaScrollViewHeight
    }
    
    // Button Tapped Action
    func buttonTapped(sender: UIButton) {
        sender.selected = true
        let action = actions[sender.tag - 1] as! DOAlertAction
        if (action.handler != nil) {
            action.handler(action)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Handle ContainerView tap gesture
    func handleContainerViewTapGesture(sender: AnyObject) {
        // cancel action
        let action = actions[cancelButtonTag] as! DOAlertAction
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
            var keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue().size
            if ((UIDevice.currentDevice().systemVersion as NSString).floatValue < 8.0) {
                if (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)) {
                    keyboardSize = CGSizeMake(keyboardSize.height, keyboardSize.width)
                }
            }
            keyboardHeight = keyboardSize.height
            reloadAlertViewHeight()
            containerViewBottomSpaceConstraint.constant = -keyboardHeight
            UIView.animateWithDuration(0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        keyboardHeight = 0.0
        reloadAlertViewHeight()
        containerViewBottomSpaceConstraint.constant = keyboardHeight
        UIView.animateWithDuration(0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: Public Methods
    
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
        button.layer.cornerRadius = buttonCornerRadius
        button.addTarget(self, action: Selector("buttonTapped:"), forControlEvents: .TouchUpInside)
        button.tag = buttons.count + 1
        buttons.append(button)
        buttonContainer.addSubview(button)
    }
    
    // Adds a text field to an alert.
    func addTextFieldWithConfigurationHandler(configurationHandler: ((UITextField!) -> Void)!) {
        
        // You can add a text field only if the preferredStyle property is set to DOAlertControllerStyle.Alert.
        if (!isAlert()) {
            var error: NSError?
            NSException.raise("NSInternalInconsistencyException", format: "Text fields can only be added to an alert controller of style DOAlertControllerStyleAlert", arguments:getVaList([error ?? "nil"]))
            return
        }
        if (textFields == nil) {
            textFields = []
        }
        
        var textField = UITextField()
        textField.frame.size = CGSizeMake(innerContentWidth, textFieldHeight)
        textField.borderStyle = UITextBorderStyle.None
        textField.backgroundColor = textFieldBgColor
        textField.delegate = self
        
        if ((configurationHandler) != nil) {
            configurationHandler(textField)
        }
        
        textFields!.append(textField)
        textFieldContainerView.addSubview(textField)
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
