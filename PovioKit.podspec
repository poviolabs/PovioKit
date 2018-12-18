#
# Be sure to run `pod lib lint PovioKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PovioKit'
  s.version          = '0.1.12'
  s.summary          = 'PovioKit is a collection of useful tools, extensions and other modules.'
  s.swift_version    = '4.2'

  s.description      = <<-DESC
PovioKit is a collection of useful tools, views, extensions and modules.
TODO add description ...
                       DESC

  s.homepage         = 'https://github.com/poviolabs/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Toni Kocjan w/ colaboration of other `PovioLabs` members' => 'toni.kocjan@poviolabs.com' }
  s.source           = { :git => 'git@github.com:poviolabs/PovioKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.source_files = 'PovioKit/Classes/**/*'
  s.frameworks = 'UIKit'
  
  # s.resource_bundles = {
  #   'PovioKit' => ['PovioKit/Assets/*.png']
  # }
  
  s.subspec 'Utilities' do |sp|
    sp.source_files = 'PovioKit/Classes/Utilities/**/*'

    sp.subspec 'AttributedStringBuilder' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/AttributedStringBuilder/**/*'
    end
    
    sp.subspec 'StartupService' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/StartupService/**/*'
    end
    
    sp.subspec 'Broadcast' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/Broadcast/**/*'
    end
    
    sp.subspec 'Throttler' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/Throttler/**/*'
    end
  end
  
  s.subspec 'Views' do |sp|
    sp.source_files = 'PovioKit/Classes/Views/**/*'
    
    sp.subspec 'GradientView' do |cs|
      cs.source_files = 'PovioKit/Classes/Views/GradientView/**/*'
    end
  end
  
  s.subspec 'Extensions' do |sp|
    sp.source_files = 'PovioKit/Classes/Extensions/**/*'
    
    sp.subspec 'UIKit' do |cs|
      cs.source_files = 'PovioKit/Classes/Extensions/UIKit/**/*'
    end
    
    sp.subspec 'Foundation' do |cs|
      cs.source_files = 'PovioKit/Classes/Extensions/Foundation/**/*'
    end
  end
  
  s.subspec 'ShareKit' do |sp|
    sp.source_files = 'PovioKit/Classes/ShareKit/**/*'
    sp.dependency 'FBSDKCoreKit', '~> 4.38.0'
    sp.dependency 'FBSDKLoginKit', '~> 4.38.0'
    sp.dependency 'FBSDKShareKit', '~> 4.38.0'
    sp.dependency 'TwitterKit', '~> 3.4.0'
  end
end
