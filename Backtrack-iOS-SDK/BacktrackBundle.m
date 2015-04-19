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
NSString* const BTBundleFileName = @"BacktrackDataBundle.sqlite";

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
            completionBlock(responseObject[@"data"][@"url"], nil);
        } else {
            // no update
            completionBlock(nil, nil);
        }
        
    } failure:^(NSError *error) {
        completionBlock(nil, error);
    }];
}

+ (void)downloadBundle:(NSString*)url progress:(BTDownloadProgressBlock)progressBlock completionHandler:(BTVoidBlock)completionBlock
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFURLConnectionOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:BTBundleFileName];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    if(progressBlock) {
        [operation setDownloadProgressBlock:progressBlock];
    }
    
    if(completionBlock) {
        [operation setCompletionBlock:completionBlock];
    }

    [operation start];
}
@end