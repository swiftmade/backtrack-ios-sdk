//
//  BacktrackBundle.h
//  Pods
//
//  Created by Ahmet Özışık on 20.04.2015.
//
//

#import "BacktrackClient.h"
#import "BTGlobals.h"
#import "BTDatabase.h"

@interface BacktrackBundle : NSObject

@property (nonatomic, copy) NSNumber *version;

+(int)getLocalVersion;
+(void)setLocalVersion:(int)version;

+ (void)checkForUpdates:(BTObjectResultBlock)completionBlock;
+ (void)downloadBundle:(NSString*)url progress:(BTDownloadProgressBlock)progressBlock completionHandler:(BTVoidBlock)completionBlock;

@end
