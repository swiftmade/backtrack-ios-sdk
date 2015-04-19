//
//  BacktrackSDK.m
//  Backtrack-Test
//
//  Created by Ahmet Özışık on 19.04.2015.
//  Copyright (c) 2015 Sailbright. All rights reserved.
//

#import "BacktrackSDK.h"

@implementation BacktrackSDK

+(void)setBaseURL:(NSString *)baseURL {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:baseURL forKey:API_BASE_URL_KEY];
    [userDefaults synchronize];
}

+(void)setClientID:(NSString *)clientId clientSecret:(NSString *)clientSecret
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:clientId forKey:CLIENT_ID_KEY];
    [userDefaults setObject:clientSecret forKey:CLIENT_SECRET_KEY];
    [userDefaults synchronize];
}

+(NSString*)baseURL {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return (NSString *) [userDefaults objectForKey:API_BASE_URL_KEY];
}

+(NSString*)clientID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return (NSString *) [userDefaults objectForKey:CLIENT_ID_KEY];
}

+(NSString*)clientSecret {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return (NSString *) [userDefaults objectForKey:CLIENT_SECRET_KEY];
}

+ (NSString*) language {
    //
    NSArray* languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    
    if(languages != nil || [languages count] == 0) {
        return @"en"; // fallback language
    }
    
    return [languages firstObject];
}

+ (NSString *) errorDomain {
    return @"com.backtrack.error";
}

+ (NSInteger) errorCode {
    return -13579;
}

+ (NSError *)authenticationErrorForResponse:(NSDictionary *)response {
    
    if (response == nil) {
        NSDictionary *errorDetail = @{NSLocalizedDescriptionKey:@"Server returned an empty response.",
                                      @"iOS SDK Version" : VERSION};
        return [NSError errorWithDomain:[BacktrackSDK errorDomain]
                                   code:-22222
                               userInfo:errorDetail];
    }
    
    NSDictionary *errorDetail = @{NSLocalizedDescriptionKey:response[@"error_description"],
                                  @"iOS SDK Version" : VERSION};
    NSError *error = [NSError errorWithDomain:[BacktrackSDK errorDomain]
                                         code:-22222
                                     userInfo:errorDetail];
    return error;
}

+ (NSError *)serverErrorForResponse:(NSDictionary *)response {
    
    if (response == nil) {
        NSDictionary *errorDetail = @{NSLocalizedDescriptionKey:@"Server returned an empty response.",
                                      @"iOS SDK Version" : VERSION};
        return [NSError errorWithDomain:[BacktrackSDK errorDomain]
                                   code:-22222
                               userInfo:errorDetail];
    }
    
    NSDictionary *errorDetail = @{NSLocalizedDescriptionKey:response[@"message"],
                                  @"iOS SDK Version" : VERSION};
    NSError *error = [NSError errorWithDomain:[BacktrackSDK errorDomain]
                                         code:-22223
                                     userInfo:errorDetail];
    return error;
}

@end
