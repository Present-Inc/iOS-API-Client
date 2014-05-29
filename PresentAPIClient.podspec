Pod::Spec.new do |s|
  s.name         = 'PresentAPIClient'
  s.version      = '0.1'
  s.license      =  :type => 'MIT'
  s.homepage     = 'http://github.com/Present-Inc/PresentAPIClient'
  s.authors      =  'Justin Makaila' => 'justin@present.tv'
  s.summary      = 'The API Client for the iOS App'
  s.platform     =  :ios, '7.0'
  s.source       =  :git => 'https://github.com/Present-Inc/PresentAPIClient.git', :tag => '0.1'
  s.source_files = 'PresentAPIClient/Controllers/*.{h,m}', 'PresentAPIClient/Models/*.{h,m}'
  s.requires_arc = true
  s.dependencies =	pod 'AFNetworking', '~> 2.0.1'
  s.dependencies =	pod 'Reachability', '~> 3.1.1'
  s.dependencies =	pod 'Facebook-iOS-SDK', '~> 3.9.0'
  s.dependencies =	pod 'STTwitter', '~> 0.1.0'
  s.dependencies =	pod 'PFileManager', '~> 0.0.1'
  s.dependencies =	pod 'Mantle', '~> 1.3.1'
  s.dependencies =	pod 'Objective-Shorthand', '~> 1.0'
  s.dependencies =	pod 'Kiwi/XCTest'

end