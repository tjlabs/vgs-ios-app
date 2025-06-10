# Uncomment the next line to define a global platform for your project

target 'VGS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VGS
  pod 'SnapKit' 
  pod 'Then' 
  pod 'RxSwift', '~> 6.5.0'
  pod 'RxCocoa', '~> 6.5.0'
  pod 'Kingfisher', '7.10.0'
  pod 'KNSDK-UI'

  target 'VGSTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'VGSUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
