//
//  BacktrackUser.m
//  Backtrack-Test
//
//  Created by Ahmet Özışık on 19.04.2015.
//  Copyright (c) 2015 Sailbright. All rights reserved.
//

#define OBJC_STRINGIFY(x) @#x
#define encodeObject(x) [aCoder encodeObject:x forKey:OBJC_STRINGIFY(x)]
#define decodeObject(x) x = [aDecoder decodeObjectForKey:OBJC_STRINGIFY(x)]
#define encodeBool(x) [aCoder encodeBool:x forKey:OBJC_STRINGIFY(x)]
#define decodeBool(x) x = [aDecoder decodeBoolForKey:OBJC_STRINGIFY(x)]
#define encodeInteger(x) [aCoder encodeInteger:x forKey:OBJC_STRINGIFY(x)]
#define decodeInteger(x) x = [aDecoder decodeIntegerForKey:OBJC_STRINGIFY(x)]

#import "BacktrackUser.h"

@implementation BacktrackUser

- (instancetype) initWithDictionary:(NSDictionary *)dict {
    
    self = [super init];
    
    if (self) {
        _email = dict[@"email"];
        _first_name = dict[@"first_name"];
        _last_name = dict[@"last_name"];
        _phone = dict[@"phone"];
    }
    
    return self;
}


#pragma mark - Login

+ (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(BTBooleanResultBlock)completionHandler {
    
    BacktrackClient *client = [BacktrackClient sharedClient];
    [client authenticateUser:email password:password completion:^(BOOL success, NSError *error) {
        
        if (completionHandler) {
            completionHandler(success, error);
        }
        
    }];
    
}

+ (void) logoutWithCompletion:(BTBooleanResultBlock)completionBlock {
    
    BacktrackClient *client = [BacktrackClient sharedClient];
    [client logoutWithCompletion:^(BOOL success, NSError *error) {
        
        if (completionBlock) {
            completionBlock(success, error);
        }
        
    }];
    
}

#pragma mark - Update

- (void) updateWithCompletion:(BTObjectResultBlock)completionBlock {

    BacktrackClient *client = [BacktrackClient sharedClient];
    [client updateUserWithCompletion:completionBlock];

}


#pragma mark - password

- (void) changeOldPassword:(NSString *)oldPassword toNewPassword:(NSString *)newPassword completionBlock:(BTBooleanResultBlock)completionBlock {
    /*
    BacktrackClient *client = [BacktrackClient sharedClient];
    [client changeOldPassword:oldPassword
                toNewPassword:newPassword
                   completion:completionBlock];
    */
}

- (void) resetPasswordWithCompletion:(BTBooleanResultBlock)completionBlock {
    /*
    BacktrackClient *client = [BacktrackClient sharedClient];
    [client resetPasswordForEmail:self.email
                      withCompletion:completionBlock];
     */
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    
    if(self) {

        decodeObject(_email);
        decodeObject(_first_name);
        decodeObject(_last_name);
        decodeObject(_phone);
        decodeObject(_authenticationToken);
        
    }
    
    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    encodeObject(_email);
    encodeObject(_first_name);
    encodeObject(_last_name);
    encodeObject(_phone);
    encodeObject(_authenticationToken);
    
}

@end
