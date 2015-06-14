# DOAlertController

Simple Alert View written in Swift, which can be used as a UIAlertController replacement.  
It supports from iOS7! It is simple and easily customizable!

![BackgroundImage](https://raw.githubusercontent.com/okmr-d/okmr-d.github.io/master/img/DOAlertController/AlertScreenshot.png) ![BackgroundImage](https://raw.githubusercontent.com/okmr-d/okmr-d.github.io/master/img/DOAlertController/ActionSheetScreenshot.png)

## Easy to use
DOAlertController can be used as a `UIAlertController`.
```swift
// Set title, message and alert style
let alertController = DOAlertController(title: "title", message: "message", preferredStyle: .Alert)

// Create the action.
let cancelAction = DOAlertAction(title: "OK", style: .Cancel) { action in
    NSLog("The simple alert's cancel action occured.")
}

// Add the action.
alertController.addAction(cancelAction)

presentViewController(alertController, animated: true, completion: nil)
```

## Customize
see DOAlertController-DEMO for details

* change Fonts
* change color (Background, View, Buttons)
* add TextField (Alert style only)

![BackgroundImage](https://raw.githubusercontent.com/okmr-d/okmr-d.github.io/master/img/DOAlertController/CustomAlert.png)
![BackgroundImage](https://raw.githubusercontent.com/okmr-d/okmr-d.github.io/master/img/DOAlertController/CustomActionSheet.png)

## Installation
DOAlertController is available through [CocoaPods](http://cocoapods.org).

To install add the following line to your Podfile:
```
pod 'DOAlertController'
```

## License
This software is released under the MIT License, see LICENSE.txt.
