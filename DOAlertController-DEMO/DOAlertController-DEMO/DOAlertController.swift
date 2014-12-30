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

enum DOAlertActionStyle : Int {
    case Default
    case Cancel
    case Destructive
}

enum DOAlertControllerStyle : Int {
    //case ActionSheet
    case Alert
}

class DOAlertAction : NSObject, NSCopying {
    var title: String
    var style: DOAlertActionStyle
    var handler: ((DOAlertAction!) -> Void)!
    var enabled: Bool
    
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

class DOAlertController : UIViewController {
    
    // スタイル
    var preferredStyle: DOAlertControllerStyle?
    
    // 背景ビュー
    var overlayBgColor = UIColor(red:0, green:0, blue:0, alpha:0.7)
    
    // アラートビュー
    private var alertView = UIView()
    private let alertViewPadding: CGFloat = 15.0
    private let alertViewWidth: CGFloat = 270.0
    var alertViewBgColor = UIColor(red:239/255, green:240/255, blue:242/255, alpha:1)
    
    // タイトルラベル
    private var titleLabel = UILabel()
    private let titleLabelHeight: CGFloat = 20.0
    var titleFont = UIFont(name: "HelveticaNeue-Bold", size: 18)
    var titleTextColor = UIColor(red:77/255, green:77/255, blue:77/255, alpha:1)
    
    // メッセージビュー
    private var messageView = UITextView()
    private var messageViewHeight: CGFloat = 0.0
    var messageFont = UIFont(name: "HelveticaNeue", size: 15)
    var messageTextColor = UIColor(red:77/255, green:77/255, blue:77/255, alpha:1)
    var message: String?
    
    // アラートビュー内のボタン
    private var buttons = [UIButton]()
    private var buttonHeight: CGFloat = 44.0
    private var buttonMargin: CGFloat = 10.0
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
    
    var actions: [DOAlertAction] = [DOAlertAction]()
    
    func addTextFieldWithConfigurationHandler(configurationHandler: ((UITextField!) -> Void)!) {
    }
    var textFields: [AnyObject]?
    
    init(title: String?, message: String?, preferredStyle: DOAlertControllerStyle) {
        super.init()
        
        self.title = title
        self.message = message
        self.preferredStyle = preferredStyle
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        
        // メインビュー
        view.frame = UIScreen.mainScreen().applicationFrame
        view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        view.alpha = 0
        view.addSubview(alertView)
        
        // アラートビュー
        //alertView.layer.cornerRadius = 5
        //alertView.layer.masksToBounds = true
        //alertView.layer.borderWidth = 0.5
        
        // タイトルラベル
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .Center
        titleLabel.text = title
        // 高さを修正
        if (title == nil || title!.isEmpty) {
            titleLabelHeight = 0
        }
        alertView.addSubview(titleLabel)
        
        // メッセージビュー
        messageView.editable = false
        messageView.textAlignment = .Center
        messageView.textContainerInset = UIEdgeInsetsZero
        messageView.textContainer.lineFragmentPadding = 0;
        alertView.addSubview(messageView)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addAction(action: DOAlertAction) {
        
        // ２つ目のキャンセルはエラー
        if (action.style == DOAlertActionStyle.Cancel) {
            for ac in actions {
                if (ac.style == DOAlertActionStyle.Cancel) {
                    var error: NSError?
                    NSException.raise("NSInternalInconsistencyException", format:"DOAlertController can only have one action with a style of DOAlertActionStyle.Cancel", arguments:getVaList([error!]))
                    return
                }
            }
        }
        
        // アクションを追加
        actions.append(action)
        
        // ビューにボタンを追加
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 色の設定
        view.backgroundColor = overlayBgColor
        alertView.backgroundColor = alertViewBgColor
        titleLabel.textColor = titleTextColor
        messageView.backgroundColor = alertView.backgroundColor
        messageView.textColor = messageTextColor
        
        // フォントの設定
        titleLabel.font = titleFont
        messageView.font = messageFont
        
        // スクリーンサイズ
        var screenSize = UIScreen.mainScreen().bounds.size
        
        // iOS8.0より前のバージョンで、デバイス回転時の幅と高さのスイッチが行われない対応
        let verStr = UIDevice.currentDevice().systemVersion as NSString
        let ver = verStr.floatValue
        if (ver < 8.0) {
            if (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)) {
                screenSize = CGSize(width:screenSize.height, height:screenSize.width)
            }
        }
        
        // メインViewのframe
        view.frame.size = screenSize
        
        // Content Viewのパーツ
        let innerContentWidth = alertViewWidth - alertViewPadding * 2
        var y = alertViewPadding
        
        // Title Labelのframe
        if (titleLabelHeight > 0.0) {
            titleLabel.frame = CGRect(x: alertViewPadding, y: y, width: innerContentWidth, height: titleLabelHeight)
            y += titleLabelHeight + alertViewPadding
        }
        
        // 高さを修正
        if (message != nil && !message!.isEmpty) {
            messageView.text = message
            // Adjust text view size, if necessary
            let nsstr = message! as NSString
            let attr = [NSFontAttributeName: messageView.font]
            let messageViewSize = CGSize(width: innerContentWidth, height: messageViewHeight)
            let rect = nsstr.boundingRectWithSize(messageViewSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:attr, context:nil)
            messageViewHeight = ceil(rect.size.height)
        }
        // Message Viewのframe
        if (messageViewHeight > 0.0) {
            messageView.frame = CGRect(x: alertViewPadding, y: y, width: innerContentWidth, height: messageViewHeight)
            y += messageViewHeight + alertViewPadding
        }
        
        // Text fields
        /*for txt in inputs {
        txt.frame = CGRect(x: padding, y: y, width: innerContentWidth, height:30)
        txt.layer.cornerRadius = 3
        y += 40
        }*/
        
        // Buttons
        for btn in buttons {
            btn.frame = CGRect(x: alertViewPadding, y: y, width: innerContentWidth, height: buttonHeight)
            y += buttonHeight + buttonMargin
            
            btn.titleLabel?.font = buttonFont
        }
        
        // Content Viewのframe
        let alertViewHeight = y - buttonMargin + alertViewPadding
        var x = (screenSize.width - alertViewWidth) / 2
        y = (screenSize.height - alertViewHeight) / 2
        alertView.frame = CGRect(x: x, y: y, width: alertViewWidth, height: alertViewHeight)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        alertView.center = view.center
        alertView.transform = CGAffineTransformMakeScale(0.5, 0.5)
        
        UIView.animateWithDuration(0.25, animations: {
            
            self.alertView.transform = CGAffineTransformMakeScale(1.05, 1.05)
            self.view.alpha = 1
            
            }, completion: { finished in
                
                UIView.animateWithDuration(0.2, animations: {
                    self.alertView.transform = CGAffineTransformIdentity
                })
        })
    }
    
    // UIColor -> UIImage 変換
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
    
    // ボタンタップ時のアクション
    func buttonTapped(sender: UIButton) {
        let action = self.actions[sender.tag - 1]
        if (action.handler != nil) {
            action.handler(action)
        }
        self.hideView()
    }
    
    // 閉じる
    func hideView() {
        UIView.animateWithDuration(0.2, animations: {
            self.view.alpha = 0
            }, completion: { finished in
                self.dismissViewControllerAnimated(false, completion: nil)
        })
    }
}
