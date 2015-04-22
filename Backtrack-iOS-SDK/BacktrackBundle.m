//
//  BacktrackBundle.m
//  Pods
//
//  Created by Ahmet Özışık on 20.04.2015.
//
//

#import "BacktrackBundle.h"
#import <AFNetworking/AFNetworking.h>

NSString* const BTBundleVersionKeyForUserDefaults = @"com.backtrack.bundle_version";

@implementation BacktrackBundle

+(int)getLocalVersion {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:BTBundleVersionKeyForUserDefaults] != nil) {
        return [[defaults objectForKey:BTBundleVersionKeyForUserDefaults] intValue];
    }
    
    return 0;
}

+(void)setLocalVersion:(int)version {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:version] forKey:BTBundleVersionKeyForUserDefaults];
    [defaults synchronize];
}

+ (void)checkForUpdates:(BTObjectResultBlock)completionBlock
{
    BacktrackClient* client = [BacktrackClient sharedClient];
    [client getPath:@"updates" parameters:nil success:^(id responseObject) {
        
        int remoteVersion = [(NSNumber*)responseObject[@"data"][@"id"] intValue];
        // if there is a new update
        if(remoteVersion > [BacktrackBundle getLocalVersion]) {
            completionBlock(@[responseObject[@"data"][@"id"], responseObject[@"data"][@"url"]], nil);
        } else {
            // no update
            completionBlock(nil, nil);
        }
        
    } failure:^(NSError *error) {
        completionBlock(nil, error);
    }];
}

// bundle info is an array: 0 -> bundle id, 1 -> bundle url
+ (void)downloadBundle:(NSArray*)bundleInfo progress:(BTDownloadProgressBlock)progressBlock completionHandler:(BTVoidBlock)completionBlock
{
    NSNumber *version = (NSNumber*)[bundleInfo objectAtIndex:0];
    NSString *url     = [bundleInfo objectAtIndex:1];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFURLConnectionOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    // save Data Bundle to disk

    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:[BTDatabase bundleFilePath] append:NO];
    
    if(progressBlock) {
        [operation setDownloadProgressBlock:progressBlock];
    }
    
    [operation setCompletionBlock:^{
        // write version to disk
        [BacktrackBundle setLocalVersion:[version intValue]];
        //
        if(completionBlock) {
            completionBlock();
        }
    }];

    [operation start];
}
@end