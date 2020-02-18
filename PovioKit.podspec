Pod::Spec.new do |s|
  s.name             = 'PovioKit'
  s.version          = '0.4.0'
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
  s.default_subspecs = 'Utilities', 'Extensions', 'Views'
  s.dependency 'Alamofire', '5.0.0'

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
      cs.source_files = 'PovioKit/Classes/Utilities/Logger/**/*.swift'
    end

    us.subspec 'DispatchTimer' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/DispatchTimer/**/*.swift'
    end
    
    us.subspec 'Throttler' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/Throttler/**/*.swift'
    end
    
    us.subspec 'ColorInterpolator' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/ColorInterpolator/**/*.swift'
    end
    
    us.subspec 'PromiseKit' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/PromiseKit/**/*.swift'
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
    vs.source_files = 'PovioKit/Classes/Views/**/*.swift'
    
    vs.subspec 'GradientView' do |cs|
      cs.source_files = 'PovioKit/Classes/Views/GradientView/**/*.swift'
    end
  end
  
  s.subspec 'Networking' do |vs|
    vs.source_files = 'PovioKit/Classes/Networking/**/*.swift'
    
    vs.subspec 'AlamofireNetworkClient' do |cs|
      cs.source_files = 'PovioKit/Classes/Networking/AlamofireNetworkClient/**/*.swift'
    end
  end
end
