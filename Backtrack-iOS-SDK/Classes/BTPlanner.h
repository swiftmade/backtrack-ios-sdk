//
//  BTPlanner.h
//  Pods
//
//  Created by Ahmet Özışık on 31.05.2015.
//
//

#import "BTDatabase.h"
#import <CoreLocation/CoreLocation.h>

@interface BTPlanner : NSObject
{
    NSMutableArray* waypoints;
    NSUInteger totalLength;
    
    BOOL inFork;
    NSMutableArray* forks;
    NSUInteger currentForkIndex;
}

-(NSArray*)getForksInRoute:(NSString*)fromPointID toPoint:(NSString*)toPointID;

@end
