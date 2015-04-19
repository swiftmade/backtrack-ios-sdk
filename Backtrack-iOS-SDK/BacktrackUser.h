//
//  BacktrackUser.h
//  Backtrack-Test
//
//  Created by Ahmet Özışık on 19.04.2015.
//  Copyright (c) 2015 Sailbright. All rights reserved.
//

#import "BacktrackClient.h"
#import "BTGlobals.h"

@interface BacktrackUser : NSObject <NSCoding>

@property (nonatomic, copy) NSString *authenticationToken;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *first_name;
@property (nonatomic, copy) NSString *last_name;
@property (nonatomic, copy) NSString *phone;

- (instancetype) initWithDictionary:(NSDictionary *)dict;

// login/logout
+ (void) loginWithEmail:(NSString *)email password:(NSString *)password completion:(BTBooleanResultBlock)completionHandler;
+ (void) logoutWithCompletion:(BTBooleanResultBlock)completionBlock;

// update
- (void) updateWithCompletion:(BTObjectResultBlock)completionBlock;

// Password
- (void) changeOldPassword:(NSString *)oldPassword toNewPassword:(NSString *)newPassword completionBlock:(BTBooleanResultBlock)completionBlock;
- (void) resetPasswordWithCompletion:(BTBooleanResultBlock)completionBlock;

@end
