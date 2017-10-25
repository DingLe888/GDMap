#
# Be sure to run `pod lib lint GDMap.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GDMap'
  s.version          = '1.0.0'
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

  s.resource = 'Resources/*'

  s.frameworks = 'GLKit','OpenGLES','CoreGraphics','QuartzCore','CoreLocation','CoreTelephony','SystemConfiguration','Security','AdSupport','JavaScriptCore','UIKit','Foundation'

  s.libraries = 'z','stdc++.6.0.9','c++'

  s.vendored_frameworks = 'Frameworks/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
