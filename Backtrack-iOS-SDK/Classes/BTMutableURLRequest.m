//
//  BTMutableURLRequest.m
//  Backtrack-Test
//
//  Created by Ahmet Özışık on 19.04.2015.
//  Copyright (c) 2015 Sailbright. All rights reserved.
//

#import "BTMutableURLRequest.h"

@implementation BTMutableURLRequest

-(id) init {
    self = [super init];
    
    if (self) {
        _contentType = BAAContentTypeJSON;
    }
    
    return self;
}

@end