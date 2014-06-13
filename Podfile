# Present Cocoapods Podfile
# > docs @ http://docs.cocoapods.org/podfile.html
# > install cocoapods: `$ sudo gem install cocoapods; pod setup`

# Declare ios platform
platform :ios, '7.0'

# Location of xcodeproj
xcodeproj './PresentAPIClient.xcodeproj'

# ignore all warnings from all pods
inhibit_all_warnings!

# Pods

# Networking
pod 'AFNetworking', '~> 2.0.1'
pod 'Reachability', '~> 3.1.1'

# Social
pod 'Facebook-iOS-SDK', '~> 3.9.0'
pod 'STTwitter', '~> 0.1.0'

# Utilities
pod 'PFileManager', '~> 0.0.1'
pod 'Mantle', '~> 1.3.1'
pod 'Objective-Shorthand', :head

# Tests
target :PresentAPIClientTests, :exclusive => true do
    pod 'Kiwi/XCTest'
end
