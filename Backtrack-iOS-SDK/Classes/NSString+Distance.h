//
//  NSString+Distance.h
//
//  Created by Alexander Johansson on 2011-11-27.
//  Based on http://stackoverflow.com/q/5684973/590396
//

#import <Foundation/Foundation.h>

@interface NSString (Distance)

+ (NSString *)stringWithDistance:(double)distance;
// Return a string of the number to one decimal place and with commas & periods based on the locale.


+ (NSString *)stringWithDouble:(double)value;
@end