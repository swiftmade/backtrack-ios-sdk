//
//  BTGlobals.h
//  Backtrack-Test
//
//  Created by Ahmet Özışık on 19.04.2015.
//  Copyright (c) 2015 Sailbright. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTGlobals : NSObject

typedef void (^BTArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^BTObjectResultBlock)(id object, NSError *error);
typedef void (^BTBooleanResultBlock)(BOOL success, NSError *error);
typedef void (^BTIntegerResultBlock)(NSInteger count, NSError *error);
typedef void (^BTDownloadProgressBlock)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);
typedef void (^BTVoidBlock)();
typedef void (^BTPlanCompletionBlock)(NSArray *routes, NSArray *distances);

@end
