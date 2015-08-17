#
# Be sure to run `pod lib lint backtrack-ios-sdk.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name         = 'Backtrack-iOS-SDK'
  spec.version      = '1.0.3'
  spec.summary      = 'An SDK for Backtrack Back-End Service'
  spec.homepage     = 'https://github.com/aozisik/backtrack-ios-sdk'
  spec.author       = { 'Ahmet Ozisik' => 'ozisikahmet@gmail.com' }
  spec.source       = { :git => 'https://github.com/aozisik/backtrack-ios-sdk.git', :tag => spec.version.to_s }
  spec.platform     = :ios
  spec.ios.deployment_target = "6.0"
  spec.prepare_command = 'ruby ./Maki-Crawler/crawler.rb'
  spec.source_files = 'Backtrack-iOS-SDK/Classes/*.{h,m}'
  spec.resource_bundles = {
    'MakiBundle' => ['Backtrack-iOS-SDK/Assets/*.png']
  }
  spec.requires_arc = true
  spec.license      = { :type => 'APACHE2', :file => 'LICENSE' }
  spec.dependency 'Mapbox-iOS-SDK', '~> 1.6.0'
  spec.dependency 'AFNetworking', '~> 2.0'
  spec.dependency 'FMDB'
end