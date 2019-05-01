#
# Be sure to run `pod lib lint PovioKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PovioKit'
  s.version          = '0.1.0'
  s.summary          = 'Modular cocoapods libraries collection.'
  s.swift_version    = '5.0'

  s.description      = 'PovioKit is a collection of useful tools, extensions and modules.'

  s.homepage         = 'https://github.com/poviolabs/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Povio Inc.' => 'services@poviolabs.com' }
  s.source           = { :git => 'https://github.com/poviolabs/PovioKit.git', :tag => s.version.to_s }

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
    
    sp.subspec 'ColorInterpolator' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/ColorInterpolator/**/*'
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
  
  s.subspec 'Views' do |sp|
    sp.source_files = 'PovioKit/Classes/Views/**/*'
    
    sp.subspec 'GradientView' do |cs|
      cs.source_files = 'PovioKit/Classes/Views/GradientView/**/*'
    end
  end
end
