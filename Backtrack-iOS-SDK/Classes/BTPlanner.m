//
//  BTPlanner.m
//  Pods
//
//  Created by Ahmet Özışık on 31.05.2015.
//
//

#import "BTPlanner.h"

@implementation BTPlanner

-(void)planTripFrom:(NSString*)fromPointID toPoint:(NSString*)toPointID forkBlock:(BTTripForkBlock)forkHandler completionBlock:(BTObjectResultBlock)completionHandler
{
    NSLog(@"calculated: %@", [[BTDatabase singleton] routesBetween:fromPointID to:toPointID]);
    
   
}

@end
