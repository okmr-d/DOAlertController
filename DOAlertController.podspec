Pod::Spec.new do |s|
  s.name         = "DOAlertController"
  s.version      = "0.0.1"
  s.summary      = "Flat UI Alert written in Swift, which can be used as a UIAlertController. It supports from iOS7."
  s.homepage     = "https://github.com/okmr-d/DOAlertController"
  s.screenshots  = "https://raw.githubusercontent.com/okmr-d/okmr-d.github.io/master/img/DOAlertController/AlertScreenshot.png", "https://raw.githubusercontent.com/okmr-d/okmr-d.github.io/master/img/DOAlertController/ActionSheetScreenshot.png"
  s.license      = { :type => "MIT", :file => "LICENSE.txt" }
  s.author       = { "Daiki Okumura" => "daiki.okumura@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/okmr-d/DOAlertController.git", :tag => s.version.to_s }
  s.source_files = "DOAlertController/*"
  s.framework    = "UIKit"
  s.requires_arc = true
end
