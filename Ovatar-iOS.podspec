#
# Be sure to run `pod lib lint Ovatar-iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Ovatar-iOS'
  s.version          = '1.1'
  s.summary          = 'Ovatar is the quickest and most powerful way to enable avatar support in any app!'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Ovatar is the quickest and most powerful way to enable avatar support in any client. This Framework build in Objective C has support for both Objective C and Swift will allow you to access quick drag and drop classes to get you started in minutes, or give you more powerful high level access directly to our public API. 
  					   DESC
              

  s.homepage         = 'https://ovatar.io'
  # s.screenshots    = 'www.example.com/screenshots_1'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NorthernSpark' => 'joe@northernspark.co.uk' }
  s.source           = { :git => 'https://github.com/northernspark/Ovatar-iOS.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/@NorthernSparkUK'

  s.ios.deployment_target = '8.0'

  s.source_files = 'OOvatar*.{h,m}'
  s.public_header_files = 'OOvatar*.h'
  
  s.frameworks = 'UIKit', 'Photos', 'AVFoundation', 'SafariServices', 'ContactsUI'
  
  end