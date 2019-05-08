Pod::Spec.new do |s|
  s.name             = 'PovioKit'
  s.version          = '0.2.0'
  s.summary          = 'Modular cocoapods libraries collection.'
  s.swift_version    = '5.0'

  s.description      = 'PovioKit is a collection of useful tools, extensions and modules.'

  s.homepage         = 'https://github.com/poviolabs/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Povio Inc.' => 'services@poviolabs.com' }
  s.source           = { :git => 'https://github.com/poviolabs/PovioKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.source_files = 'PovioKit/Classes/**/*.swift'
  s.frameworks = 'UIKit', 'Foundation'

  s.subspec 'Utilities' do |us|
    us.source_files = 'PovioKit/Classes/Utilities/**/*.swift'

    us.subspec 'AttributedStringBuilder' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/AttributedStringBuilder/*.swift'
    end
    
    us.subspec 'StartupService' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/StartupService/*.swift'
    end
    
    us.subspec 'Broadcast' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/Broadcast/*.swift'
    end

    us.subspec 'Logger' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/Logger/**/*'
    end

    us.subspec 'DispatchTimer' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/DispatchTimer/**/*'
    end
    
    us.subspec 'Throttler' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/Throttler/**/*'
    end
    
    us.subspec 'ColorInterpolator' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/ColorInterpolator/**/*'
    end
  end
  
  s.subspec 'Extensions' do |es|
    es.source_files = 'PovioKit/Classes/Extensions/**/*.swift'
    
    es.subspec 'UIKit' do |cs|
      cs.source_files = 'PovioKit/Classes/Extensions/UIKit/*.swift'
    end
    
    es.subspec 'Foundation' do |cs|
      cs.source_files = 'PovioKit/Classes/Extensions/Foundation/*.swift'
    end
  end
  
  s.subspec 'Views' do |vs|
    vs.source_files = 'PovioKit/Classes/Views/**/*'
    
    vs.subspec 'GradientView' do |cs|
      cs.source_files = 'PovioKit/Classes/Views/GradientView/**/*'
    end
  end
end
