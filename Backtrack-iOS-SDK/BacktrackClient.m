//
//  BacktrackClient.m
//  Backtrack-Test
//
//  Created by Ahmet Özışık on 19.04.2015.
//  Copyright (c) 2015 Sailbright. All rights reserved.
//

#import "BacktrackClient.h"


NSString * const kPageNumberKey = @"page";
NSString * const kPageSizeKey = @"recordsPerPage";
NSString * const kSkipKey = @"skip";
NSInteger const kPageLength = 50;

NSString * const kAuthenticationTokenExpiredNotification = @"com.backtrack.tokenExpired";


static NSString * const boundary = @"BTSBOX_BOUNDARY_STRING";

static NSString * const kBTCharactersToBeEscapedInQuery = @"@/:?&=$;+!#()',*";

static NSString * BTPercentEscapedQueryStringKeyFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kBTCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";
    
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kBTCharactersToLeaveUnescapedInQueryStringPairKey, (__bridge CFStringRef)kBTCharactersToBeEscapedInQuery, CFStringConvertNSStringEncodingToEncoding(encoding));
}

static NSString * BTPercentEscapedQueryStringValueFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)kBTCharactersToBeEscapedInQuery, CFStringConvertNSStringEncodingToEncoding(encoding));
}

#pragma mark - URL Serialization borrowed from AFNetworking

@interface BTQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (id)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;
@end

@implementation BTQueryStringPair

- (id)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return BTPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding);
    } else {
        return [NSString stringWithFormat:@"%@=%@", BTPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding), BTPercentEscapedQueryStringValueFromStringWithEncoding([self.value description], stringEncoding)];
    }
}

@end


extern NSArray * BTQueryStringPairsFromDictionary(NSDictionary *dictionary);
extern NSArray * BTQueryStringPairsFromKeyAndValue(NSString *key, id value);

static NSString * BTQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding) {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (BTQueryStringPair *pair in BTQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValueWithEncoding:stringEncoding]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

NSArray * BTQueryStringPairsFromDictionary(NSDictionary *dictionary) {
    return BTQueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSArray * BTQueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = [dictionary objectForKey:nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:BTQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:BTQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in set) {
            [mutableQueryStringComponents addObjectsFromArray:BTQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[BTQueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}

# pragma mark Client


NSString* const BTUserKeyForUserDefaults = @"com.backtrack.user";

@implementation BacktrackClient

+ (instancetype)sharedClient {
    
    static BacktrackClient *sharedBTClient = nil;
    static dispatch_once_t onceBAAToken;
    dispatch_once(&onceBAAToken, ^{
        sharedBTClient = [[BacktrackClient alloc] init];
    });
    
    return sharedBTClient;
}

- (id) init {
    
    if (self = [super init]) {
        
        _baseURL = [NSURL URLWithString:[BacktrackSDK baseURL]];
        _clientID = [BacktrackSDK clientID];
        _clientSecret = [BacktrackSDK clientSecret];
        [self _initSession];
    }
    
    return self;
}

- (void) _initSession {
    
    self.currentUser = [self loadUserFromDisk];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSDictionary *headers = @{@"Accept": @"application/json",
                              @"User-Agent": [NSString stringWithFormat:@"Backtrack iOS SDK %@", VERSION],
                              @"Language": [BacktrackSDK language]
                              };
    sessionConfiguration.HTTPAdditionalHeaders = headers;
    _session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                             delegate:nil
                                        delegateQueue:[NSOperationQueue mainQueue]];
}

#pragma mark - Authentication

- (void)authenticateClient:(BTBooleanResultBlock)completionHandler {
    [self postPath:@"authenticate"
        parameters:@{
                     @"client_id": self.clientID,
                     @"client_secret": self.clientSecret,
                     @"grant_type": @"client_credentials"
                     }
           success:^(NSDictionary *responseObject) {
               
               NSString *token = responseObject[@"access_token"];
               
               if (token) {
                   self.clientAccessToken = token;
                   completionHandler(YES, nil);
                   
               } else {
                   NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                   [errorDetail setValue:responseObject[@"message"]
                                  forKey:NSLocalizedDescriptionKey];
                   NSError *error = [NSError errorWithDomain:[BacktrackSDK errorDomain]
                                                        code:[BacktrackSDK errorCode]
                                                    userInfo:errorDetail];
                   completionHandler(NO, error);
               }
               
           } failure:^(NSError *error) {
               completionHandler(NO, error);
           }];
}

- (void)authenticateUser:(NSString *)email
                password:(NSString *)password
              completion:(BTBooleanResultBlock)completionHandler {
    
    [self postPath:@"authenticate"
        parameters:@{
                     @"email": email,
                     @"password": password,
                     @"client_id": self.clientID,
                     @"client_secret": self.clientSecret,
                     @"grant_type": @"backtrack"
                    }
           success:^(NSDictionary *responseObject) {
               
               NSString *token = responseObject[@"access_token"];
               
               if (token) {
                   
                   NSLog(@"user data: %@", responseObject[@"data"]);
                   BacktrackUser *user = [[BacktrackUser alloc] initWithDictionary:responseObject[@"data"]];
                   user.authenticationToken = token;
                   self.currentUser = user;
                   [self saveUserToDisk:user];
                   completionHandler(YES, nil);
                   
               } else {
                   
                   NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                   [errorDetail setValue:responseObject[@"message"]
                                  forKey:NSLocalizedDescriptionKey];
                   NSError *error = [NSError errorWithDomain:[BacktrackSDK errorDomain]
                                                        code:[BacktrackSDK errorCode]
                                                    userInfo:errorDetail];
                   completionHandler(NO, error);
                   
               }
               
           } failure:^(NSError *error) {
               
               completionHandler(NO, error);
               
           }];
    
}

-(void)createUserWithEmail:(NSString *)email
                password:(NSString *)password
                first_name:(NSString *)first_name
                last_name:(NSString *)last_name
                phone:(NSString *)phone
                completion:(BTBooleanResultBlock)completionHandler
{
    // check client access token
    if(self.clientAccessToken == nil) {
        
        [self authenticateClient:^(BOOL success, NSError *error) {

            if(success && self.clientAccessToken != nil) {
                [self createUserWithEmail:email password:password first_name:first_name last_name:last_name phone:phone completion:completionHandler];
            } else {
                NSLog(@"Error acquiring client access token: %@", [error localizedDescription]);
            }
        }];
        
        return;
    }

    [self postPath:@"users"
        parameters:@{
                     @"email": email,
                     @"password": password,
                     @"first_name": first_name,
                     @"last_name": last_name,
                     @"phone": phone
                     }
           success:^(id responseObject) {
            
               [self authenticateUser:email password:password completion:completionHandler];

           } failure:^(NSError *error) {

               if (completionHandler) {
                   self.currentUser = nil;
                   completionHandler(NO, error);
               }
           }];

}

- (void) logoutWithCompletion:(BTBooleanResultBlock)completionHandler {
    
    [self postPath:@"logout"
        parameters:nil
           success:^(id responseObject) {
               
               if (completionHandler) {
                   self.currentUser = nil;
                   [self saveUserToDisk:self.currentUser];
                   completionHandler(YES, nil);
               }
               
           } failure:^(NSError *error) {
               
               if (completionHandler) {
                   completionHandler(NO, error);
               }
               
           }];
    
}


- (void) updateUserWithCompletion:(BTObjectResultBlock)completionBlock {
    
    [self putPath:@"users/1"
       parameters:@{
                    @"email": self.currentUser.email,
                    @"first_name": self.currentUser.first_name,
                    @"last_name": self.currentUser.last_name,
                    @"phone": self.currentUser.phone
                    }
          success:^(NSDictionary *responseObject) {
            
              // save updated data
              [self saveUserToDisk:self.currentUser];
              
              if (completionBlock) {
                  completionBlock(self.currentUser, nil);
              }
              
          } failure:^(NSError *error) {
              // restore to the previous state
              self.currentUser = [self loadUserFromDisk];
              
              if (completionBlock) {
                  completionBlock(nil, error);
              }
              
          }];
}

- (void) changeOldPassword:(NSString *)oldPassword
             toNewPassword:(NSString *)newPassword
                completion:(BTBooleanResultBlock)completionBlock {
    
    [self postPath:@"users/change_password"
       parameters:@{@"old_password": oldPassword, @"password": newPassword}
          success:^(id responseObject) {
              
              if (completionBlock) {
                  completionBlock(YES, nil);
              }
              
          } failure:^(NSError *error) {
              
              if (completionBlock) {
                  completionBlock(NO, error);
              }
              
          }];
}

#pragma mark - URL Serialization

- (BTMutableURLRequest *)requestWithMethod:(NSString *)method
                                  URLString:(NSString *)path
                                 parameters:(NSDictionary *)parameters {
    
    NSString *u = [[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString];
    NSURL *url = [NSURL URLWithString:u];
    BTMutableURLRequest *request = [[BTMutableURLRequest alloc] initWithURL:url];
    
    if ([method isEqualToString:@"POST"]) {
        request.contentType = BAAContentTypeForm;
    }
    
    [request setHTTPMethod:method];
    
    if(self.currentUser != nil) {
        [request setValue:self.currentUser.authenticationToken forHTTPHeaderField:@"Authorization"];
    } else if(self.clientAccessToken != nil) {
        [request setValue:self.clientAccessToken forHTTPHeaderField:@"Authorization"];
    }

    
    request = [[self requestBySerializingRequest:request withParameters:parameters error:nil] mutableCopy];
    
    return request;
}

- (BTMutableURLRequest *)requestBySerializingRequest:(BTMutableURLRequest *)mutableRequest
                                       withParameters:(id)parameters
                                                error:(NSError *__autoreleasing *)error {
    
    if (!parameters) {
        return mutableRequest;
    }
    
    NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSString *query = BTQueryStringFromParametersWithEncoding(parameters, NSUTF8StringEncoding);
    
    if (mutableRequest.contentType == BAAContentTypeForm) {
        
        [mutableRequest setHTTPBody:[query dataUsingEncoding:NSUTF8StringEncoding]];
        [mutableRequest setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset]
              forHTTPHeaderField:@"Content-Type"];
        
    } else {
        
        [mutableRequest setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset]
              forHTTPHeaderField:@"Content-Type"];
        if ([mutableRequest.HTTPMethod isEqualToString:@"POST"] || [mutableRequest.HTTPMethod isEqualToString:@"PUT"] || [mutableRequest.HTTPMethod isEqualToString:@"DELETE"]) {
            [mutableRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:error]];
        }
        if ([mutableRequest.HTTPMethod isEqualToString:@"GET"]) {
            mutableRequest.URL = [NSURL URLWithString:[[mutableRequest.URL absoluteString] stringByAppendingFormat:mutableRequest.URL.query ? @"&%@" : @"?%@", query]];
        }
        
    }
    
    return mutableRequest;
}

#pragma mark - Client methods

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure {
    
    BTMutableURLRequest *request = [self requestWithMethod:@"GET" URLString:path parameters:parameters];
    
    [[self.session dataTaskWithRequest:request
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

                         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                         NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:nil];
                         
                         if (httpResponse.statusCode >= 400) {
                             
                             NSError *error = [BacktrackSDK authenticationErrorForResponse:jsonObject];
                             failure(error);
                             [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenticationTokenExpiredNotification
                                                                                 object:nil];
                             return;
                             
                         }
                         
                         if (error == nil) {
                             
                             NSString *contentType = [httpResponse.allHeaderFields objectForKey:@"Content-type"];
                             if ([contentType hasPrefix:@"image/"]) {
                                 
                                 success(data);
                                 
                             } else {
                                 
                                 success(jsonObject);
                                 
                             }
                             
                         } else {
                             
                             failure(error);
                             
                         }
                         
                     }] resume];
    
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(id responseObject))success
         failure:(void (^)(NSError *error))failure {

    
    BTMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                  URLString:path
                                                 parameters:parameters];

    [[self.session dataTaskWithRequest:request
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         [self handleRequestResult:data response:response error:error success:success failure:failure];
                     }] resume];
}

- (void)putPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure {
    
    BTMutableURLRequest *request = [self requestWithMethod:@"PUT"
                                                  URLString:path
                                                 parameters:parameters];
    [[self.session dataTaskWithRequest:request
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         [self handleRequestResult:data response:response error:error success:success failure:failure];
                     }] resume];
    
}

- (void)deletePath:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(void (^)(id responseObject))success
           failure:(void (^)(NSError *error))failure {
    
    BTMutableURLRequest *request = [self requestWithMethod:@"DELETE"
                                                  URLString:path
                                                 parameters:parameters];
    [[self.session dataTaskWithRequest:request
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         
                         [self handleRequestResult:data response:response error:error success:success failure:failure];
                         
                     }] resume];
    
}

#pragma mark - Helpers

-(void)handleRequestResult:(NSData*)data
                  response:(NSURLResponse*)response
                     error:(NSError*)error
                   success:(void (^)(id responseObject))success
                   failure:(void (^)(NSError *error))failure
{
    NSHTTPURLResponse *r = (NSHTTPURLResponse*)response;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                               options:kNilOptions
                                                                 error:nil];
    if (r.statusCode >= 400) {
        NSError *error;
        
        if(r.statusCode == 401) {
            error = [BacktrackSDK authenticationErrorForResponse:jsonObject];
            [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenticationTokenExpiredNotification object:nil];
        } else {
            error = [BacktrackSDK serverErrorForResponse:jsonObject];
        }
        
        failure(error);
        return;
    }
    
    if (error == nil) {
        success(jsonObject);
    } else {
        failure(error);
    }
}


- (BacktrackUser *) loadUserFromDisk {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *decodedUser = [defaults objectForKey:BTUserKeyForUserDefaults];
    
    if (decodedUser) {
        
        BacktrackUser *user = (BacktrackUser*)[NSKeyedUnarchiver unarchiveObjectWithData:decodedUser];
        return user;
    } else {
        
        return nil;
    }
}

- (void) saveUserToDisk:(BacktrackUser *)user {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedUser = [NSKeyedArchiver archivedDataWithRootObject:user];
    [defaults setValue:encodedUser forKey:BTUserKeyForUserDefaults];
    [defaults synchronize];
}


- (BOOL) isAuthenticated {
    
    return self.currentUser.authenticationToken != nil;
}

@end
