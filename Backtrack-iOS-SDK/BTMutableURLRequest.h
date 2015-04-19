//
//  BTMutableURLRequest.h
//  Backtrack-Test
//
//  Created by Ahmet Özışık on 19.04.2015.
//  Copyright (c) 2015 Sailbright. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BTContentType) {
    BAAContentTypeJSON,
    BAAContentTypeForm
};

@interface BTMutableURLRequest : NSMutableURLRequest

@property (assign) BTContentType contentType;

@end