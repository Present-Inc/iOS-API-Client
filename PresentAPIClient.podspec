Pod::Spec.new do |s|
  s.name         = 'PresentAPIClient'
  s.version      = '0.1'
  s.license      = { :file => 'LICENSE', :type => 'MIT' }
  s.homepage     = "http://www.present.tv"
  s.authors      = { 'Justin Makaila' => 'justin@present.tv' }
  s.summary      = 'The API Client for the iOS App'
  s.platform     =  :ios, '7.0'
  s.source       = { :git => 'https://github.com/Present-Inc/iOS-API-Client.git', :tag => s.version.to_s}
  s.source_files = 'PresentAPIClient/Controllers/*.{h,m}', 'PresentAPIClient/Models/*.{h,m}'
  s.requires_arc = true
  
  s.dependency 'AFNetworking', '~> 2.0.1'
  s.dependency 'Reachability', '~> 3.1.1'
  s.dependency 'Facebook-iOS-SDK', '~> 3.9.0'
  s.dependency 'STTwitter', '~> 0.1.0'
  s.dependency 'PFileManager', '~> 0.0.1'
  s.dependency 'Mantle', '~> 1.3.1'
  s.dependency 'Objective-Shorthand', '~> 1.0'
end
