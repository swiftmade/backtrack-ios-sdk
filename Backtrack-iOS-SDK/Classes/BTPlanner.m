//
//  BTPlanner.m
//  Pods
//
//  Created by Ahmet Özışık on 31.05.2015.
//
//

#import "BTPlanner.h"

@implementation BTPlanner


-(void)resolvePathGuide:(NSArray*)routes {
    
    for(id object in routes) {
        // We sail ahead!
        if([object isKindOfClass:[NSNumber class]]) {
            if(inFork == NO) {
                NSDictionary *wObject = [[BTDatabase singleton] waypointsForRoute:[NSString stringWithFormat:@"%@", object]];
                
                totalLength += [wObject[@"length"] intValue];
                [waypoints addObjectsFromArray:wObject[@"waypoints"]];
            } else {
                
            }
        }
        
        // Fork detected!
        if([object isKindOfClass:[NSArray class]]) {
            inFork = YES;
        }
    }
}


-(NSArray*)getForksInRoute:(NSString*)fromPointID toPoint:(NSString*)toPointID
{
    currentForkIndex = 0;
    inFork = NO;
    
    forks = [[NSMutableArray alloc] init];
    NSDictionary *pathGuide = [[BTDatabase singleton] routesBetween:fromPointID to:toPointID];
    
    for(id obj in pathGuide[@"routes"]) {
        if([obj isKindOfClass:[NSArray class]]) {
            
            if(inFork == NO) {
                // beginning of a fork
                inFork = YES;
                [forks addObject:[[NSMutableArray alloc] init]];
            }
            
            NSDictionary *waypoint = [[BTDatabase singleton] waypointsForRoute:[NSString stringWithFormat:@"%@", [obj firstObject]]];
            [[forks objectAtIndex:currentForkIndex] addObject:waypoint[@"name"]];
            
        } else {
            if(inFork == YES) {
                inFork = NO;
                currentForkIndex++;
            }
        }
    }
    
    return forks;
}

@end
