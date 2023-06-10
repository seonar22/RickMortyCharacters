# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

use_frameworks!
inhibit_all_warnings!

def rxPods
  pod 'RxSwift', '6.5.0'
  pod 'RxCocoa', '6.5.0'
  pod 'RxGesture', '4.0.4'
end

def rxTestPods
  pod 'RxTest', '6.5.0'
  pod 'RxBlocking', '6.5.0'
end

target 'RickMortyCharacters' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for RickMortyCharacters
  rxPods
end

target 'RickMortyCharactersTests' do
  inherit! :search_paths
  # Pods for testing
  rxTestPods
end

target 'RickMortyCharactersUITests' do
  # Pods for testing
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'No'
      config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
      config.build_settings['GCC_OPTIMIZATION_LEVEL'] = '0'
      config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
