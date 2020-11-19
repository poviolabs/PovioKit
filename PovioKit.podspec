Pod::Spec.new do |s|
  s.name             = 'PovioKit'
  s.version          = '1.0.0'
  s.summary          = 'Modular cocoapods libraries collection.'
  s.swift_version    = '5.0'
  s.description      = 'PovioKit is a modular library collection, written in Swift.'
  s.homepage         = 'https://github.com/poviolabs'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Povio Inc.' => 'services@poviolabs.com' }
  s.source           = { :git => 'https://github.com/poviolabs/PovioKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.frameworks = 'UIKit', 'Foundation'
  s.default_subspecs = 'Utilities', 'Extensions', 'Views'

  s.subspec 'Utilities' do |us|
    us.subspec 'AttributedStringBuilder' do |cs|
      cs.source_files = 'Sources/Utilities/AttributedStringBuilder/*.swift'
    end
    
    us.subspec 'StartupService' do |cs|
      cs.source_files = 'Sources/Utilities/StartupService/*.swift'
    end
    
    us.subspec 'Broadcast' do |cs|
      cs.source_files = 'Sources/Utilities/Broadcast/*.swift'
    end

    us.subspec 'Logger' do |cs|
      cs.source_files = 'Sources/Utilities/Logger/**/*.swift'
    end

    us.subspec 'DispatchTimer' do |cs|
      cs.source_files = 'Sources/Utilities/DispatchTimer/**/*.swift'
    end
    
    us.subspec 'Throttler' do |cs|
      cs.source_files = 'Sources/Utilities/Throttler/**/*.swift'
    end
    
    us.subspec 'ColorInterpolator' do |cs|
      cs.source_files = 'Sources/Utilities/ColorInterpolator/**/*.swift'
    end
    
    us.subspec 'PromiseKit' do |cs|
      cs.source_files = 'Sources/Utilities/PromiseKit/**/*.swift'
    end

    us.subspec 'SignInWithApple' do |cs|
      cs.dependency 'PovioKit/Utilities/Logger'
      cs.source_files = 'Sources/Utilities/SignInWithApple/**/*.swift'
    end
    
    us.subspec 'ImageSource' do |cs|
      cs.source_files = 'Sources/Utilities/ImageSource/*.swift'
    end
  end
  
  s.subspec 'Extensions' do |es|
    es.dependency 'PovioKit/Utilities/Logger'
    
    es.subspec 'UIKit' do |cs|
      cs.source_files = 'Sources/Extensions/UIKit/*.swift'
    end
    
    es.subspec 'Foundation' do |cs|
      cs.source_files = 'Sources/Extensions/Foundation/*.swift'
    end
    
    es.subspec 'MapKit' do |cs|
      cs.source_files = 'Sources/Extensions/MapKit/*.swift'
    end
  end
  
  s.subspec 'Views' do |vs|
    vs.subspec 'GradientView' do |gvs|
      gvs.source_files = 'Sources/Views/GradientView/*.swift'
    end
    
    vs.subspec 'PaddingLabel' do |pds|
      pds.source_files = 'Sources/Views/PaddingLabel/*.swift'
    end
  end
  
  s.subspec 'Networking' do |ns|
    ns.dependency 'Alamofire', '5.4.0'
    ns.dependency 'PovioKit/Utilities/PromiseKit'
    ns.dependency 'PovioKit/Utilities/Logger'
    
    ns.subspec 'AlamofireNetworkClient' do |cs|
      cs.source_files = 'Sources/Networking/AlamofireNetworkClient/**/*.swift'
    end
  end
end
