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
#import "BacktrackBundle.h"
#import "BTGlobals.h"
#import "BTMutableURLRequest.h"
#import "BTQueryStringPair.h"
#import "BTDatabase.h"

@class BacktrackUser;
@class BacktrackBundle;

@interface BacktrackClient : NSObject

@property (nonatomic, strong) BacktrackUser *currentUser;
@property (nonatomic, strong) NSURLSession *session;
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
- (void) forceLogout; // logout without API request

// User
- (void) updateUserWithCompletion:(BTObjectResultBlock)completionBlock;

- (void) changeOldPassword:(NSString *)oldPassword
             toNewPassword:(NSString *)newPassword
                completion:(BTBooleanResultBlock)completionBlock;

- (void) resetPassword:(NSString*)email completion:(BTBooleanResultBlock)completionBlock;

// Core methods
- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure;

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(id responseObject))success
         failure:(void (^)(NSError *error))failure;

- (void)putPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure;

- (void)deletePath:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(void (^)(id responseObject))success
           failure:(void (^)(NSError *error))failure;

// Helpers
-(NSURL*)authenticatedURL:(NSString*)urlString;

@end
