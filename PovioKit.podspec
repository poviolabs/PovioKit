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
  s.summary          = 'PovioKit is a collection of useful tools, extensions and modules.'
  s.swift_version    = '5.0'

  s.description      = <<-DESC
PovioKit is a collection of useful tools, extensions and modules.
                       DESC

  s.homepage         = 'https://github.com/poviolabs/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Povio Inc.' => 'services@poviolabs.com' }
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
  end
end
