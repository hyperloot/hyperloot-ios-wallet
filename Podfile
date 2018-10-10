platform :ios, '10.0'
inhibit_all_warnings!
source 'https://github.com/CocoaPods/Specs.git'

def hyperloot_libs
  pod 'BigInt', '3.1.0'
  pod 'JSONRPCKit', :git=> 'https://github.com/bricklife/JSONRPCKit.git'
  pod 'KeychainSwift'
  pod 'SwiftLint'
  pod 'CryptoSwift', '0.10.0'
  pod 'TrustCore', '0.0.7'
  pod 'TrustKeystore', :git=>'https://github.com/TrustWallet/trust-keystore', :commit=>'b338faf76d62efa570bd03088ebceac4e10314da'
  pod 'SAMKeychain'
  pod 'Alamofire', '4.7.3'
  pod 'AlamofireObjectMapper', '5.1'
end


abstract_target 'CommonPods' do

  target 'HyperlootWallet' do
    use_frameworks!

    hyperloot_libs

    pod 'AlamofireImage', '3.4'
    pod 'MBProgressHUD', '1.1.0'
    pod 'QRCodeReaderViewController', '~> 4.0.2'

  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['JSONRPCKit'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
    if ['TrustKeystore'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
    target.build_configurations.each do |config|
      config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
    end
  end
end
