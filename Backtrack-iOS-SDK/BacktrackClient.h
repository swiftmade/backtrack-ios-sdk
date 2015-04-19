//
//  BacktrackClient.h
//  Backtrack-Test
//
//  Created by Ahmet Özışık on 19.04.2015.
//  Copyright (c) 2015 Sailbright. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BacktrackSDK.h"
#import "BacktrackUser.h"
#import "BTGlobals.h"
#import "BTMutableURLRequest.h"
#import "BTQueryStringPair.h"

@class BacktrackUser;

@interface BacktrackClient : NSObject

@property (nonatomic, strong) BacktrackUser *currentUser;
@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, copy) NSString *clientID;
@property (nonatomic, copy) NSString *clientSecret;
@property (nonatomic, copy) NSString *clientAccessToken;

+ (instancetype)sharedClient;

// Authentication
- (void)authenticateUser:(NSString *)email
                password:(NSString *)password
              completion:(BTBooleanResultBlock)completionBlock;

- (void)createUserWithEmail:(NSString *)username
                password:(NSString *)password
                first_name:(NSString*)first_name
                last_name:(NSString*)last_name
                phone:(NSString*)phone
                completion:(BTBooleanResultBlock)completionBlock;

- (BOOL) isAuthenticated;

- (void) logoutWithCompletion:(BTBooleanResultBlock)completionBlock;
@end
