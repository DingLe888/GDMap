#
# Be sure to run `pod lib lint GDMap.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GDMap'
  s.version          = '1.1.0'
  s.summary          = '集成高德SDK暴露一些方法'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/DingLe888/GDMap'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '18911755085@163.com' => '18911755085@163.com' }
  s.source           = { :git => 'https://github.com/DingLe888/GDMap.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'GDMap/Classes/**/*'
  
  # s.resource_bundles = {
  #   'GDMap' => ['GDMap/Assets/*.png']
  # }

   dir = File.dirname(__FILE__)
   dirs = '$(PODS_ROOT)/GDMap/Frameworks/AMapFoundationKit.framework/Headers'


   s.pod_target_xcconfig = { 
      'HEADER_SEARCH_PATHS' => "\"$(PODS_ROOT)/GDMap/Frameworks/AMapFoundationKit.framework/Headers\" \"$(PODS_ROOT)/GDMap/Frameworks/AMapLocationKit.framework/Headers\" \"$(PODS_ROOT)/GDMap/Frameworks/AMapNaviKit.framework/Headers\" \"$(PODS_ROOT)/GDMap/Frameworks/AMapSearchKit.framework/Headers\" \"$(PODS_ROOT)/GDMap/Frameworks/MAMapKit.framework/Headers\""


      #"\"/Users/dingle/Desktop/arena/iOS_framework/GDMap/Frameworks/AMapFoundationKit.framework/Headers\" \"/Users/dingle/Desktop/arena/iOS_framework/GDMap/Frameworks/AMapLocationKit.framework/Headers\" \"/Users/dingle/Desktop/arena/iOS_framework/GDMap/Frameworks/AMapNaviKit.framework/Headers\" \"/Users/dingle/Desktop/arena/iOS_framework/GDMap/Frameworks/AMapSearchKit.framework/Headers\" \"/Users/dingle/Desktop/arena/iOS_framework/GDMap/Frameworks/MAMapKit.framework/Headers\""
   }

  s.resource = '*.bundle','*.plist'

  s.frameworks = 'GLKit','OpenGLES','CoreGraphics','QuartzCore','CoreLocation','CoreTelephony','SystemConfiguration','Security','AdSupport','JavaScriptCore','UIKit','Foundation'

  s.libraries = 'z','stdc++.6.0.9','c++'

  s.vendored_frameworks = 'Frameworks/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
