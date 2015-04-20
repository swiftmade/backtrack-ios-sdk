# Backtrack iOS SDK

[![CI Status](http://img.shields.io/travis/aozisik/backtrack-ios-sdk.svg?style=flat)](https://travis-ci.org/Ahmet Ozisik/backtrack-ios-sdk)
[![Version](https://img.shields.io/cocoapods/v/backtrack-ios-sdk.svg?style=flat)](http://cocoapods.org/pods/backtrack-ios-sdk)
[![License](https://img.shields.io/cocoapods/l/backtrack-ios-sdk.svg?style=flat)](http://cocoapods.org/pods/backtrack-ios-sdk)
[![Platform](https://img.shields.io/cocoapods/p/backtrack-ios-sdk.svg?style=flat)](http://cocoapods.org/pods/backtrack-ios-sdk)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

In order to use this SDK, you will need a client access key and secret. The SDK can be integrated for:

- [x] Login capabilities (registration, etc)
- [ ] Multilingual capabilities
- [ ] Access to your application database
- [x] Checking & downloading updates
- [ ] Caching files (photos, videos, etc)
- [ ] Using pre-calculated data from Backtrack to offer point-to-point navigation

## Dependencies

This SDK depends on MapBox, AFNetworking and other third-party open source software. For a full list of dependencies, view the Podspec file.

## Installation

backtrack-ios-sdk is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Backtrack-iOS-SDK"
```

## Configuration
Include "BacktrackClient.h" where necessary and add the following lines to your AppDelegate, inside "didFinishLaunchingWithOptions" method

```objective-c
    [BacktrackSDK setBaseURL:@"https://backtrack.sailbright.com/api/"];
    [BacktrackSDK setClientID:@"yourClientId" clientSecret:@"yourClientSecret"];
```

## Author

Ahmet Ozisik, ozisikahmet@gmail.com

## License

Backtrack iOS SDK is available under the Apache License. See the LICENSE file for more info.
