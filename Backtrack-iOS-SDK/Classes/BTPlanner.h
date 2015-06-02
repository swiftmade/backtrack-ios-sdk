//
//  BTPlanner.h
//  Pods
//
//  Created by Ahmet Özışık on 31.05.2015.
//
//

#import "BTDatabase.h"
#import "NSString+Distance.h"
#import <CoreLocation/CoreLocation.h>


@class BTPlanner;

@protocol BTPlannerDelegate<NSObject>
-(void)detectedFork:(BTPlanner*)planner withOptions:(NSArray*)options;
-(void)planCompleted:(BTPlanner*)planner withPlan:(NSDictionary*)plan;
@end

@interface BTPlanner : NSObject {
    
    NSMutableArray *loadedRoutes;
    NSMutableArray *loadedDistances;
    
    NSMutableArray *designatedRoutes;
    NSMutableArray *designatedDistances;
    
    NSMutableArray *currentFork;
    
    NSString *departure;
    NSString *destination;
}

@property (nonatomic, weak) IBOutlet id <BTPlannerDelegate> delegate;
@property (nonatomic, copy) BTPlanCompletionBlock completionBlock;

-(void)planForDeparture:(NSDictionary*)fromPoint andDestination:(NSDictionary*)toPoint;
-(void)resolveFork:(int)offset;

@end
