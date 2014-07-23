Pod::Spec.new do |s|
  s.name         = "OTMWebView"
  s.version      = "0.0.2"
  s.summary      = "UIWebView subclass adding the missing features of a UIWebView"
  s.homepage     = "https://github.com/otium/OTMWebView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "otium" => "otium.dev@gmail.com" }
  s.social_media_url   = "http://twitter.com/otium_"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/Otium/OTMWebView.git", :tag => "0.0.2" }
  s.frameworks = "UIKit", "Foundation"
  s.requires_arc = true

  s.subspec 'Core' do |sub|
    sub.source_files = "OTMWebView/Core/*.{h,m}"
    sub.public_header_files = "OTMWebView/Core/OTMwebView.h", "OTMWebView/Core/OTMWebViewContextMenuItem.h"
    sub.resource  = "OTMWebView/Core/Resources/*.js"
  end
  s.subspec 'ProgressBar' do |sub|
    sub.source_files = "OTMWebView/ProgressBar/*.{h,m}"
    sub.public_header_files = "OTMWebView/ProgressBar/OTMWebViewProgressBar.h"
  end
end
