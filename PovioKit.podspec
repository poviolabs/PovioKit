Pod::Spec.new do |s|
  s.name             = 'PovioKit'
  s.version          = '0.2.2.2'
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
    us.source_files = 'PovioKit/Classes/Utilities/**/*'

    us.subspec 'AttributedStringBuilder' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/AttributedStringBuilder/**/*'
    end
    
    us.subspec 'StartupService' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/StartupService/**/*'
    end
    
    us.subspec 'Broadcast' do |cs|
      cs.source_files = 'PovioKit/Classes/Utilities/Broadcast/**/*'
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
  end
  
  s.subspec 'Extensions' do |es|
    es.source_files = 'PovioKit/Classes/Extensions/**/*'
    
    es.subspec 'UIKit' do |cs|
      cs.source_files = 'PovioKit/Classes/Extensions/UIKit/**/*'
    end
    
    es.subspec 'Foundation' do |cs|
      cs.source_files = 'PovioKit/Classes/Extensions/Foundation/**/*'
    end
  end
  
  s.subspec 'Views' do |vs|
    vs.source_files = 'PovioKit/Classes/Views/**/*'
    
    vs.subspec 'GradientView' do |cs|
      cs.source_files = 'PovioKit/Classes/Views/GradientView/**/*'
    end
  end
  
  s.subspec 'Networking' do |vs|
    vs.source_files = 'PovioKit/Classes/Networking/**/*'
    
    vs.subspec 'RestClient' do |cs|
      cs.source_files = 'PovioKit/Classes/Networking/RestClient/**/*'
      
      cs.subspec 'Core' do |es|
        es.source_files = 'PovioKit/Classes/Networking/RestClient/Core/*'
      end
    end
  end
end
