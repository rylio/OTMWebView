Pod::Spec.new do |s|
  s.name         = "OTMWebView"
  s.version      = "0.0.1"
  s.summary      = "UIWebView subclass adding the missing features of a UIWebView"
  s.homepage     = "https://github.com/otium/OTMWebView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "otium" => "otium.dev@gmail.com" }
  s.social_media_url   = "http://twitter.com/otium_"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/Otium/OTMWebView.git", :tag => "0.0.1" }
  s.source_files  = "OTMWebView/*.{h,m}"
  s.public_header_files = "OTMWebView/OTMWebView.h", "OTMWebView/OTMWebViewContextMenuItem.h"
  s.resource  = "OTMWebView/*.js"
  s.frameworks = "UIKit", "Foundation"
  s.requires_arc = true
end
