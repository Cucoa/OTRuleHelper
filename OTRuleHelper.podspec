#
# Be sure to run `pod lib lint OTRuleHelper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OTRuleHelper'
  s.version          = '0.1.3'
  s.summary          = 'Specify a rule container to convert json and data to each other.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Usually used for fast Bluetooth communication or socket communication of the transparent protoco.
                       DESC

  s.homepage         = 'https://github.com/Cucoa/OTRuleHelper'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Any' => '673921021@qq.com' }
  s.source           = { :git => 'https://github.com/Cucoa/OTRuleHelper.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.12'

  s.source_files = 'OTRuleHelper/Classes/**/*'
  
end
