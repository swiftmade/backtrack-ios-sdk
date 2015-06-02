//
//  BTPlanner.m
//  Pods
//
//  Created by Ahmet Özışık on 31.05.2015.
//
//

#import "BTPlanner.h"

@implementation BTPlanner


-(void)planForDeparture:(NSDictionary *)fromPoint andDestination:(NSDictionary *)toPoint {
    NSDictionary *pathGuide = [[BTDatabase singleton] routesBetween:fromPoint[@"id"] to:toPoint[@"id"]];
    
    departure = fromPoint;
    destination = toPoint;
    
    [self initializeWithRoutes:pathGuide[@"routes"] andDistances:pathGuide[@"distances"]];
}

-(void)initializeWithRoutes:(NSArray*)routes andDistances:(NSArray*)distances {
    loadedRoutes = [routes mutableCopy];
    loadedDistances = [distances mutableCopy];
    
    designatedDistances = [[NSMutableArray alloc] init];
    designatedRoutes = [[NSMutableArray alloc] init];
    
    currentFork = nil;
    
    [self process];
}

-(void)process {
    
    if( ! [loadedRoutes count]) {
        [self finishPlanning];
        return;
    }
    
    id object = [loadedRoutes firstObject];
    
    if([object isKindOfClass:[NSArray class]]) {
        
        NSDictionary *waypoint = [[BTDatabase singleton] waypointsForRoute:[NSString stringWithFormat:@"%@", [object firstObject]]];
        // already in a fork
        if(currentFork == nil) {
            currentFork = [[NSMutableArray alloc] init];
        }
        
        [currentFork addObject:@{
            @"name": waypoint[@"name"],
            @"routes": object,
            @"distances": [loadedDistances objectAtIndex:0]
        }];
        
    } else {
        [designatedRoutes addObject:object];
        [designatedDistances addObject:[loadedDistances objectAtIndex:0]];
    }
    
    // remove the first object
    [loadedRoutes removeObjectAtIndex:0];
    [loadedDistances removeObjectAtIndex:0];
    
    if(currentFork != nil && ( ! [loadedRoutes count] || ! [[loadedRoutes objectAtIndex:0] isKindOfClass:[NSArray class]])) {
        // stop, prompt for fork
        if(self.delegate != nil) {
            [self.delegate detectedFork:self withOptions:currentFork];
        }
    } else {
        [self process];
    }
}

-(void)resolveFork:(int)offset {
    
    NSDictionary *fork = [currentFork objectAtIndex:offset];

    BTPlanner *subPlanner = [[BTPlanner alloc] init];
    subPlanner.delegate = self.delegate;
    
    [subPlanner setCompletionBlock:^(NSArray *routes, NSArray *distances){
        [designatedRoutes addObjectsFromArray:routes];
        [designatedDistances addObjectsFromArray:distances];
    
        currentFork = nil;
        [self process];
    }];
    
    [subPlanner initializeWithRoutes:fork[@"routes"] andDistances:fork[@"distances"]];
}

/**
 * Planned trip: (NSDictionary*)
 * NSDictionary departure Departure point name
 * NSDictionary destination Destination point name
 * NSArray waypoints CLLocations for trip
 * NSArray points Contains NSDictionary objects (name, description) for trip points
 * NSNumber length Length of the trip
 * NSString readableLength Human readable length
 */
-(void)finishPlanning {
    
    if(self.completionBlock != nil) {
        self.completionBlock(designatedRoutes, designatedDistances);
        return;
    } else if(self.delegate == nil) {
        return;
    }
    
    NSMutableArray *waypoints = [[NSMutableArray alloc] init];
    NSMutableArray *points = [[NSMutableArray alloc] init];
    
    for(NSNumber *number in designatedRoutes) {
        NSDictionary *waypointQuery = [[BTDatabase singleton] waypointsForRoute:[NSString stringWithFormat:@"%@", number]];
        [waypoints addObjectsFromArray:waypointQuery[@"waypoints"]];
        [points addObject:@{@"name":waypointQuery[@"name"], @"description":waypointQuery[@"description"]}];
    }
    
    NSNumber *totalDistance = [designatedDistances valueForKeyPath:@"@sum.self"];
    
    NSDictionary *trip = @{@"departure": departure, @"destination": destination, @"waypoints": waypoints, @"points": points, @"length": totalDistance};
    [self.delegate planCompleted:self withPlan:trip];
}

@end
