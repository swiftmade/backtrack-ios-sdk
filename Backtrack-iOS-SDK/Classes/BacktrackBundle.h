//
//  BacktrackBundle.h
//  Pods
//
//  Created by Ahmet Özışık on 20.04.2015.
//
//

#import "BacktrackClient.h"
#import "BTGlobals.h"

@interface BacktrackBundle : NSObject

@property (nonatomic, copy) NSNumber *version;

+(int)getLocalVersion;
+(void)setLocalVersion:(int)version;

+ (void)checkForUpdates:(BTObjectResultBlock)completionBlock;
+ (void)downloadBundle:(NSArray*)bundleInfo progress:(BTDownloadProgressBlock)progressBlock completionHandler:(BTBooleanResultBlock)completionBlock;
+ (void)updateApplication:(BTDownloadProgressBlock)progressBlock completionHandler:(BTBooleanResultBlock)completionBlock;

@end
