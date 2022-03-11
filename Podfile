platform :ios, '12.0'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
inhibit_all_warnings!

# Dependencies to be included in the app and all extensions/frameworks
abstract_target 'GlobalDependencies' do
  pod 'PromiseKit'
  pod 'CryptoSwift'
  # FIXME: If https://github.com/jedisct1/swift-sodium/pull/249 gets resolved then revert this back to the standard pod
  pod 'Sodium', :git => 'https://github.com/oxen-io/session-ios-swift-sodium.git', branch: 'session-build'
  pod 'YapDatabase/SQLCipher', :git => 'https://github.com/oxen-io/session-ios-yap-database.git', branch: 'signal-release'
  
  target 'Session' do
    pod 'AFNetworking'
    pod 'Reachability'
    pod 'PureLayout', '~> 3.1.8'
    pod 'NVActivityIndicatorView'
    pod 'YYImage', git: 'https://github.com/signalapp/YYImage'
    pod 'Mantle', git: 'https://github.com/signalapp/Mantle', branch: 'signal-master'
    pod 'ZXingObjC'
  end
  
  # Dependencies to be included only in all extensions/frameworks
  abstract_target 'FrameworkAndExtensionDependencies' do
    pod 'Curve25519Kit', git: 'https://github.com/oxen-io/session-ios-curve-25519-kit.git', branch: 'session-version'
    pod 'SignalCoreKit', git: 'https://github.com/oxen-io/session-ios-core-kit', branch: 'session-version'
    
    target 'SessionNotificationServiceExtension'
    target 'SessionSnodeKit'
    
    # Dependencies that are shared across a number of extensions/frameworks but not all
    abstract_target 'ExtendedDependencies' do
      pod 'AFNetworking'
      pod 'PureLayout', '~> 3.1.8'
      pod 'Mantle', git: 'https://github.com/signalapp/Mantle', branch: 'signal-master'
      
      target 'SessionShareExtension' do
        pod 'NVActivityIndicatorView'
      end
      
      target 'SignalUtilitiesKit' do
        pod 'NVActivityIndicatorView'
        pod 'Reachability'
        pod 'SAMKeychain'
        pod 'SwiftProtobuf', '~> 1.5.0'
        pod 'YYImage', git: 'https://github.com/signalapp/YYImage'
      end
      
      target 'SessionMessagingKit' do
        pod 'Reachability'
        pod 'SAMKeychain'
        pod 'SwiftProtobuf', '~> 1.5.0'
        
        target 'SessionMessagingKitTests' do
          inherit! :complete
          
          pod 'Quick'
          # FIXME: change this back to use the latest 'Nimble' once a version newer than 9.2.1 has been released
          pod 'Nimble', :git => 'https://github.com/Quick/Nimble', :commit => 'cabe966'
        end
      end
      
      target 'SessionUtilitiesKit' do
        pod 'SAMKeychain'
        
        target 'SessionUtilitiesKitTests' do
          inherit! :complete
          
          pod 'Quick'
          # FIXME: change this back to use the latest 'Nimble' once a version newer than 9.2.1 has been released
          pod 'Nimble', :git => 'https://github.com/Quick/Nimble', :commit => 'cabe966'
        end
      end
    end
  end
end

# No dependencies for this
target 'SessionUIKit'

# Actions to perform post-install
post_install do |installer|
  enable_whole_module_optimization_for_crypto_swift(installer)
  set_minimum_deployment_target(installer)
end

def enable_whole_module_optimization_for_crypto_swift(installer)
  installer.pods_project.targets.each do |target|
    if target.name.end_with? "CryptoSwift"
      target.build_configurations.each do |config|
        config.build_settings['GCC_OPTIMIZATION_LEVEL'] = 'fast'
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-O'
      end
    end
  end
end

def set_minimum_deployment_target(installer)
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |build_configuration|
      build_configuration.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
