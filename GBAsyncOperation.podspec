#
# Be sure to run `pod lib lint GBAsyncOperation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GBAsyncOperation'
  s.version          = '0.2.1'
  s.summary          = 'Allows to create Swift Operations with asynchronous work packages'
  s.swift_version    = '4.0'

  s.description      = <<-DESC
  Framework is mainly focused on isolating the work package from the package point into a asynchronous operation subclass. By doing this calling point class is able to implement and manipulate a queue of operations.
                       DESC

  s.homepage         = 'https://github.com/aiwo/GBAsyncOperation'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Gennady Berezovsky' => 'bergencroc@gmail.com' }
  s.source           = { :git => 'https://github.com/aiwo/GBAsyncOperation.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/aiwo'

  s.ios.deployment_target = '9.0'

  s.source_files = 'GBAsyncOperation/Classes/**/*'

  # s.frameworks = 'UIKit', 'MapKit'
  
end
