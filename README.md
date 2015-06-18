# DOAlertController

Simple Alert View written in Swift, which can be used as a UIAlertController replacement.  
It supports from iOS7! It is simple and easily customizable!

![BackgroundImage](https://raw.githubusercontent.com/okmr-d/okmr-d.github.io/master/img/DOAlertController/Alert.gif) ![BackgroundImage](https://raw.githubusercontent.com/okmr-d/okmr-d.github.io/master/img/DOAlertController/ActionSheet.gif)

## Easy to use
DOAlertController can be used as a `UIAlertController`.
```swift
// Set title, message and alert style
let alertController = DOAlertController(title: "title", message: "message", preferredStyle: .Alert)

// Create the action.
let cancelAction = DOAlertAction(title: "Cancel", style: .Cancel, handler: nil)

// You can add plural action.
let okAction = DOAlertAction(title: "OK" style: .Default) { action in
    NSLog("OK action occured.")
}

// Add the action.
alertController.addAction(cancelAction)
alertController.addAction(okAction)

// Show alert
presentViewController(alertController, animated: true, completion: nil)
```

## Customize

* add TextField (Alert style only)
* change Fonts
* change color (Overlay, View, Text, Buttons)

![BackgroundImage](https://raw.githubusercontent.com/okmr-d/okmr-d.github.io/master/img/DOAlertController/CustomAlert.png)
![BackgroundImage](https://raw.githubusercontent.com/okmr-d/okmr-d.github.io/master/img/DOAlertController/CustomActionSheet.png)

#### Add TextField
```swift
alertController.addTextFieldWithConfigurationHandler { textField in
    // text field(UITextField) setting
    // ex) textField.placeholder = "Password"
    //     textField.secureTextEntry = true
}
```

#### Change Design
##### Overlay color
```swift
alertController.overlayColor = UIColor(red:235/255, green:245/255, blue:255/255, alpha:0.7)
```
##### Background color
```swift
alertController.alertViewBgColor = UIColor(red:44/255, green:62/255, blue:80/255, alpha:1)
```
##### Title (font, text color)
```swift
alertController.titleFont = UIFont(name: "GillSans-Bold", size: 18.0)
alertController.titleTextColor = UIColor(red:241/255, green:196/255, blue:15/255, alpha:1)
```
##### Message (font, text color)
```swift
alertController.messageFont = UIFont(name: "GillSans-Italic", size: 15.0)
alertController.messageTextColor = UIColor.whiteColor()
```
##### Button (font, text color, background color(default/highlighted))
```swift
alertController.buttonFont[.Default] = UIFont(name: "GillSans-Bold", size: 16.0)
alertController.buttonTextColor[.Default] = UIColor(red:44/255, green:62/255, blue:80/255, alpha:1)
alertController.buttonBgColor[.Default] = UIColor(red: 46/255, green:204/255, blue:113/255, alpha:1)
alertController.buttonBgColorHighlighted[.Default] = UIColor(red:64/255, green:212/255, blue:126/255, alpha:1)
// Default style : [.Default]
// Cancel style : [.Default] → [.Cancel]
// Destructive style : [.Default] → [.Destructive]
```

## Installation
DOAlertController is available through [CocoaPods](http://cocoapods.org).

To install add the following line to your Podfile:
```
pod 'DOAlertController'
```

## License
This software is released under the MIT License, see LICENSE.txt.
